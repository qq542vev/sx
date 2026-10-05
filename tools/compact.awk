# m4 展開後の sx を圧縮する。文字列・展開内の改行と空白は保持する。
# 汎用 sh パーサーではなく、sx.m4 の構文を対象とする（ヒアドキュメント非対応）。

function flush() {
    if (pending != "") print pending
    pending = ""
    pending_kind = ""
}

# 引用符と展開の入れ子を追跡する。継続行を通常のコードと誤認しない。
function scan(line,    i, c, mode, pair) {
    continued = 0
    for (i = 1; i <= length(line); i++) {
        c = substr(line, i, 1)
        mode = stack[depth]
        pair = substr(line, i, 2)
        if (mode == "'") {
            if (c == "'") depth--
        } else if (c == "\\") {
            if (i == length(line)) continued = 1
            i++
        } else if (mode == "$'") {
            if (c == "'") depth--
        } else if (pair == "${") {
            stack[++depth] = "}"
            i++
        } else if (pair == "$(") {
            stack[++depth] = ")"
            i++
        } else if (mode == "\"") {
            if (c == "\"") depth--
        } else if (c == "\"" || c == "'") {
            stack[++depth] = (c == "'" && i > 1 && substr(line, i - 1, 1) == "$") ? "$'" : c
        } else if (mode == "}" && c == "}") {
            depth--
        } else if (mode == ")" && c == "(") {
            stack[++depth] = ")"
        } else if (mode == ")" && c == ")") {
            depth--
        } else if (depth == 0 && c == "#" && (i == 1 || substr(line, i - 1, 1) ~ /[[:space:];|&()]/)) {
            break
        }
    }
}

# 単独の代入のみ結合する。コマンド・算術展開、終了ステータス、
# エスケープや入れ子の引用を含む行は、そのまま出力する。
function assignment(line) {
    return line ~ /^[A-Za-z_][A-Za-z_0-9]*=([-+./A-Za-z_0-9]*|'[^']*'|"[^"`\\]*")$/ &&
        line !~ /\$\(|\$\{?\?/
}

# readonly の引数は宣言の実行前に展開されるため、リテラル値だけを結合する。
# 単一引用符と $'...' 内のドル記号は変数参照ではない。
function literal_assignment(line) {
    return line ~ /^[A-Za-z_][A-Za-z_0-9]*=([-+./A-Za-z_0-9]*|'[^']*'|"[^"$`\\]*"|\$'([^'\\]|\\.)*')$/
}

NR == 1 && /^#!/ { print; next }

{
    protected = depth != 0 || continued
    if (!protected) {
        if ($0 ~ /^[[:space:]]*(#.*)?$/) next
        sub(/^[[:space:]]*/, "")
    }
    scan($0)
    kind = ""
    operand = $0
    if (sub(/^readonly[[:space:]]+/, "", operand)) {
        if (literal_assignment(operand)) kind = "readonly"
    } else if (assignment(operand)) {
        kind = "assignment"
    }
    # &&、||、パイプ、否定の次の行は独立した代入と結合しない。
    if (!protected && !guarded && depth == 0 && !continued && kind != "") {
        if (pending_kind != kind) flush()
        # 途中の空代入は明示的に引用し、ShellCheck SC1007 の曖昧さを避ける。
        sub(/=$/, "=''", pending)
        pending = pending (pending == "" ? (kind == "readonly" ? "readonly " : "") : " ") operand
        pending_kind = kind
    } else {
        flush()
        print
    }
    guarded = $0 ~ /(&&|\|\||\||!)[[:space:]]*$/
}

END { flush() }
