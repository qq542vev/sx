"""分割ファイル内で管理する依存宣言を再生成時にも保持する。"""

from pathlib import Path
import re


REQUIRE = re.compile(r"^M_REQUIRE\(\[\|([A-Za-z0-9_ ]*)\|\]\)dnl\n", re.MULTILINE)
SYMBOL = re.compile(r"(?:__)?sx_[a-z0-9_]+|SX_[A-Z0-9_]+")


def declaration(dependencies=()):
    """単位の宣言を一行ずつ返す。"""
    return "M_REQUIRE([|" + " ".join(dependencies) + "|])dnl\n"


def metadata(path, unit_name):
    """既存ファイルからメタ情報を取得し、構文と基本的な整合性を検査する。"""
    if not path.exists():
        return declaration()
    content = path.read_text(encoding="utf-8")
    requires = REQUIRE.findall(content)
    if len(requires) != 1 or "M_PROVIDES(" in content:
        raise ValueError(f"依存宣言の個数が不正です: {path}")
    dependencies = requires[0].split()
    if (len(dependencies) != len(set(dependencies))
            or any(not SYMBOL.fullmatch(name) for name in dependencies)
            or unit_name in dependencies):
        raise ValueError(f"依存名が不正です: {path}")
    return REQUIRE.search(content)[0]


def attach(files, root=Path(".")):
    """本体の再生成結果に、各ファイルが所有する依存宣言を挿入する。"""
    result = {}
    for path, body in files.items():
        if len(path.parts) < 3 or path.parts[1] not in ("const", "var", "func"):
            result[path] = body
            continue
        header_end = body.index("\n") + 1
        result[path] = (
            body[:header_end] + metadata(root / path, path.stem) + body[header_end:]
        )
    return result
