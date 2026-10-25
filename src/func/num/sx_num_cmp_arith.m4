M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_cmp_arith __sx_num_is_int_safe|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_cmp_arith - 2つの数値を算術展開で比較する
##
## 使い方:
##   sx_num_cmp_arith 数値1 数値2
##
## 説明:
##   設定された数値範囲内の整数を比較する。最小値も受理する。
##
## 終了ステータス:
##   1  数値1 < 数値2
##   2  数値1 = 数値2
##   3  数値1 > 数値2
##  64  引数不正 (SX_EX_USAGE)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_num_cmp_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_arith "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_cmp_arith|])

	__sx_num_is_int_safe "${1-}" "${2-}" || return M_EX_USAGE

	__sx_num_cmp_arith "${1}" "${2}" || return
}

popdef([|CLEANUP|])dnl
