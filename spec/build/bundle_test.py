#!/usr/bin/env python3
"""m4 と make による全体版・部分版ビルドの契約を検証する。"""

import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
FUNCTION = re.compile(r"^((?:__)?sx_[a-z0-9_]+)\(\) \{", re.MULTILINE)


class BundleTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sx-bundle-")
        self.addCleanup(self.temp.cleanup)
        self.output = Path(self.temp.name) / "selected.sh"
        self.env = dict(os.environ)
        self.env.pop("SX_SYMBOLS", None)
        self.env.pop("SX_OUT", None)

    def build(self, symbols=None, output=None, target=None):
        args = ["make", f"SX_OUT={output or self.output}"]
        if symbols is not None:
            args.append(f"SX_SYMBOLS={symbols}")
        if target is not None:
            args.append(target)
        return subprocess.run(args, cwd=ROOT, env=self.env, capture_output=True,
                              text=True, timeout=60)

    def evaluate(self, code, overrides=None):
        env = dict(self.env, LC_ALL="C")
        env.update(overrides or {})
        result = subprocess.run(["yash", "-efu", "-o", "posix"], input=code,
                                text=True, capture_output=True, env=env, cwd=ROOT)
        self.assertEqual(0, result.returncode, result.stderr)
        return result.stdout

    def assert_build(self, symbols):
        result = self.build(symbols)
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertTrue(self.output.read_bytes().startswith(b"#!/bin/sh\n"))
        syntax = subprocess.run(["yash", "-o", "posix", "-n", str(self.output)],
                                capture_output=True, text=True)
        self.assertEqual(0, syntax.returncode, syntax.stderr)
        return self.output.read_text(encoding="utf-8")

    def test_uri_single_and_runtime(self):
        content = self.assert_build("sx_uri_enc")
        functions = FUNCTION.findall(content)
        self.assertEqual(1, functions.count("sx_uri_enc"))
        self.assertEqual(1, functions.count("__sx_uri_enc"))
        self.assertNotIn("sx_uri_is_pct", functions)
        self.assertIn("readonly SX_STR_ALNUM=", content)
        self.assertEqual("a%20b\n", self.evaluate(
            f". {shlex.quote(str(self.output))}\n"
            "sx_uri_enc answer 'a b'\nprintf '%s\\n' \"$answer\"\n"))

    def test_multiple_roots_and_rebuild(self):
        self.assert_build("sx_uri_enc sx_uri_is_pct")
        self.assertIn("sx_uri_is_pct", FUNCTION.findall(self.output.read_text()))
        self.assert_build("sx_uri_enc sx_uri_enc")
        self.assertNotIn("sx_uri_is_pct", FUNCTION.findall(self.output.read_text()))
        duplicate = self.output.read_bytes()
        self.assert_build("sx_uri_enc")
        self.assertEqual(duplicate, self.output.read_bytes())

    def test_cycle_emits_each_function_once(self):
        content = self.assert_build("__sx_arr_push_raw")
        functions = FUNCTION.findall(content)
        self.assertEqual(1, functions.count("__sx_arr_push_raw"))
        self.assertEqual(len(functions), len(set(functions)))

    def test_numeric_global_selects_only_its_field(self):
        content = self.assert_build("SX_SYS_NUM_MAX")
        self.assertIn('SX_SYS_NUM_MAX=', content)
        self.assertNotIn('SX_SYS_NUM_MIN=', content)
        for width in (32, 64, 128):
            with self.subTest(width=width):
                self.assertRegex(content, rf"\bSX_NUM_I{width}_MAX=")
                self.assertNotRegex(content, rf"\bSX_NUM_I{width}_MIN=")
                output = self.evaluate(
                    f". {shlex.quote(str(self.output))}\n"
                    f"printf '%s\\n%s\\n' \"$SX_SYS_NUM_MAX\" \"$SX_NUM_I{width}_MAX\"\n",
                    {"SX_CFG_NUM_RANGE": str(width)})
                first, second = output.splitlines()
                self.assertEqual(first, second)

    def test_invalid_request_keeps_existing_output(self):
        self.output.write_text("既存の内容\n", encoding="utf-8")
        for symbols in ("unknown_name", "sx_uri_enc  sx_cfg_set"):
            with self.subTest(symbols=symbols):
                result = self.build(symbols)
                self.assertNotEqual(0, result.returncode)
                self.assertEqual("既存の内容\n", self.output.read_text(encoding="utf-8"))
                self.assertFalse(Path(str(self.output) + ".tmp").exists())
                self.assertFalse(Path(str(self.output) + ".tmp2").exists())

    def test_global_cycle_and_duplicate_name_are_errors(self):
        fixture = Path(self.temp.name)
        (fixture / "m4").mkdir()
        (fixture / "src/globals").mkdir(parents=True)
        shutil.copyfile(ROOT / "m4/common.m4", fixture / "m4/common.m4")
        shutil.copyfile(ROOT / "m4/resolve.m4", fixture / "m4/resolve.m4")
        (fixture / "src/constants.m4").write_text("", encoding="utf-8")
        (fixture / "src/functions.m4").write_text("", encoding="utf-8")
        unit_a = "M_UNIT([|SX_SYS_A|], [|src/globals/SX_SYS_A.m4|])dnl\n"
        unit_b = "M_UNIT([|SX_SYS_B|], [|src/globals/SX_SYS_B.m4|])dnl\n"
        (fixture / "src/globals.m4").write_text(unit_a + unit_b, encoding="utf-8")
        (fixture / "src/globals/SX_SYS_A.m4").write_text(
            "M_REQUIRE([|SX_SYS_B|])dnl\nSX_SYS_A=1\n", encoding="utf-8")
        (fixture / "src/globals/SX_SYS_B.m4").write_text(
            "M_REQUIRE([|SX_SYS_A|])dnl\nSX_SYS_B=1\n", encoding="utf-8")
        command = ["m4", "-DSX_SYMBOLS=SX_SYS_A", "--", "m4/resolve.m4"]
        result = subprocess.run(command, cwd=fixture, capture_output=True, text=True)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("初期化依存の循環", result.stderr)

        (fixture / "src/globals.m4").write_text(unit_a + unit_a, encoding="utf-8")
        result = subprocess.run(command, cwd=fixture, capture_output=True, text=True)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("定義の重複", result.stderr)

        (fixture / "src/functions").mkdir()
        (fixture / "src/functions.m4").write_text(
            "M_UNIT([|sx_util_dummy|], [|src/functions/sx_util_dummy.m4|])dnl\n",
            encoding="utf-8")
        (fixture / "src/functions/sx_util_dummy.m4").write_text(
            "M_REQUIRE([||])dnl\nsx_util_dummy() { :; }\n", encoding="utf-8")
        (fixture / "src/globals.m4").write_text(unit_a, encoding="utf-8")
        (fixture / "src/globals/SX_SYS_A.m4").write_text(
            "M_REQUIRE([|sx_util_dummy|])dnl\nSX_SYS_A=1\n", encoding="utf-8")
        result = subprocess.run(command, cwd=fixture, capture_output=True, text=True)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("初期化から関数への依存", result.stderr)

        (fixture / "src/constants").mkdir()
        (fixture / "src/constants.m4").write_text(
            "M_UNIT([|SX_STR_DUMMY|], [|src/constants/SX_STR_DUMMY.m4|])dnl\n",
            encoding="utf-8")
        (fixture / "src/constants/SX_STR_DUMMY.m4").write_text(
            "M_REQUIRE([|SX_SYS_A|])dnl\nreadonly SX_STR_DUMMY=x\n", encoding="utf-8")
        (fixture / "src/globals/SX_SYS_A.m4").write_text(
            "M_REQUIRE([||])dnl\nSX_SYS_A=1\n", encoding="utf-8")
        result = subprocess.run(["m4", "-DSX_SYMBOLS=SX_STR_DUMMY", "--", "m4/resolve.m4"],
                                cwd=fixture, capture_output=True, text=True)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("定数から実行時状態への依存", result.stderr)

    def test_all_units_match_normal_build(self):
        names = []
        for group in ("constants", "globals", "functions"):
            manifest = (ROOT / "src" / f"{group}.m4").read_text(encoding="utf-8")
            names.extend(re.findall(r"^M_UNIT\(\[\|([^|]+)\|\],", manifest, re.MULTILINE))
        self.assertEqual(700, len(names))
        self.assert_build(" ".join(names))
        self.assertEqual((ROOT / "sx.sh").read_bytes(), self.output.read_bytes())

    def test_omitted_and_empty_symbols_select_all(self):
        result = self.build()
        self.assertEqual(0, result.returncode, result.stderr)
        expected = self.output.read_bytes()
        self.assertEqual((ROOT / "sx.sh").read_bytes(), expected)
        for target in (None, "all", "bundle"):
            with self.subTest(target=target):
                result = self.build("", target=target)
                self.assertEqual(0, result.returncode, result.stderr)
                self.assertEqual(expected, self.output.read_bytes())

    def test_default_target_accepts_selection(self):
        result = self.build("sx_uri_enc")
        self.assertEqual(0, result.returncode, result.stderr)
        functions = FUNCTION.findall(self.output.read_text(encoding="utf-8"))
        self.assertIn("sx_uri_enc", functions)
        self.assertNotIn("sx_uri_is_pct", functions)

    def test_test_target_forces_full_build(self):
        result = subprocess.run(["make", "-n", "SX_SYMBOLS=sx_uri_enc", "test"],
                                cwd=ROOT, env=self.env, capture_output=True, text=True)
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertIn("SX_SYMBOLS= SX_OUT=sx.sh all", result.stdout)
        self.assertIn("make module", result.stdout)
        self.assertIn("unset SXTEST_LOAD_MOD; shellspec", result.stdout)
        self.assertIn("SXTEST_LOAD_MOD=sx.sh shellspec", result.stdout)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
