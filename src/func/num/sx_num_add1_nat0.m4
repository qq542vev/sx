M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_add1_nat0 __sx_num_is_nat0_base __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_add1_nat0 - 非負整数に1を加算する
##
## 使い方:
##   sx_num_add1_nat0 結果変数名 数値
##
## 説明:
##   符号なし10進整数に1を加算する。
##   引数の検証を行い、符号なし整数でない場合はエラーとする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

sx_num_add1_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_add1_nat0 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 "${2-}" || return M_EX_USAGE

	__sx_num_add1_nat0 "$1" "$2"
}
|], [|num_add1_nat0|])dnl
popdef([|CLEANUP|])dnl
