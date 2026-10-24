#!/usr/bin/env python3
"""大域変数の継承・初期化・更新の契約を検証する。"""

import os
from pathlib import Path
import re
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
NUM_FIELDS = ("WLEN", "QM", "ZR", "MAX", "MIN")
UNIT = re.compile(r"^M_UNIT\(\[\|([^|]+)\|\], \[\|([^|]+)\|\]\)dnl$", re.MULTILINE)


def expand(*paths):
    return subprocess.run(["m4", "--", "m4/common.m4", *paths], cwd=ROOT,
                          capture_output=True, check=True).stdout


def snapshot(names):
    return "printf '%s\\0' " + " ".join('"${' + name + '}"' for name in names) + "\n"


class SplitGlobalsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        manifest = (ROOT / "src/var.m4").read_text(encoding="utf-8")
        cls.entries = UNIT.findall(manifest)
        cls.configs = [name for name, _ in cls.entries if name.startswith("SX_CFG_")]
        cls.numbers = ["SX_SYS_NUM_" + field for field in NUM_FIELDS]
        cls.names = cls.configs + ["SX_SYS_REV"] + cls.numbers
        cls.constants = expand("src/const.m4")
        cls.library = expand("src/const.m4", "src/var.m4", "src/func.m4")

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
            [f"SX_NUM_I{width}_{field}" for field in NUM_FIELDS]
        ))

    def test_inventory_and_initialization_order(self):
        """一覧の順序で各初期化ファイルを一度ずつ読み込む。"""
        actual = {path.relative_to(ROOT).as_posix() for path in (ROOT / "src/var").rglob("*.m4")}
        self.assertEqual({path for _, path in self.entries}, actual)
        self.assertEqual(len(self.entries), len(actual))
        self.assertEqual(expand(*(path for _, path in self.entries)), expand("src/var.m4"))

    def test_each_numeric_global_is_independent(self):
        """各派生値を対応する定数だけで初期化できる。"""
        for width in (32, 64, 128):
            for field in NUM_FIELDS:
                with self.subTest(width=width, field=field):
                    name = f"SX_SYS_NUM_{field}"
                    code = expand(f"src/const/num/SX_NUM_I{width}_{field}.m4",
                                  f"src/var/sys/{name}.m4")
                    value = self.evaluate(code, snapshot([name]),
                                          {"SX_CFG_NUM_RANGE": str(width)})
                    self.assertEqual(self.numeric_constants(width)[NUM_FIELDS.index(field)], value[0])

    def test_each_config_is_independent_and_mutable(self):
        """設定値の単独展開では、未設定だけを既定値で補い、空値も保持する。"""
        for name, default in zip(self.configs, self.defaults()):
            constant = name.replace("SX_CFG_", "SX_CFG_META_DEF_", 1)
            code = expand(f"src/const/cfg/{constant}.m4", f"src/var/cfg/{name}.m4")
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

if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
