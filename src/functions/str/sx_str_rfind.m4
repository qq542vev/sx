dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_nat0_safe __sx_str_rfind __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_rfind - 文字列から指定された文字列を後方一致で探し、位置を取得する
##
## 使い方:
##   sx_str_rfind 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   元文字列から検索文字列をリテラル後方一致で探し、見つかったすべての位置を
##   "index:len" 形式で結果変数に格納する。複数一致する場合はスペース区切りで並べる。
##   検索文字列が空の場合は、各文字境界位置（長さ0）を末尾から順に出力する。
##   第一引数には sx_arg_find と同様のバインド形式を指定できる。
##
##   フラグに SX_STR_RFIND_GLOB (1) を指定すると、検索文字列を glob パターンとして扱う。
##   フラグに SX_STR_RFIND_OVERLAP (2) を指定すると、重なり合う一致も検出する。
##   フラグに SX_STR_RFIND_TEXT (4) を指定すると、出力が "index:len" の代わりに
##   実際にマッチした文字列になる。
##   元文字列の長さに SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  1件以上一致 (SX_EX_OK)
##    1  不一致
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rfind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rfind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_rfind "${@}" || return
}

popdef([|CLEANUP|])dnl
