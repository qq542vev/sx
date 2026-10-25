#!/usr/bin/env python3
"""分割単位の依存宣言と、m4 展開後の実行時参照を照合する。"""

import argparse
from pathlib import Path
import re
import subprocess

from dependency_headers import REQUIRE, declaration, metadata


ROOT = Path(__file__).resolve().parent.parent
UNITS = sorted(path for group in ("const", "var", "func")
               for path in (ROOT / "src" / group).rglob("*.m4"))
TOKEN = re.compile(r"(?<![A-Za-z0-9_])(?:__)?sx_[a-z0-9_]+(?![A-Za-z0-9_])|(?<![A-Za-z0-9_])SX_[A-Z0-9_]+(?![A-Za-z0-9_])")
DYNAMIC_FUNCTION = re.compile(r'"(__sx_num_[a-z0-9_]+_)\$\{')
DYNAMIC_CONSTANT = re.compile(r"(?<![A-Za-z0-9_])(SX_[A-Z0-9_]*)\$\{")
CFG_CHECK = re.compile(r"M_CFG_CHECK\(\[\|([A-Za-z0-9_]+)\|\]\)")
CFG_EXEMPT = {"sx_cfg_is_valid", "sx_cfg_set"}


def config_checks(body):
    """説明コメント内の例を除いて、検査マクロの呼び出しを取り出す。"""
    return CFG_CHECK.findall(re.sub(r"(?m)^[ \t]*#.*$", "", body))


def inventory():
    owners = {}
    for path in UNITS:
        name = path.stem
        if name in owners:
            raise ValueError(f"提供名が重複しています: {name}")
        owners[name] = path
    return owners


def references(path, owners, generated=False):
    if path.parts[-3] == "const":
        # M_CONST の値は文字列データ。説明文中の関数名は呼び出しではない。
        return set()
    command = ["m4"] + ([] if generated else ["-DSX_CFG_SCAN=1"])
    result = subprocess.run(command + ["--", "m4/common.m4", str(path.relative_to(ROOT))],
                            cwd=ROOT, capture_output=True, text=True, check=True).stdout
    # ### ヘッダおよび行コメントは実行時の参照ではない。
    code = re.sub(r"(?m)^[ \t]*#.*(?:\n|$)", "", result)
    names = set(owners)
    refs = set(TOKEN.findall(code)) & names
    for prefix in DYNAMIC_FUNCTION.findall(code):
        # 呼び出し元から渡す type は arith / nat0 の二択。
        matches = {prefix + suffix for suffix in ("arith", "nat0") if prefix + suffix in names}
        if not matches:
            raise ValueError(f"動的な関数名の提供元がありません: {path}: {prefix}")
        refs.update(matches)
    for prefix in DYNAMIC_CONSTANT.findall(code):
        # 例: SX_NUM_I${...}_MAX、SX_CFG_META_DEF_${...}。
        matches = {name for name in names if name.startswith(prefix)}
        if prefix == "SX_NUM_I":
            fields = set(re.findall(r"SX_NUM_I\$\{[^{}]+\}_(WLEN|QM|ZR|MAX|MIN)", code))
            matches = {name for name in matches
                       if name.startswith(("SX_NUM_I32_", "SX_NUM_I64_", "SX_NUM_I128_"))
                       and name.rsplit("_", 1)[-1] in fields}
        elif prefix == "SX_NUM_BASE":
            fields = set(re.findall(r"SX_NUM_BASE\$\{[^{}]+\}_(PREFIX|CHARS)", code))
            matches = {name for name in matches if name.rsplit("_", 1)[-1] in fields}
        elif prefix == "SX_CFG_":
            matches = {name for name in matches if owners[name].parent == ROOT / "src/var/cfg"}
        if not matches:
            raise ValueError(f"動的な定数名の提供元がありません: {path}: {prefix}")
        refs.update(matches)
    return refs - {name for name, owner in owners.items() if owner == path}


def config_metadata(owners, report=False):
    """生成器自身から、検査の追加依存または設定への到達経路を得る。"""
    commands = []
    for name, path in sorted(owners.items()):
        if not config_checks(path.read_text(encoding="utf-8")):
            continue
        if report:
            commands.append(f"M_CFG_REPORT([|{name}|])dnl\n")
        else:
            commands.append(f"[|CFGDEPS\t{name}\t|]M_CFG_DEPS([|{name}|])\n")
    result = subprocess.run(["m4", "--", "m4/common.m4", "-"], input="".join(commands),
                            cwd=ROOT, capture_output=True, text=True, check=True).stdout
    if report:
        return result
    return {name: set(deps.split()) for tag, name, deps in
            (line.split("\t", 2) for line in result.splitlines() if line.startswith("CFGDEPS\t"))}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="参照から依存宣言を更新する")
    parser.add_argument("--report-config", action="store_true", help="公開関数・要求設定・到達経路を出力する")
    args = parser.parse_args()
    owners = inventory()
    if args.report_config:
        print(config_metadata(owners, report=True), end="")
        return
    failures = []
    for path in UNITS:
        expected = references(path, owners)
        body = path.read_text(encoding="utf-8")
        checks = config_checks(body)
        wanted = [path.stem] if path.stem.startswith("sx_") and path.stem not in CFG_EXEMPT else []
        if checks != wanted:
            parser.exit(1, f"設定検査マクロの配置が不正です: {path.relative_to(ROOT)}: {checks}\n")
        if not args.write:
            metadata(path, path.stem)
        actual = set(REQUIRE.findall(body)[0].split()) if len(REQUIRE.findall(body)) == 1 else set()
        if args.write:
            header = declaration(sorted(expected))
            body = REQUIRE.sub("", body)
            first_line = body.index("\n") + 1 if body.startswith("#!") else 0
            path.write_text(body[:first_line] + header + body[first_line:], encoding="utf-8")
        elif actual != expected or len(REQUIRE.findall(body)) != 1:
            failures.append((path.relative_to(ROOT), sorted(expected - actual), sorted(actual - expected)))
    if failures:
        for path, missing, extra in failures:
            print(f"{path}: 不足={missing} 過剰={extra}")
        parser.exit(1, f"依存宣言の不一致: {len(failures)} ファイル\n")
    for name, generated in config_metadata(owners).items():
        path = owners[name]
        explicit = set(REQUIRE.findall(path.read_text(encoding="utf-8"))[0].split())
        expected = explicit | generated
        actual = references(path, owners, generated=True)
        if expected != actual:
            parser.exit(1, f"生成依存の不一致: {path.relative_to(ROOT)}: "
                        f"不足={sorted(actual - expected)} 過剰={sorted(expected - actual)}\n")
    print(f"依存宣言を照合しました: {len(UNITS)} ファイル")


if __name__ == "__main__":
    main()
