M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_swapcase __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_swapcase - ラテン文字の大文字と小文字を反転する
##
## 使い方:
##   sx_str_swapcase 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   指定された文字列内のラテン大文字 (A-Z) を小文字 (a-z) に、
##   ラテン小文字 (a-z) を大文字 (A-Z) に変換し、
##   結果を結果変数に格納する。アルファベット以外の文字はそのまま保持される。
##   回数制限が正の値の場合は前方から、負の値の場合は後方から
##   指定された回数分だけ変換を行う。省略時は無制限。
##   空文字列以外の回数制限は先行ゼロなしの符号付き10進整数に限る。
##   元文字列の長さと回数制限に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_swapcase() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_swapcase "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_str_swapcase "${@}"
}

popdef([|CLEANUP|])dnl
