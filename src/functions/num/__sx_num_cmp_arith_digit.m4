M_REQUIRE([|__sx_num_cmp_arith|])dnl
pushdef([|CLEANUP|])dnl
### __sx_num_cmp_arith_digit - 10進整数文字列を算術展開で比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_arith_digit() {
	set -- "${1#${1%%[!0]*}}" "${2#${2%%[!0]*}}"
	__sx_num_cmp_arith "${1:-0}" "${2:-0}"
}

popdef([|CLEANUP|])dnl
