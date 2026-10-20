#!/usr/bin/env python3
"""単位一覧の欠落と重複を検証する。"""

import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("check_units", ROOT / "tools/check-units.py")
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)


class UnitsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sx-units-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for group in CHECKER.GROUPS:
            (self.root / "src" / group).mkdir(parents=True)
            (self.root / "src" / f"{group}.m4").write_text("", encoding="utf-8")

    def test_missing_and_unlisted_file(self):
        manifest = self.root / "src/constants.m4"
        line = "M_UNIT([|SX_STR_SAMPLE|], [|src/constants/SX_STR_SAMPLE.m4|])dnl\n"
        manifest.write_text(line, encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "欠落"):
            CHECKER.check(self.root)
        (self.root / "src/constants/SX_STR_SAMPLE.m4").write_text("", encoding="utf-8")
        self.assertEqual(1, CHECKER.check(self.root))
        manifest.write_text("", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "未登録"):
            CHECKER.check(self.root)

    def test_duplicate_and_wrong_path(self):
        manifest = self.root / "src/constants.m4"
        line = "M_UNIT([|SX_STR_SAMPLE|], [|src/constants/SX_STR_SAMPLE.m4|])dnl\n"
        (self.root / "src/constants/SX_STR_SAMPLE.m4").write_text("", encoding="utf-8")
        manifest.write_text(line * 2, encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "重複"):
            CHECKER.check(self.root)
        manifest.write_text(line.replace("SX_STR_SAMPLE.m4", "SX_STR_OTHER.m4"), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "名前とパス"):
            CHECKER.check(self.root)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
