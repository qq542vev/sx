#!/usr/bin/env python3
"""テストの Include に明示した名前から、テスト用モジュールを生成する。"""

import argparse
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parent.parent
INCLUDE = re.compile(r"^\s*Include \./spec/support/library\.sh ([^\n]+)$", re.MULTILINE)
DIRECT_MODULE = re.compile(r"^\s*Include \./build/modules/([A-Za-z_][A-Za-z0-9_]*)\.sh\s*$", re.MULTILINE)
FULL_INCLUDE = re.compile(r"^\s*Include \./(?:sx\.sh|sx\.m4)\s*$", re.MULTILINE)


def plans(root=ROOT, selected=()):
    known = {path.stem for group in ("constants", "globals", "functions")
             for path in (root / "src" / group).rglob("*.m4")}
    files = set()
    for item in selected or ("spec",):
        path = (root / item).resolve()
        if not path.exists() or root.resolve() not in path.parents:
            raise ValueError(f"テストのパスが不正です: {item}")
        if path.is_dir():
            files.update(path.rglob("*_spec.sh"))
        elif path.name.endswith("_spec.sh"):
            files.add(path)
        else:
            raise ValueError(f"テストファイルではありません: {item}")
    result = {}
    for path in sorted(files):
        body = path.read_text(encoding="utf-8")
        relative = path.relative_to(root).as_posix()
        if FULL_INCLUDE.search(body):
            raise ValueError(f"全体版を直接読み込んでいます: {relative}")
        entries = [(f"build/modules/{name}.sh", [name]) for name in DIRECT_MODULE.findall(body)]
        for value in INCLUDE.findall(body):
            args = value.split()
            if args[0].startswith("spec/"):
                if args[0] != relative or len(args) < 2:
                    raise ValueError(f"テスト用モジュールの指定が不正です: {relative}")
                output = "build/spec-modules/" + relative[len("spec/"):]
                symbols = args[1:]
            elif len(args) == 1:
                output = f"build/modules/{args[0]}.sh"
                symbols = args
            else:
                raise ValueError(f"Include の書式が不正です: {relative}")
            if len(symbols) != len(set(symbols)):
                raise ValueError(f"依存名が重複しています: {relative}")
            entries.append((output, symbols))
        for output, symbols in entries:
            unknown = set(symbols) - known
            if unknown:
                raise ValueError(f"未定義の依存名: {relative}: {sorted(unknown)}")
            result.setdefault(output, set()).update(symbols)
    return {output: sorted(symbols) for output, symbols in sorted(result.items())}


def build(item):
    output, symbols = item
    result = subprocess.run(["make", "bundle", f"SX_SYMBOLS={' '.join(symbols)}", f"SX_OUT={output}"],
                            cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"生成に失敗しました: {output}\n{result.stdout}{result.stderr}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="読み込み宣言だけを検査する")
    parser.add_argument("specs", nargs="*", help="対象のテストファイルまたはディレクトリ")
    args = parser.parse_args()
    try:
        selection = args.specs or os.environ.get("SX_SPECS", "").split()
        modules = plans(selected=selection)
        if not args.check:
            # 出力先ごとに一度だけ生成する。依存解決は既存の m4 生成器が担当する。
            with ThreadPoolExecutor(max_workers=4) as pool:
                list(pool.map(build, modules.items()))
        print(f"テスト用モジュールを{'照合' if args.check else '生成'}しました: {len(modules)} ファイル")
    except (OSError, ValueError, RuntimeError) as error:
        parser.exit(1, str(error) + "\n")


if __name__ == "__main__":
    main()
