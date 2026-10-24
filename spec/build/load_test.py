#!/usr/bin/env python3
"""sxtest_load の読み込み順序と環境変数による上書きを検証する。"""

import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class LoadTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sx load ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        modules = self.root / "build/modules"
        modules.mkdir(parents=True)
        (modules / "sx_first.sh").write_text(
            'loaded="${loaded-}first "\n'
            'loaded_fn() { printf "%s" available; }\n', encoding="utf-8")
        (modules / "sx_second.sh").write_text(
            'loaded="${loaded-}second "\n', encoding="utf-8")
        (modules / "sx_fail.sh").write_text("return 23\n", encoding="utf-8")
        self.env = {key: value for key, value in os.environ.items()
                    if key != "SXTEST_LOAD_MOD"}

    def run_shell(self, code, overrides=None):
        env = dict(self.env, **(overrides or {}))
        helper = shlex.quote(str(ROOT / "spec/spec_helper.sh"))
        return subprocess.run(
            ["yash", "-efu", "-o", "posix", "-c", f". {helper}\n{code}"],
            cwd=self.root, env=env, capture_output=True, text=True, timeout=30)

    def test_arguments_load_in_order_and_keep_definitions_in_caller(self):
        result = self.run_shell(
            'set -- parent "a b"\n'
            'sxtest_load ./build/modules/sx_second.sh ./build/modules/sx_first.sh\n'
            'check_no_leak\n'
            'printf "%s|%s|%s|%s" "$loaded" "$#" "$1" "$2"\n'
            'loaded_fn\n')
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("second first |2|parent|a bavailable", result.stdout)

    def test_environment_overrides_arguments_and_accepts_repeated_spaces(self):
        result = self.run_shell(
            'sxtest_load invalid:name\n'
            'printf "%s" "$loaded"\n',
            {"SXTEST_LOAD_MOD": "  ./build/modules/sx_second.sh   ./build/modules/sx_first.sh  "})
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("second first ", result.stdout)

    def test_empty_lists_succeed_without_loading(self):
        for value in (None, "", "   "):
            with self.subTest(value=value):
                env = {} if value is None else {"SXTEST_LOAD_MOD": value}
                call = "sxtest_load" if value is None else "sxtest_load invalid:name"
                result = self.run_shell(f'{call}\nprintf "%s" "${{loaded-unset}}"\n', env)
                self.assertEqual(0, result.returncode, result.stderr)
                self.assertEqual("unset", result.stdout)

    def test_environment_split_preserves_ifs_and_shell_options(self):
        for setup in ("IFS=:; set +f", "IFS=; set -f", "unset IFS; set +f"):
            with self.subTest(setup=setup):
                result = self.run_shell(
                    f'{setup}\n'
                    'before_ifs="${IFS+x}:${IFS-}"\n'
                    'before_flags=$-\n'
                    'sxtest_load\n'
                    '[ "${IFS+x}:${IFS-}" = "$before_ifs" ]\n'
                    '[ "$-" = "$before_flags" ]\n'
                    'check_no_leak\n'
                    'printf "%s" "$loaded"\n',
                    {"SXTEST_LOAD_MOD": "./build/modules/sx_first.sh ./build/modules/sx_second.sh"})
                self.assertEqual(0, result.returncode, result.stderr)
                self.assertEqual("first second ", result.stdout)

    def test_modules_observe_restored_state(self):
        (self.root / "build/modules/sx_state.sh").write_text(
            'observed_ifs=$IFS\nobserved_flags=$-\n', encoding="utf-8")
        result = self.run_shell(
            'IFS=:; set +f\n'
            'before_flags=$-\n'
            'sxtest_load\n'
            '[ "$observed_ifs" = : ]\n'
            '[ "$observed_flags" = "$before_flags" ]\n',
            {"SXTEST_LOAD_MOD": "./build/modules/sx_state.sh"})
        self.assertEqual(0, result.returncode, result.stderr)

    def test_duplicates_are_loaded_again(self):
        result = self.run_shell(
            'sxtest_load ./build/modules/sx_first.sh ./build/modules/sx_first.sh\nprintf "%s" "$loaded"\n')
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("first first ", result.stdout)

    def test_empty_path_argument_is_rejected(self):
        result = self.run_shell("sxtest_load ''\n")
        self.assertEqual(64, result.returncode)
        self.assertIn("パスが空", result.stderr)

    def test_paths_are_literal_and_do_not_expand_globs_or_execute_code(self):
        (self.root / "sx_first.sh").write_text("loaded=expanded\n", encoding="utf-8")
        for name in ("sx_*.sh", "x;exit 29", "$(exit 29)", "build/modules"):
            for use_env in (False, True):
                with self.subTest(name=name, use_env=use_env):
                    env = {"SXTEST_LOAD_MOD": name} if use_env else {}
                    args = "" if use_env else shlex.quote(name)
                    result = self.run_shell(f'set +f\nsxtest_load {args}\n', env)
                    self.assertEqual(1, result.returncode, result.stderr)
                    self.assertIn(name.split(" ")[0] if use_env else name, result.stderr)
                    self.assertEqual("", result.stdout)

    def test_absolute_parent_and_quoted_paths_with_spaces_are_supported(self):
        path = self.root / "space quote' *.sh"
        path.write_text('loaded="${loaded-}path "\n', encoding="utf-8")
        result = self.run_shell(
            f'sxtest_load {shlex.quote(str(path))}\n'
            f'sxtest_load {shlex.quote(path.name)}\n'
            'cd build\n'
            f'sxtest_load {shlex.quote("../" + path.name)}\n'
            'printf "%s" "$loaded"\n')
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("path path path ", result.stdout)

    def test_full_library_override_uses_working_directory_without_path_search(self):
        (self.root / "sx.sh").write_text("loaded=full\n", encoding="utf-8")
        shadow = self.root / "shadow"
        shadow.mkdir()
        (shadow / "sx.sh").write_text("loaded=wrong\n", encoding="utf-8")
        result = self.run_shell(
            f'PATH={shlex.quote(str(shadow))}:$PATH\n'
            'sxtest_load ./build/modules/sx_first.sh\n'
            'printf "%s" "$loaded"\n', {"SXTEST_LOAD_MOD": "sx.sh"})
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("full", result.stdout)

    def test_missing_module_returns_failure_without_exiting_caller(self):
        result = self.run_shell(
            'if sxtest_load ./build/modules/sx_missing.sh; then exit 99; else status=$?; fi\n'
            'printf "%s" "$status"\n')
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("1", result.stdout)
        self.assertIn("sx_missing", result.stderr)

    def test_module_failure_stops_before_next_module(self):
        result = self.run_shell(
            'if sxtest_load ./build/modules/sx_fail.sh ./build/modules/sx_first.sh; then exit 99; else status=$?; fi\n'
            'printf "%s:%s" "$status" "${loaded-unset}"\n')
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("23:unset", result.stdout)

    def test_real_module_loads_and_runs(self):
        output = self.root / "build/modules/sx_uri_enc.sh"
        build = subprocess.run(
            ["make", "bundle", "SX_SYMBOLS=sx_uri_enc", f"SX_OUT={output}"],
            cwd=ROOT, capture_output=True, text=True, timeout=30)
        self.assertEqual(0, build.returncode, build.stderr)
        result = self.run_shell(
            'sxtest_load ./build/modules/sx_uri_enc.sh\n'
            'sx_uri_enc result "a b"\n'
            'check_no_leak\n'
            'printf "%s" "$result"\n')
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("a%20b", result.stdout)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
