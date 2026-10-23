#!/usr/bin/env python3
"""各テストの読み込み宣言と読み込み先の選択を検証する。"""

import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("build_spec_modules", ROOT / "tools/build-spec-modules.py")
BUILDER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BUILDER)


class SpecModulesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sx spec modules ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ("sx_uri_enc", "sx_uri_is_pct"):
            self.write(f"src/functions/uri/{name}.m4", "")

    def write(self, relative, body):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8")
        return path

    def test_specs_keep_separate_requirements_and_selection(self):
        self.write("spec/uri/enc_spec.sh", "Include ./spec/support/library.sh sx_uri_enc\n")
        self.write("spec/uri/pct_spec.sh", "Include ./build/modules/sx_uri_is_pct.sh\n")
        self.write("spec/other_spec.sh", "Include ./spec/support/library.sh sx_uri_is_pct\n")
        plans = BUILDER.plans(self.root)
        self.assertEqual({"build/modules/sx_uri_enc.sh": ["sx_uri_enc"],
                          "build/modules/sx_uri_is_pct.sh": ["sx_uri_is_pct"]}, plans)
        self.assertEqual(2, len(BUILDER.plans(self.root, ["spec/uri"])))
        self.assertEqual(1, len(BUILDER.plans(self.root, ["spec/uri/enc_spec.sh"])))

    def test_invalid_declarations_are_rejected(self):
        cases = (
            "Include ./sx.sh\n",
            "Include ./spec/support/library.sh\n",
            "Include ./spec/support/library.sh unknown\n",
            "Include ./build/modules/unknown.sh\n",
            "Include ./spec/support/library.sh sx_uri_enc sx_uri_is_pct\n",
            "Include ./spec/support/library.sh spec/uri/other_spec.sh sx_uri_enc\n",
            "Include ./spec/support/library.sh spec/uri/enc_spec.sh\n",
            "Include ./spec/support/library.sh spec/uri/enc_spec.sh sx_uri_enc\n",
        )
        for body in cases:
            with self.subTest(body=body):
                self.write("spec/uri/enc_spec.sh", body)
                with self.assertRaises(ValueError):
                    BUILDER.plans(self.root)

    def test_multiple_groups_deduplicate_names_without_combining_modules(self):
        self.write("spec/uri/enc_spec.sh", "Include ./spec/support/library.sh sx_uri_enc\nInclude ./spec/support/library.sh sx_uri_is_pct\nInclude ./spec/support/library.sh sx_uri_enc\n")
        self.assertEqual({"build/modules/sx_uri_enc.sh": ["sx_uri_enc"],
                          "build/modules/sx_uri_is_pct.sh": ["sx_uri_is_pct"]},
                         BUILDER.plans(self.root))

    def test_loader_uses_single_module_without_full_library(self):
        support = self.write("spec/support/library.sh", "")
        shutil.copyfile(ROOT / "spec/support/library.sh", support)
        self.write("build/modules/sx_uri_enc.sh", "marker=module\n")
        probe = "set -- sx_uri_enc\n. ./spec/support/library.sh\nprintf '%s\\n' \"$marker\"\n"
        env = {key: value for key, value in os.environ.items() if key != "SX_TEST_MODE"}
        for mode in (None, "module", "full"):
            with self.subTest(mode=mode):
                if mode == "full":
                    self.write("sx.sh", "marker=full\n")
                selected_env = env if mode is None else dict(env, SX_TEST_MODE=mode)
                result = subprocess.run(["yash", "-efu", "-o", "posix", "-c", probe],
                                        cwd=self.root, env=selected_env, capture_output=True, text=True)
                self.assertEqual(0, result.returncode, result.stderr)
                self.assertEqual("full\n" if mode == "full" else "module\n", result.stdout)

    def test_loader_rejects_invalid_and_old_declarations_in_both_modes(self):
        support = self.write("spec/support/library.sh", "")
        shutil.copyfile(ROOT / "spec/support/library.sh", support)
        self.write("sx.sh", "marker=full\n")
        for mode in ("module", "full"):
            for args in ([], [""], ["1invalid"], ["../outside"],
                         ["spec/uri/enc_spec.sh"],
                         ["spec/uri/enc_spec.sh", "sx_uri_enc"],
                         ["sx_uri_enc", "sx_uri_is_pct"]):
                with self.subTest(mode=mode, args=args):
                    result = subprocess.run(
                        ["yash", "-efu", "-o", "posix", "-c",
                         '. ./spec/support/library.sh', "probe", *args],
                        cwd=self.root, env=dict(os.environ, SX_TEST_MODE=mode),
                        capture_output=True, text=True)
                    self.assertNotEqual(0, result.returncode)
                    self.assertIn("提供名", result.stderr)


if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout))
