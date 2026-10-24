#!/usr/bin/env python3
"""関数の一覧・単独展開・全体ビルドとの一致を検証する。"""

import os
from pathlib import Path
import re
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
FUNCTION = re.compile(r"^((?:__)?sx_[a-z0-9_]+)\(\) \{", re.MULTILINE)
UNIT = re.compile(r"^M_UNIT\(\[\|([^|]+)\|\],", re.MULTILINE)


def run(command, data=None):
    # yash は入力のコメント・リテラルもロケールに従って読む。awk の圧縮は C で行う。
    locale = "C.UTF-8" if command[0] == "yash" else "C"
    result = subprocess.run(command, input=data, capture_output=True, cwd=ROOT,
                            env=dict(os.environ, LC_ALL=locale))
    if result.returncode:
        raise AssertionError(f"{command}: {result.returncode}\n" + result.stderr.decode())
    return result.stdout


def compact(data):
    return run(["awk", "-f", "tools/compact.awk"], data)


class SplitFunctionsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.files = sorted((ROOT / "src/func").glob("**/*.m4"))

    def test_inventory_and_order(self):
        """全関数を一度ずつ収録し、一覧順で展開する。"""
        expected = UNIT.findall((ROOT / "src/func.m4").read_text(encoding="utf-8"))
        self.assertTrue(expected)
        self.assertEqual(len(expected), len(set(expected)))
        self.assertEqual(sorted(expected), sorted(path.stem for path in self.files))
        expanded = run(["m4", "--", "m4/common.m4", "src/func.m4"])
        self.assertEqual(expected, FUNCTION.findall(expanded.decode()))
        for path in self.files:
            with self.subTest(path=path.relative_to(ROOT)):
                self.assertEqual([path.stem], FUNCTION.findall(path.read_text(encoding="utf-8")))

    def test_independent_expansion_and_cleanup_scope(self):
        """全ファイルを単独展開し、外側の CLEANUP の有無によらず同じコードを得る。"""
        separator = "SPLIT_FUNCTION_SCOPE_SEPARATOR\n"
        for path in self.files:
            with self.subTest(path=path.relative_to(ROOT)):
                include = f"include([|{path.relative_to(ROOT).as_posix()}|])dnl\n"
                probe = (
                    "define([|CLEANUP|], [|SAVED_CLEANUP|])dnl\n" + include
                    + "ifelse(defn([|CLEANUP|]), [|SAVED_CLEANUP|], [||], [|m4exit(1)|])dnl\n"
                    + "undefine([|CLEANUP|])dnl\n" + separator + include
                    + "ifdef([|CLEANUP|], [|m4exit(1)|])dnl\n"
                )
                expanded = run(["m4", "--", "m4/common.m4", "-"], probe.encode())
                before, after = expanded.split(separator.encode())
                self.assertEqual(before, after)
                code = compact(before)
                self.assertEqual([path.stem], FUNCTION.findall(before.decode()))
                self.assertNotRegex(code.decode(), r"\b(?:Q_[A-Za-z0-9_]*|M_[A-Za-z0-9_]*|__M_[A-Za-z0-9_]*|__sx_m4_gen_[A-Za-z0-9_]*|CLEANUP)\b")
                run(["yash", "-o", "posix", "-n"], code)

    def test_shared_callback_names(self):
        """ファイル名が異なるコールバックでも親の名前空間を使う。"""
        cases = (
            ("__sx_str_escape_cb", "str_escape", "cb_se"),
            ("__sx_str_sub_isep_adapt", "str_sub", "cb"),
        )
        for name, base, variable in cases:
            with self.subTest(name=name):
                expanded = run(["m4", "--", "m4/common.m4", f"src/func/str/{name}.m4"])
                self.assertIn(f"__sx_{base}_{variable}_".encode(), expanded)
                self.assertNotIn(f"{name}_{variable}_".encode(), expanded)

    def test_complete_assembly(self):
        """全一覧を直接結合すると標準出力とバイト単位で一致する。"""
        actual = compact(run(["m4", "--", "m4/common.m4", "src/const.m4",
                              "src/var.m4", "src/func.m4"]))
        self.assertEqual((ROOT / "sx.sh").read_bytes(), b"#!/bin/sh\n" + actual)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
