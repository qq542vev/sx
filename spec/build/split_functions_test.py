#!/usr/bin/env python3
"""関数分割の完全性・単独展開・既存ビルドとの一致を検証する。"""

import importlib.util
import os
from pathlib import Path
import re
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
SPEC = importlib.util.spec_from_file_location("split_functions", ROOT / "tools/split-functions.py")
SPLITTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SPLITTER)


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
        cls.source = (ROOT / "sx.m4").read_text(encoding="utf-8")
        cls.files = sorted((ROOT / "src/functions").glob("**/*.m4"))

    def test_inventory_and_order(self):
        """全関数を一度ずつ収録し、読み込み順も元の定義順を保つ。"""
        expected = SPLITTER.FUNCTION.findall(self.source)
        self.assertTrue(expected)
        self.assertEqual(len(expected), len(set(expected)))
        self.assertEqual(sorted(expected), sorted(path.stem for path in self.files))
        expanded = run(["m4", "--", "m4/common.m4", "src/functions.m4"])
        self.assertEqual(expected, SPLITTER.FUNCTION.findall(expanded.decode()))
        for path in self.files:
            with self.subTest(path=path.relative_to(ROOT)):
                self.assertEqual([path.stem], SPLITTER.FUNCTION.findall(path.read_text(encoding="utf-8")))

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
                self.assertEqual([path.stem], SPLITTER.FUNCTION.findall(before.decode()))
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
                expanded = run(["m4", "--", "m4/common.m4", f"src/functions/str/{name}.m4"])
                self.assertIn(f"__sx_{base}_{variable}_".encode(), expanded)
                self.assertNotIn(f"{name}_{variable}_".encode(), expanded)

    def test_complete_assembly(self):
        """初期化・全定数・全関数を結合すると通常ビルドとバイト単位で一致する。"""
        assembly = run(["python3", "tools/split-functions.py", "--assemble"])
        actual = compact(run(["m4", "--"], assembly))
        self.assertEqual((ROOT / "sx.sh").read_bytes(), actual)

    def test_reject_unknown_structure(self):
        """構造が変わった場合、コードを黙って欠落させず生成を止める。"""
        valid = "### sx_util_sample - 検証用\nsx_util_sample() {\n\t:\n}\n"
        cases = {
            "ヘッダ不一致": valid.replace("### sx_util_sample", "### sx_util_other"),
            "関数の重複": valid + valid,
            "ヘッダ前の処理": "unexpected=1\n" + valid,
            "関数後の処理": valid + "unexpected=1\n",
            "CLEANUP 未定義": valid.replace("\t:", "\tunset CLEANUP"),
            "名前変換なし": valid.replace("\t:", "\tQ_value=1"),
            "m4 引用未完了": "M_RENAME_Q([|dnl\n" + valid,
            "名前変換末尾不正": "M_RENAME_Q([|dnl\n" + valid + "|], invalid)dnl\n",
        }
        for name, text in cases.items():
            with self.subTest(name=name), self.assertRaises(ValueError):
                SPLITTER.split_source(SPLITTER.MARKER + text)
        with self.assertRaises(ValueError):
            SPLITTER.split_source(valid + SPLITTER.MARKER + valid.replace("sample", "other"))

    def test_nested_m4_quotes(self):
        """関数内の入れ子の引用をブロック末尾として扱わない。"""
        text = (
            "M_RENAME_QI([|dnl\n### __sx_util_sample - 検証用\n"
            "define([|CLEANUP|], [|Q_value|])dnl\n"
            "__sx_util_sample() {\n\tM_VAR_SET([|Q_value|], [|a,b|])\n\tunset CLEANUP\n}\n"
            "|], [|util_sample|])dnl\n"
        )
        files = SPLITTER.split_source(SPLITTER.MARKER + text)
        content = files[Path("src/functions/util/__sx_util_sample.m4")]
        expanded = run(["m4", "--", "m4/common.m4", "-"], content.encode())
        self.assertIn(b"__sx_util_sample_value_", expanded)
        run(["yash", "-o", "posix", "-n"], expanded)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
