#!/usr/bin/env python3
"""大域変数の分割と、継承・初期化・更新の契約を検証する。"""

import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
SPEC = importlib.util.spec_from_file_location("split_globals", ROOT / "tools/split-globals.py")
SPLITTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SPLITTER)


def expand(*paths):
    return subprocess.run(["m4", "--", "m4/common.m4", *paths], cwd=ROOT,
                          capture_output=True, check=True).stdout


def snapshot(names):
    return "printf '%s\\0' " + " ".join('"${' + name + '}"' for name in names) + "\n"


class SplitGlobalsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = (ROOT / "sx.m4").read_text(encoding="utf-8")
        cls.configs = ["SX_CFG_" + name for name in SPLITTER.META_NAMES.findall(cls.source)[0].split()]
        cls.numbers = ["SX_SYS_NUM_" + field for field in SPLITTER.NUM_FIELDS]
        cls.names = cls.configs + ["SX_SYS_REV"] + cls.numbers
        cls.constants = expand("src/constants.m4")
        cls.library = expand("src/constants.m4", "src/globals.m4", "src/functions.m4")

    def evaluate(self, code, probe, overrides=None):
        # 呼び出し元の設定を排除し、各ケースで環境継承の有無を指定する。
        env = {key: value for key, value in os.environ.items()
               if not key.startswith(("SX_CFG_", "SX_SYS_"))}
        env.update(LC_ALL="C.UTF-8")
        env.update(overrides or {})
        result = subprocess.run(["yash", "-efu", "-o", "posix"],
                                input=code + b"\n" + probe.encode(), env=env,
                                capture_output=True, cwd=ROOT)
        self.assertEqual(0, result.returncode, result.stderr.decode())
        self.assertEqual(b"", result.stderr)
        return [value.decode() for value in result.stdout.split(b"\0")[:-1]]

    def defaults(self):
        return self.evaluate(self.constants, snapshot(
            [name.replace("SX_CFG_", "SX_CFG_META_DEF_", 1) for name in self.configs]
        ))

    def numeric_constants(self, width):
        return self.evaluate(self.constants, snapshot(
            [f"SX_NUM_I{width}_{field}" for field in SPLITTER.NUM_FIELDS]
        ))

    def test_inventory_and_initialization_order(self):
        """全単位を一度ずつ、元の式と順序のまま読み込む。"""
        files = SPLITTER.attach(SPLITTER.split_source(self.source), ROOT)
        actual = {path.relative_to(ROOT) for path in (ROOT / "src/globals").glob("**/*.m4")}
        self.assertEqual(set(files) - {Path("src/globals.m4")}, actual)
        for path, content in files.items():
            self.assertEqual(content, (ROOT / path).read_text(encoding="utf-8"))
        block = self.source.split(SPLITTER.START)[1].split(SPLITTER.END)[0]
        expected = "".join(line for line in block.splitlines(keepends=True)
                           if line.strip() and not line.startswith("#"))
        self.assertEqual(expected, expand("src/globals.m4").decode())
        for field in SPLITTER.NUM_FIELDS:
            self.assertEqual(SPLITTER.NUM_INIT[field].encode(),
                             expand(f"src/globals/sys/SX_SYS_NUM_{field}.m4"))

    def test_each_numeric_global_is_independent(self):
        """各派生値を対応する定数だけで初期化できる。"""
        for width in (32, 64, 128):
            for field in SPLITTER.NUM_FIELDS:
                with self.subTest(width=width, field=field):
                    name = f"SX_SYS_NUM_{field}"
                    code = expand(f"src/constants/num/SX_NUM_I{width}_{field}.m4",
                                  f"src/globals/sys/{name}.m4")
                    value = self.evaluate(code, snapshot([name]),
                                          {"SX_CFG_NUM_RANGE": str(width)})
                    self.assertEqual(self.numeric_constants(width)[SPLITTER.NUM_FIELDS.index(field)], value[0])

    def test_each_config_is_independent_and_mutable(self):
        """設定値の単独展開では、未設定だけを既定値で補い、空値も保持する。"""
        for name, default in zip(self.configs, self.defaults()):
            constant = name.replace("SX_CFG_", "SX_CFG_META_DEF_", 1)
            code = expand(f"src/constants/cfg/{constant}.m4", f"src/globals/cfg/{name}.m4")
            for inherited in (None, "", "引用'\" $value\\\n次行"):
                with self.subTest(name=name, inherited=inherited):
                    env = {} if inherited is None else {name: inherited}
                    probe = snapshot([name]) + name + "='changed'\n" + snapshot([name])
                    values = self.evaluate(code, probe, env)
                    self.assertEqual([default if inherited is None else inherited, "changed"], values)

    def test_default_values(self):
        values = self.evaluate(self.library, snapshot(self.names))
        defaults = self.defaults()
        self.assertEqual(defaults, values[:len(self.configs)])
        self.assertEqual("0", values[len(self.configs)])
        width = defaults[self.configs.index("SX_CFG_NUM_RANGE")]
        self.assertEqual(self.numeric_constants(width), values[-len(self.numbers):])

    def test_inherited_settings_and_reset_system_values(self):
        inherited = dict(zip(self.configs, self.defaults()))
        inherited.update(SX_CFG_NUM_RANGE="64", SX_CFG_SEP="<> ' $",
                         SX_CFG_ARR_HOLE="空白\n'\\", SX_CFG_SKIP_CHK="1", SX_SYS_REV="99")
        inherited.update({name: "stale" for name in self.numbers})
        values = self.evaluate(self.library, snapshot(self.names), inherited)
        self.assertEqual([inherited[name] for name in self.configs], values[:len(self.configs)])
        self.assertEqual("0", values[len(self.configs)])
        self.assertEqual(self.numeric_constants(64), values[-len(self.numbers):])

    def test_numeric_ranges(self):
        # 128bit の算術は行わず、設定に対応する派生元の参照だけを検査する。
        for width in (32, 64, 128):
            with self.subTest(width=width):
                values = self.evaluate(self.library, snapshot(self.numbers), {"SX_CFG_NUM_RANGE": str(width)})
                self.assertEqual(self.numeric_constants(width), values)

    def test_setting_updates_keep_revision(self):
        probe = (
            "sx_fn_anon first ':'\n"
            "sx_cfg_set NUM_RANGE=32\n"
            + snapshot(["SX_SYS_REV"] + self.numbers)
            + "sx_fn_anon second ':'\n"
            + snapshot(["first", "second", "SX_SYS_REV"])
        )
        values = self.evaluate(self.library, probe, {"SX_CFG_NUM_RANGE": "64"})
        self.assertEqual(["1"] + self.numeric_constants(32), values[:1 + len(self.numbers)])
        self.assertEqual(["sx_fn_anon_0", "sx_fn_anon_1", "2"], values[-3:])

    def test_reject_unknown_or_incomplete_initialization(self):
        config_line = next(line for line in self.source.splitlines(keepends=True)
                           if line.startswith("SX_CFG_SIG_ARR="))
        cases = {
            "定義の欠落": self.source.replace(config_line, ""),
            "定義の重複": self.source.replace(config_line, config_line * 2),
            "未対応の処理": self.source.replace(SPLITTER.END, "unexpected=1\n" + SPLITTER.END),
            "空値の上書き": self.source.replace(config_line, config_line.replace("ARR-", "ARR:-")),
            "カウンタの継承": self.source.replace("SX_SYS_REV=0\n", 'SX_SYS_REV="${SX_SYS_REV-0}"\n'),
            "初期化順の変更": self.source.replace(config_line, "").replace(SPLITTER.END, config_line + SPLITTER.END),
            "派生値の欠落": self.source.replace(SPLITTER.NUM_INIT["WLEN"], ""),
            "派生値の重複": self.source.replace(SPLITTER.NUM_INIT["WLEN"], SPLITTER.NUM_INIT["WLEN"] * 2),
            "派生値の順序変更": self.source.replace(
                SPLITTER.NUM_INIT["WLEN"] + SPLITTER.NUM_INIT["QM"],
                SPLITTER.NUM_INIT["QM"] + SPLITTER.NUM_INIT["WLEN"]),
            "範囲の重複": self.source + SPLITTER.START,
        }
        for name, source in cases.items():
            with self.subTest(name=name), self.assertRaises(ValueError):
                SPLITTER.split_source(source)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
