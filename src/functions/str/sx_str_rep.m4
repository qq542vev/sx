M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_nat0_base __sx_str_rep __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_rep - 文字列を繰り返す
##
## 使い方:
##   sx_str_rep 結果変数名 [元文字列 [繰り返し回数]]
##
## 説明:
##   元文字列を指定された回数だけ繰り返して、結果変数に格納する。
##   繰り返し回数は、符号なし・先行する 0 のない10進整数（0 は可）とする。
##   8進・16進表記は受け付けない。回数には SX_CFG_NUM_RANGE の上限を適用しない。
##   元文字列の省略時は空文字列、繰り返し回数の省略時・空文字列時は 1 とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rep "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_str_rep "${@}"
}

popdef([|CLEANUP|])dnl
