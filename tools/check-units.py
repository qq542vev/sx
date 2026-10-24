#!/usr/bin/env python3
"""分割単位と一覧の対応を検査する。"""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parent.parent
GROUPS = ("const", "var", "func")
UNIT = re.compile(r"M_UNIT\(\[\|([A-Za-z_][A-Za-z0-9_]*)\|\], \[\|(src/(?:const|var|func)/[A-Za-z0-9_/]+\.m4)\|\]\)dnl")


def check(root=ROOT):
    names = set()
    paths = set()
    for group in GROUPS:
        manifest = root / "src" / f"{group}.m4"
        entries = []
        for number, line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
            if not line or line.startswith("dnl "):
                continue
            match = UNIT.fullmatch(line)
            if match is None:
                raise ValueError(f"一覧の書式が不正です: {manifest}:{number}")
            name, relative = match.groups()
            path = Path(relative)
            if path.parts[1] != group or path.stem != name:
                raise ValueError(f"名前とパスが一致しません: {manifest}:{number}")
            if name in names or path in paths:
                raise ValueError(f"単位が重複しています: {name}")
            names.add(name)
            paths.add(path)
            entries.append(path)
        actual = {path.relative_to(root) for path in (root / "src" / group).rglob("*.m4")}
        missing = set(entries) - actual
        unlisted = actual - set(entries)
        if missing or unlisted:
            raise ValueError(f"一覧と実ファイルが一致しません: {group}: 欠落={sorted(missing)} 未登録={sorted(unlisted)}")
    return len(names)


if __name__ == "__main__":
    print(f"一覧と実ファイルを照合しました: {check()} 単位")
