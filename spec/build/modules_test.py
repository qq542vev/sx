#!/usr/bin/env python3
"""module.mk の一覧更新・依存関係・生成失敗時の出力保持を検証する。"""

import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
FUNCTION = re.compile(r"^((?:__)?sx_[a-z0-9_]+)\(\) \{", re.MULTILINE)


class ModulesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sx modules ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.output = self.root / "build/modules"
        shutil.copytree(ROOT / "src", self.root / "src")
        for relative in ("Makefile", "m4/common.m4", "m4/resolve.m4", "tools/compact.awk"):
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / relative, target)
        self.env = {key: value for key, value in os.environ.items()
                    if key not in ("SX_SYMBOLS", "SX_OUT")}

    def build(self, symbols):
        rules = subprocess.run(["make", "module.mk"], cwd=self.root, env=self.env,
                               capture_output=True, text=True, timeout=60)
        if rules.returncode:
            return rules
        args = ["make", "-f", "module.mk", "SX_OUT=unused.sh"]
        args.extend(f"build/modules/{name}.sh" for name in symbols.split())
        return subprocess.run(args, cwd=self.root, env=self.env,
                              capture_output=True, text=True, timeout=60)

    def assert_build(self, symbols):
        result = self.build(symbols)
        self.assertEqual(0, result.returncode, result.stderr)

    def test_single_module_is_complete_without_unrelated_api(self):
        self.assert_build("sx_uri_enc")
        path = self.output / "sx_uri_enc.sh"
        code = path.read_text(encoding="utf-8")
        functions = FUNCTION.findall(code)
        self.assertTrue(code.startswith("#!/bin/sh\n"))
        self.assertEqual(1, functions.count("sx_uri_enc"))
        self.assertEqual(1, functions.count("__sx_uri_enc"))
        self.assertEqual(len(functions), len(set(functions)))
        self.assertNotIn("sx_uri_is_pct", functions)
        self.assertIn("readonly SX_STR_ALNUM=", code)
        self.assertTrue(os.access(path, os.X_OK))
        self.assertFalse((self.root / "unused.sh").exists())
        result = subprocess.run(["yash", "-o", "posix", "-n", str(path)],
                                capture_output=True, text=True)
        self.assertEqual(0, result.returncode, result.stderr)

    def test_multiple_names_get_separate_files_and_rebuild(self):
        self.assert_build("sx_uri_enc sx_uri_is_pct")
        self.assertEqual({"sx_uri_enc.sh", "sx_uri_is_pct.sh"},
                         {path.name for path in self.output.iterdir()})
        selected = self.output / "sx_uri_enc.sh"
        other = self.output / "sx_uri_is_pct.sh"
        original = selected.read_bytes()
        other_original = other.read_bytes()
        percent_code = other.read_text(encoding="utf-8")
        self.assertEqual({"sx_uri_is_pct", "__sx_uri_is_pct"}, set(FUNCTION.findall(percent_code)))
        self.assertIn("readonly SX_STR_XDIGIT=", percent_code)
        self.assertNotIn("SX_SYS_REV", percent_code)
        self.assertNotIn("SX_CFG_NUM_RANGE", percent_code)
        selected.write_text("古い生成物\n", encoding="utf-8")
        os.utime(selected, (1, 1))
        self.assert_build("sx_uri_enc")
        self.assertEqual(original, selected.read_bytes())
        self.assertEqual(other_original, other.read_bytes())

    def test_failure_keeps_existing_output_and_removes_temporary_files(self):
        self.assert_build("sx_uri_enc")
        path = self.output / "sx_uri_enc.sh"
        original = path.read_bytes()
        (self.root / "m4/resolve.m4").write_text("m4exit(1)\n", encoding="utf-8")
        result = self.build("sx_uri_enc")
        self.assertNotEqual(0, result.returncode)
        self.assertEqual(original, path.read_bytes())
        self.assertEqual([path], list(self.output.iterdir()))

    def test_library_mode_works_without_full_library_and_selects_explicitly(self):
        self.assert_build("sx_uri_enc")
        support = self.root / "spec/support/library.sh"
        support.parent.mkdir(parents=True)
        shutil.copyfile(ROOT / "spec/support/library.sh", support)
        probe = (
            "set -- sx_uri_enc\n. ./spec/support/library.sh\n"
            "sx_uri_enc result 'a b'\nprintf '%s\\n' \"$result\"\n"
        )
        env = {key: value for key, value in self.env.items() if key != "SX_TEST_MODE"}
        # sx.sh が存在しなくても、既定と module 指定では個別版だけで動作する。
        for mode in (None, "module"):
            with self.subTest(mode=mode):
                selected_env = env if mode is None else dict(env, SX_TEST_MODE=mode)
                result = subprocess.run(["yash", "-efu", "-o", "posix", "-c", probe],
                                        cwd=self.root, env=selected_env, capture_output=True, text=True)
                self.assertEqual(0, result.returncode, result.stderr)
                self.assertEqual("a%20b\n", result.stdout)
        # 全体版用の目印を置き、full 指定で読み込み先が切り替わることを検査する。
        (self.root / "sx.sh").write_text("sx_uri_enc() { result=full; }\n", encoding="utf-8")
        result = subprocess.run(["yash", "-efu", "-o", "posix", "-c", probe],
                                cwd=self.root, env=dict(env, SX_TEST_MODE="full"),
                                capture_output=True, text=True)
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("full\n", result.stdout)
        result = subprocess.run(["yash", "-efu", "-o", "posix", "-c", probe],
                                cwd=self.root, env=dict(env, SX_TEST_MODE="invalid"),
                                capture_output=True, text=True)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("SX_TEST_MODE", result.stderr)

    def test_unknown_targets_fail(self):
        for symbols in ("unknown_name", "1invalid"):
            with self.subTest(symbols=symbols):
                result = self.build(symbols)
                self.assertNotEqual(0, result.returncode)
                self.assertFalse(list(self.root.rglob("*.sh")))

    def test_library_rejects_invalid_arguments_in_both_modes(self):
        support = self.root / "spec/support/library.sh"
        support.parent.mkdir(parents=True)
        shutil.copyfile(ROOT / "spec/support/library.sh", support)
        (self.root / "sx.sh").write_text("marker=full\n", encoding="utf-8")
        for mode in ("module", "full"):
            for args in ([], [""], ["1invalid"], ["../outside"],
                         ["spec/uri/enc_spec.sh"], ["sx_uri_enc", "sx_uri_is_pct"]):
                with self.subTest(mode=mode, args=args):
                    result = subprocess.run(
                        ["yash", "-efu", "-o", "posix", "-c",
                         '. ./spec/support/library.sh', "probe", *args],
                        cwd=self.root, env=dict(self.env, SX_TEST_MODE=mode),
                        capture_output=True, text=True)
                    self.assertNotEqual(0, result.returncode)
                    self.assertIn("提供名", result.stderr)


class ModuleRulesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sx module rules ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.env = {key: value for key, value in os.environ.items()
                    if key not in ("SX_SYMBOLS", "SX_OUT")}
        for relative in ("Makefile", "m4/common.m4", "m4/resolve.m4", "tools/compact.awk"):
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / relative, target)
        self.units = {
            "constants/SX_STR_SAMPLE": 'M_REQUIRE([||])dnl\nreadonly SX_STR_SAMPLE=sample\n',
            "globals/SX_SYS_SAMPLE": 'M_REQUIRE([|SX_STR_SAMPLE|])dnl\nSX_SYS_SAMPLE=$SX_STR_SAMPLE\n',
            "functions/__sx_sample": 'M_REQUIRE([|SX_SYS_SAMPLE|])dnl\n__sx_sample() { result=$SX_SYS_SAMPLE; }\n',
            "functions/sx_sample": 'M_REQUIRE([|__sx_sample|])dnl\nsx_sample() { __sx_sample; }\n',
        }
        for relative, body in self.units.items():
            path = self.root / "src" / f"{relative}.m4"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(body, encoding="utf-8")
        for group in ("constants", "globals", "functions"):
            body = "".join(
                f'M_UNIT([|{relative.split("/")[-1]}|], [|src/{relative}.m4|])dnl\n'
                for relative in sorted(self.units) if relative.startswith(group + "/"))
            (self.root / "src" / f"{group}.m4").write_text(body, encoding="utf-8")

    def make(self, *args, overrides=None):
        return subprocess.run(["make", *args], cwd=self.root,
                              env=dict(self.env, **(overrides or {})),
                              capture_output=True, text=True, timeout=60)

    def assert_make(self, *args, overrides=None):
        result = self.make(*args, overrides=overrides)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        return result

    def outputs(self):
        return {path.name: path.stat().st_mtime_ns
                for path in (self.root / "build/modules").glob("*.sh")}

    def test_module_builds_all_source_units_without_specs(self):
        self.assert_make("-j4", "module", overrides={"SX_SYMBOLS": "unknown", "SX_OUT": "unused.sh"})
        self.assertEqual({relative.split("/")[-1] + ".sh" for relative in self.units},
                         set(self.outputs()))
        self.assertFalse((self.root / "unused.sh").exists())
        self.assertFalse((self.root / "build/modules/functions.sh").exists())
        self.assertFalse((self.root / "spec").exists())

    def test_individual_target_includes_its_dependencies(self):
        self.assert_make("module.mk")
        self.assert_make("-f", "module.mk", "build/modules/sx_sample.sh")
        self.assertEqual({"sx_sample.sh"}, set(self.outputs()))
        result = subprocess.run(
            ["yash", "-efu", "-o", "posix", "-c",
             '. ./build/modules/sx_sample.sh; sx_sample; printf "%s" "$result"'],
            cwd=self.root, capture_output=True, text=True)
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual("sample", result.stdout)

    def test_direct_default_builds_all_and_unchanged_files_are_not_rebuilt(self):
        self.assert_make("module.mk")
        self.assert_make("-f", "module.mk")
        before = self.outputs()
        rules_time = (self.root / "module.mk").stat().st_mtime_ns
        self.assertEqual(4, len(before))
        self.assert_make("module")
        self.assertEqual(before, self.outputs())
        self.assertEqual(rules_time, (self.root / "module.mk").stat().st_mtime_ns)

    def test_any_source_change_rebuilds_all_but_individual_target_only_rebuilds_itself(self):
        self.assert_make("module")
        before = self.outputs()
        # 定数の生成物も、参照していない公開関数の変更に依存する。
        (self.root / "src/functions/sx_sample.m4").touch()
        self.assert_make("-f", "module.mk", "build/modules/sx_sample.sh")
        partial = self.outputs()
        self.assertNotEqual(before["sx_sample.sh"], partial["sx_sample.sh"])
        for name in before.keys() - {"sx_sample.sh"}:
            self.assertEqual(before[name], partial[name])
        self.assert_make("-f", "module.mk")
        for name, timestamp in before.items():
            self.assertGreater(self.outputs()[name], timestamp)

    def test_common_build_files_and_manifests_trigger_rebuilds(self):
        self.assert_make("module")
        for relative in ("Makefile", "m4/common.m4", "m4/resolve.m4", "tools/compact.awk",
                         "src/constants.m4", "src/globals.m4", "src/functions.m4"):
            with self.subTest(relative=relative):
                before = self.outputs()
                (self.root / relative).touch()
                self.assert_make("-f", "module.mk")
                for name, timestamp in before.items():
                    self.assertGreater(self.outputs()[name], timestamp)

    def test_addition_and_removal_require_explicit_rule_refresh(self):
        self.assert_make("module.mk")
        rules = (self.root / "module.mk").read_bytes()
        added = self.root / "src/functions/sx_added.m4"
        added.write_text('M_REQUIRE([||])dnl\nsx_added() { :; }\n', encoding="utf-8")
        manifest = self.root / "src/functions.m4"
        original = manifest.read_text(encoding="utf-8")
        manifest.write_text(original + 'M_UNIT([|sx_added|], [|src/functions/sx_added.m4|])dnl\n',
                            encoding="utf-8")
        result = self.make("-f", "module.mk", "build/modules/sx_added.sh")
        self.assertNotEqual(0, result.returncode)
        self.assertEqual(rules, (self.root / "module.mk").read_bytes())
        self.assert_make("module")
        self.assertIn("sx_added.sh", self.outputs())
        added.unlink()
        manifest.write_text(original, encoding="utf-8")
        self.assertNotEqual(0, self.make("-f", "module.mk").returncode)
        self.assert_make("module.mk")
        self.assertNotIn("sx_added", (self.root / "module.mk").read_text(encoding="utf-8"))
        self.assert_make("-f", "module.mk")

    def test_invalid_or_duplicate_names_keep_previous_rules(self):
        self.assert_make("module.mk")
        original = (self.root / "module.mk").read_bytes()
        for name in ("bad-name", "SX_STR_SAMPLE"):
            with self.subTest(name=name):
                path = self.root / "src/functions" / f"{name}.m4"
                path.write_text("", encoding="utf-8")
                result = self.make("module.mk")
                self.assertNotEqual(0, result.returncode)
                self.assertEqual(original, (self.root / "module.mk").read_bytes())
                self.assertFalse(list(self.root.glob("module.mk.tmp.*")))
                path.unlink()

    def test_clean_removes_generated_files_and_old_targets_are_unavailable(self):
        self.assert_make("module")
        self.assert_make("clean")
        self.assertFalse((self.root / "module.mk").exists())
        self.assertEqual({}, self.outputs())
        self.assertTrue((self.root / "src/functions/sx_sample.m4").exists())
        for target in ("modules", "test-modules"):
            with self.subTest(target=target):
                self.assertNotEqual(0, self.make(target).returncode)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
