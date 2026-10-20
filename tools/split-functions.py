#!/usr/bin/env python3
"""sx.m4 から関数ごとの分割案を生成する。既存ビルドは変更しない。"""

import argparse
from pathlib import Path
import re
import sys
from dependency_headers import attach


ROOT = Path(__file__).resolve().parent.parent
HEADER = "dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。\n"
MARKER = "# 関数定義\n"
FUNCTION = re.compile(r"^((?:__)?sx_[A-Za-z0-9_]+)\(\) \{\n", re.MULTILINE)
DOC = re.compile(r"^### ((?:__)?sx_[A-Za-z0-9_]+) - [^\n]*\n", re.MULTILINE)
SCOPE = re.compile(r"^(M_RENAME_QI?)\(\[\|dnl\n", re.MULTILINE)
SCOPE_END = re.compile(r", \[\|([A-Za-z0-9_]+)\|\]\)dnl\n")
CLEANUP = re.compile(r"^define\(\[\|CLEANUP\|\], \[\|[^\n]*\|\]\)dnl\n", re.MULTILINE)
TRIVIA = re.compile(r"(?:[ \t]*\n|#[^\n]*(?:\n|$))*\Z")


def quote_end(text, start):
    """入れ子の m4 引用を数え、開始位置の [| に対応する |] の直後を返す。"""
    depth = 0
    for token in re.finditer(r"\[\||\|\]", text[start:]):
        depth += 1 if token[0] == "[|" else -1
        if depth == 0:
            return start + token.end()
    raise ValueError("閉じられていない m4 引用があります。")


def function_chunks(text, scope=None):
    """関数ヘッダを境界とし、既知の構造だけを受理する。シェルの括弧では分割しない。"""
    if scope == ("M_RENAME_QI", "uri_enc"):
        # この生成マクロは common.m4 に、同じ名前変換を通して収録済み。
        start = text.index("define([|__sx_m4_gen_uri_enc_case|]")
        end = text.index("\n\n### __sx_uri_enc", start)
        text = text[:start] + text[end:]
        text, count = re.subn(
            r"^undefine\(\[\|__sx_m4_gen_uri_enc_case\|\]\)dnl\n", "", text,
            flags=re.MULTILINE,
        )
        if count != 1:
            raise ValueError("URI 生成マクロの構造を確認してください。")

    docs = list(DOC.finditer(text))
    prefix = text[:docs[0].start()] if docs else text
    if not TRIVIA.fullmatch(prefix):
        raise ValueError("関数ヘッダの前に未対応のコードがあります: " + prefix[:120])
    for index, doc in enumerate(docs):
        chunk = text[doc.start():docs[index + 1].start() if index + 1 < len(docs) else len(text)]
        functions = list(FUNCTION.finditer(chunk))
        if len(functions) != 1 or functions[0][1] != doc[1]:
            raise ValueError("関数ヘッダと定義が一対一で対応していません: " + doc[1])
        function = functions[0]
        preamble = chunk[:function.start()]
        cleanups = list(CLEANUP.finditer(preamble))
        if len(cleanups) > 1 or not TRIVIA.fullmatch(CLEANUP.sub("", preamble)):
            raise ValueError("関数の前処理に未対応のコードがあります: " + doc[1])
        # 閉じ括弧の後にはコメントと空行だけを許す。未知の処理は捨てずに拒否する。
        if not re.search(r"^}\n(?=(?:[ \t]*\n|#[^\n]*(?:\n|$))*\Z)", chunk, re.MULTILINE):
            raise ValueError("関数末尾の構造を確認してください: " + doc[1])
        body = chunk[function.start():]
        if re.search(r"\bCLEANUP\b", body) and not cleanups:
            raise ValueError("CLEANUP の定義が関数内で完結していません: " + doc[1])
        if scope is None and re.search(r"\bQ_[A-Za-z0-9_]+", body):
            raise ValueError("Q_* の名前変換がありません: " + doc[1])
        yield doc[1], chunk, scope


def split_source(source):
    """m4 の引用を保ったまま名前変換ブロックを解き、関数別の内容を返す。"""
    text = source[source.index(MARKER) + len(MARKER):]
    chunks = []
    cursor = 0
    while True:
        match = SCOPE.search(text, cursor)
        if not match:
            chunks.extend(function_chunks(text[cursor:]))
            break
        chunks.extend(function_chunks(text[cursor:match.start()]))
        end = quote_end(text, match.start() + len(match[1]) + 1)
        suffix = SCOPE_END.match(text, end)
        if not suffix:
            raise ValueError("名前変換ブロック末尾の構造を確認してください。")
        scope = match[1], suffix[1]
        chunks.extend(function_chunks(text[match.end():end - 2], scope))
        cursor = suffix.end()

    names = [name for name, _, _ in chunks]
    if not names or len(names) != len(set(names)) or names != FUNCTION.findall(source):
        raise ValueError("関数の欠落・重複、または未対応の定義形式があります。")
    files = {}
    includes = [HEADER.rstrip("\n")]
    for name, chunk, scope in chunks:
        group = name.lstrip("_").split("_")[1]
        path = Path("src/functions") / group / f"{name}.m4"
        # define は pushdef で追加した層だけを更新する。呼び出し元の定義は popdef で戻る。
        content = HEADER + "pushdef([|CLEANUP|])dnl\n"
        if scope:
            content += f"{scope[0]}([|dnl\n{chunk}|], [|{scope[1]}|])dnl\n"
        else:
            content += chunk
        files[path] = content + "popdef([|CLEANUP|])dnl\n"
        includes.append(f"M_UNIT([|{name}|], [|{path.as_posix()}|])dnl")
    files[Path("src/functions.m4")] = "\n".join(includes) + "\n"
    return files


def assembly_source(source):
    """分割した定数・大域変数・関数を使う比較用の m4 入力を返す。"""
    return (
        source[:source.index("changequote(")]
        + "include(`m4/common.m4')dnl\n"
        + "include([|src/constants.m4|])dnl\n"
        + "include([|src/globals.m4|])dnl\n"
        + "include([|src/functions.m4|])dnl\n"
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="再生成せずに同期を確認する")
    mode.add_argument("--assemble", action="store_true", help="比較用の全体 m4 入力を標準出力に出す")
    args = parser.parse_args()
    source = (ROOT / "sx.m4").read_text(encoding="utf-8")
    try:
        files = attach(split_source(source), ROOT)
    except ValueError as error:
        parser.exit(1, str(error) + "\n")
    if args.assemble:
        sys.stdout.write(assembly_source(source))
        return
    obsolete = set((ROOT / "src/functions").glob("**/*.m4")) - {
        ROOT / path for path in files
    }
    if obsolete:
        parser.exit(1, "元の定義に存在しない関数ファイルがあります:\n" + "\n".join(
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
    print(f"関数{len(files) - 1}ファイル、全関数の読み込み一覧1ファイル")


if __name__ == "__main__":
    main()
