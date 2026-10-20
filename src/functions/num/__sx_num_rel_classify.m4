M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
### __sx_num_rel_classify - 比較方式を分類する（内部用）
##
## 終了ステータス:
##   1  arith (算術展開比較)
##   2  dec   (10進整数文字列比較)
##   3  norm  (正規化数値比較)
__sx_num_rel_classify() {
	case "${1}" in
		*0[Xx]* | 0[0-9]* | [+-]0[0-9]*) return 1;;
		*.* | *[Ee]*) return 3;;
	esac

	__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${1}" || return 2

	return 1
}

popdef([|CLEANUP|])dnl
