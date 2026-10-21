#!/usr/bin/env python3
"""機能ごとの生成・再生成・生成失敗時の出力保持を検証する。"""

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
        # ソースは参照だけ共有し、Makefile と生成器は障害試験用にコピーする。
        (self.root / "src").symlink_to(ROOT / "src", target_is_directory=True)
        for relative in ("Makefile", "m4/common.m4", "m4/resolve.m4", "tools/compact.awk"):
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / relative, target)
        self.env = {key: value for key, value in os.environ.items()
                    if key not in ("SX_SYMBOLS", "SX_OUT")}

    def build(self, symbols=None):
        args = ["make", "modules", "SX_OUT=unused.sh"]
        if symbols is not None:
            args.append(f"SX_SYMBOLS={symbols}")
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
        self.assertIn("sx_uri_is_pct", FUNCTION.findall(other.read_text(encoding="utf-8")))
        selected.write_text("古い生成物\n", encoding="utf-8")
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

    def test_empty_unknown_and_invalid_names_fail(self):
        for symbols in (None, "", "unknown_name", "../outside", "sx_uri_enc  sx_uri_is_pct", "1invalid"):
            with self.subTest(symbols=symbols):
                result = self.build(symbols)
                self.assertNotEqual(0, result.returncode)
                self.assertFalse(list(self.root.rglob("*.sh")))


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
