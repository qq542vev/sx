M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_rot __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_rot - 文字セット内で文字をシフトして変換する
##
## 使い方:
##   sx_str_rot 結果変数名 [元文字列 [文字セット [シフト量]]]
##
## 説明:
##   指定された文字セット内で各文字をシフト量だけ移動させる暗号変換を行う。
##   デフォルトは ROT13（SX_STR_ALPHA を13シフト）。
##   シフト量が正の場合は前方に、負の場合は後方に移動する。
##   空文字列以外のシフト量は先行ゼロなしの符号付き10進整数に限る。
##   シフト量が省略された場合または空文字列の場合は 13 とする。
##   元文字列長・文字セット長・シフト量に SX_CFG_NUM_RANGE による上限は設けない。
##   文字セットに含まれない文字はそのまま保持される。
##
##   使用例:
##     sx_str_rot res "HELLO"              # → URYYB (ROT13)
##     sx_str_rot res "ABC" SX_STR_UPPER 3 # → DEF (Caesar)
##     sx_str_rot res "999" SX_STR_DIGIT 1 # → 000 (数字シフト)
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_str_rot() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rot "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_str_rot|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_rot "${@}"
}

popdef([|CLEANUP|])dnl
