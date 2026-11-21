M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_nat0_safe __sx_str_find __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_find - 文字列から指定された文字列を前方一致で探し、位置を取得する
##
## 使い方:
##   sx_str_find 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   元文字列から検索文字列をリテラル前方一致で探し、見つかったすべての位置を
##   "index:len" 形式で結果変数に格納する。複数一致する場合はスペース区切りで並べる。
##   検索文字列が空の場合は、各文字境界位置（長さ0）を出力する。
##   第一引数には sx_arg_find と同様のバインド形式を指定できる。
##   例: res（全件）、3res:（最大3件）、a:b（分配）
##
##   フラグに SX_STR_FIND_GLOB (1) を指定すると、検索文字列を glob パターンとして扱う。
##   例: "hello world" から "w*" を検索すると "6:1" を返す。
##   例: "abc" から "?b" を検索すると "0:2" を返す。
##   グロブモードでは一致長にマッチした文字列（最短一致）の長さを使用する。
##
##   フラグに SX_STR_FIND_OVERLAP (2) を指定すると、重なり合う一致も検出する。
##   例: "aaa" から "aa" を重複検索すると "0:2 1:2" を返す。
##
##   出力形式は SX_STR_FIND_POS (8) / SX_STR_FIND_LEN (16) /
##   SX_STR_FIND_TEXT (4) で指定する。指定されたフィールドだけを
##   POS:LEN:TEXT の固定順で ':' 連結する。指定順は結果に影響しない。
##   出力形式フラグを1つも指定しない場合は POS|LEN とみなし、
##   従来どおり "index:len" を返す。
##   例: POS|TEXT なら "pos:text"、LEN|POS なら "pos:len"、
##   POS|LEN|TEXT なら "pos:len:text"。TEXT 単独はマッチ文字列のみ。
##   空マッチで TEXT フィールドが空文字になっても区切り ':' は残す。
##   分配モード（a:b）と併用するのが安全。
##   注意: 全件モード（res）ではマッチテキストにスペースが含まれると
##   パースが曖昧になるため、分配モードの使用を推奨する。
##
## 出力形式:
##   index:len      — 既定（POS|LEN）。"位置(0-based):一致長"
##   選択フィールド — POS / LEN / TEXT の指定に応じた ':' 連結
##   空文字列       — 一致なし（終了ステータス 1）
##   元文字列の長さに SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  1件以上一致 (SX_EX_OK)
##    1  不一致
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_str_find() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_find "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_str_find|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_find "${@}" || return
}

popdef([|CLEANUP|])dnl
