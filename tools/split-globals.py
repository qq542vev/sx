#!/usr/bin/env python3
"""sx.m4 から大域変数の初期化を分割生成する。既存ビルドは変更しない。"""

import argparse
from pathlib import Path
import re
from dependency_headers import attach


ROOT = Path(__file__).resolve().parent.parent
HEADER = "dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。\n"
START = "# 大域変数の初期化\n"
END = "# 大域変数の初期化ここまで\n"
CFG = re.compile(r'SX_CFG_([A-Z][A-Z0-9_]*)="\$\{SX_CFG_\1-\$\{SX_CFG_META_DEF_\1\}\}"\n')
META_NAMES = re.compile(r'^define\(\[\|M_CFG_META_NAMES\|\], \[\|([A-Z0-9_ ]+)\|\]\)dnl$', re.MULTILINE)
NUM_FIELDS = ("WLEN", "QM", "ZR", "MAX", "MIN")
NUM_INIT = {
    field: f'eval SX_SYS_NUM_{field}="\\${{SX_NUM_I${{SX_CFG_NUM_RANGE}}_{field}}}"\n'
    for field in NUM_FIELDS
}
NUM_FIELD_BY_LINE = {line: field for field, line in NUM_INIT.items()}


def split_source(source):
    """既知の初期化だけを受理し、各変数の宣言順と式を保持する。"""
    if source.count(START) != 1 or source.count(END) != 1:
        raise ValueError("大域変数の初期化範囲を一意に指定してください。")
    start = source.index(START) + len(START)
    end = source.index(END)
    if end < start:
        raise ValueError("大域変数の初期化範囲の順序が不正です。")
    metadata = META_NAMES.findall(source)
    if len(metadata) != 1:
        raise ValueError("M_CFG_META_NAMES の定義を確認してください。")
    names = metadata[0].split()
    if not names or len(names) != len(set(names)):
        raise ValueError("M_CFG_META_NAMES が空か、設定名が重複しています。")

    files = {}
    paths = []
    for line in source[start:end].splitlines(keepends=True):
        if not line.strip() or line.startswith("#"):
            continue
        config = CFG.fullmatch(line)
        if config:
            path = Path("src/globals/cfg") / f"SX_CFG_{config[1]}.m4"
        elif line == "SX_SYS_REV=0\n":
            path = Path("src/globals/sys/SX_SYS_REV.m4")
        elif line in NUM_FIELD_BY_LINE:
            path = Path("src/globals/sys") / f"SX_SYS_NUM_{NUM_FIELD_BY_LINE[line]}.m4"
        else:
            raise ValueError("未対応の大域変数初期化があります: " + line.rstrip())
        if path in files:
            raise ValueError("大域変数の初期化が重複しています: " + str(path))
        files[path] = HEADER + line
        paths.append(path)

    expected = [Path("src/globals/cfg") / f"SX_CFG_{name}.m4" for name in names]
    expected += [Path("src/globals/sys/SX_SYS_REV.m4")]
    expected += [Path("src/globals/sys") / f"SX_SYS_NUM_{field}.m4" for field in NUM_FIELDS]
    if paths != expected:
        raise ValueError("大域変数初期化の欠落、または定義順の変更を確認してください。")
    files[Path("src/globals.m4")] = HEADER + "".join(
        f"M_UNIT([|{path.stem}|], [|{path.as_posix()}|])dnl\n" for path in paths
    )
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="再生成せずに同期を確認する")
    args = parser.parse_args()
    try:
        files = attach(split_source((ROOT / "sx.m4").read_text(encoding="utf-8")), ROOT)
    except ValueError as error:
        parser.exit(1, str(error) + "\n")
    obsolete = set((ROOT / "src/globals").glob("**/*.m4")) - {
        ROOT / path for path in files
    }
    if obsolete:
        parser.exit(1, "元の定義に存在しない大域変数ファイルがあります:\n" + "\n".join(
            str(path.relative_to(ROOT)) for path in sorted(obsolete)
        ) + "\n")
    if args.check:
        changed = [
            str(path) for path, content in files.items()
            if not (ROOT / path).exists() or (ROOT / path).read_text(encoding="utf-8") != content
        ]
        if changed:
            parser.exit(1, "再生成が必要です:\n" + "\n".join(changed) + "\n")
    else:
        for path, content in files.items():
            target = ROOT / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content, encoding="utf-8")
    print(f"大域変数初期化{len(files) - 1}ファイル、全大域変数の読み込み一覧1ファイル")


if __name__ == "__main__":
    main()
