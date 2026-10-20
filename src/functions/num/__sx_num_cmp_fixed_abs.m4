dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_cmp_fixed_frac __sx_num_cmp_nat0|])dnl
pushdef([|CLEANUP|])dnl
### __sx_num_cmp_fixed_abs - 正規化済み絶対値同士を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_fixed_abs() {
	case "${1}" in
		*.*) set -- "${1%%.*}" "${2}" "${1#*.}";;
		*) set -- "${1}" "${2}" '';;
	esac

	case "${2}" in
		*.*) set -- "${1}" "${2%%.*}" "${3}" "${2#*.}";;
		*) set -- "${1}" "${2}" "${3}" '';;
	esac

	__sx_num_cmp_nat0 "${1}" "${2}" || case "${?}" in 1 | 3)
		return "${?}"
	esac

	__sx_num_cmp_fixed_frac "${3}" "${4}" || return "${?}"
}

popdef([|CLEANUP|])dnl
