#!/usr/bin/env python3
"""sx.m4 から共通マクロと定数の分割案を生成する。既存ビルドは変更しない。"""

import argparse
from pathlib import Path
import re
import subprocess
from dependency_headers import attach


ROOT = Path(__file__).resolve().parent.parent
HEADER = "dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。\n"
DECLARATION = re.compile(r"^[ \t]*readonly (SX_[A-Z0-9_]+)=(.*)$", re.MULTILINE)


def split_source(source):
    """元の定義順と引用を保持し、出力先と内容の対応を返す。"""
    constant_start = source.index("# 実行時定数\n")
    constant_end = source.index("# 大域変数の初期化\n", constant_start)
    macros = source[source.index("changequote("):constant_start]
    constants = source[constant_start:constant_end]

    # 連番マクロの値は共通ファイルで定義するが、readonly は個別に出力する。
    macros, count = re.subn(
        r"^M_CONST\(\[\|NUM_(?:QM|ZR)_\$1\|\]\)\n", "", macros, flags=re.MULTILINE
    )
    if count != 2:
        raise ValueError("QM/ZR の生成マクロの構造を確認してください。")
    value_generators = re.findall(
        r"^__sx_m4_gen_(?:qm|zr)\([^\n]*\)$", constants, re.MULTILINE
    )
    if len(value_generators) != 2:
        raise ValueError("QM/ZR の生成呼び出しを確認してください。")

    # 関数ブロック内の生成マクロも、同じ Q_* 名前変換を通して収録する。
    uri_start = source.index("define([|__sx_m4_gen_uri_enc_case|]")
    uri_end = source.index("\n\n### __sx_uri_enc", uri_start)
    uri_macro = (
        "M_RENAME_QI([|dnl\n" + source[uri_start:uri_end]
        + "\n|], [|uri_enc|])dnl\n"
    )
    common = (
        HEADER + "divert(-1)dnl\n" + macros + uri_macro + "\n"
        + "\n".join(value_generators) + "\ndivert(0)dnl\n"
    )

    expanded = subprocess.run(
        ["m4", "--"], input=source[:constant_end], text=True,
        capture_output=True, check=True,
    ).stdout
    names = [match[0] for match in DECLARATION.findall(expanded)]
    if not names or len(names) != len(set(names)):
        raise ValueError("実行時定数が空か、定数名が重複しています。")
    files = {Path("m4/common.m4"): common}
    includes = [HEADER.rstrip("\n")]
    for name in names:
        declaration = f"M_CONST([|{name[3:]}|])"
        group = name.split("_")[1].lower()
        path = Path("src/constants") / group / f"{name}.m4"
        files[path] = HEADER + declaration + "\n"
        includes.append(f"M_UNIT([|{name}|], [|{path.as_posix()}|])dnl")
    files[Path("src/constants.m4")] = "\n".join(includes) + "\n"
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="再生成せずに同期を確認する")
    args = parser.parse_args()
    files = attach(split_source((ROOT / "sx.m4").read_text()), ROOT)
    obsolete = set((ROOT / "src/constants").glob("**/*.m4")) - {
        ROOT / path for path in files
    }
    if obsolete:
        parser.exit(1, "元の定義に存在しない定数ファイルがあります:\n" + "\n".join(
            str(path.relative_to(ROOT)) for path in sorted(obsolete)
        ) + "\n")
    if args.check:
        changed = [
            str(path) for path, content in files.items()
            if not (ROOT / path).exists() or (ROOT / path).read_text() != content
        ]
        if changed:
            parser.exit(1, "再生成が必要です:\n" + "\n".join(changed) + "\n")
    else:
        for path, content in files.items():
            target = ROOT / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)
    print(f"共通マクロ1ファイル、定数{len(files) - 2}ファイル、全定数の読み込み一覧1ファイル")


if __name__ == "__main__":
    main()
