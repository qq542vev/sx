M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_cmp_nat0 __sx_num_is_nat0_base|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_cmp_nat0 - 2つの符号なし10進整数を比較する
##
## 使い方:
##   sx_num_cmp_nat0 数値1 数値2
##
## 説明:
##   指定された2つの符号なし10進整数を比較する。
##   引数はすべて 0 以上の整数である必要がある。
##
## 終了ステータス:
##   1  数値1 < 数値2
##   2  数値1 = 数値2
##   3  数値1 > 数値2
##  64  引数不正 (SX_EX_USAGE)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_num_cmp_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_nat0 "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_cmp_nat0|])

	__sx_num_is_nat0_base 10 "${1-}" "${2-}" || return M_EX_USAGE

	__sx_num_cmp_nat0 "${1}" "${2}" || return
}

popdef([|CLEANUP|])dnl
