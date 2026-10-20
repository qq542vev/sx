dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_SYS_NUM_QM __sx_num_cmp_arith __sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_cmp_nat0 - 符号なし10進整数文字列を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺

define([|CLEANUP|], [|Q_l Q_r|])dnl

__sx_num_cmp_nat0() {
	case "${1}" in "${2}")
		return 2
	esac

	Q_l="${#1}"
	Q_r="${#2}"

	case "${Q_l}" in "${Q_r}")
		while M_STR_MATCH([|"${1}"|], [|${SX_SYS_NUM_QM}?*|]); do
			set -- "${1#${SX_SYS_NUM_QM}}" "${2#${SX_SYS_NUM_QM}}" "${1}" "${2}"
			__sx_num_cmp_arith "1${3%"${1}"}" "1${4%"${2}"}" || case "${?}" in 1 | 3)
				set -- "${?}"
				unset CLEANUP
				return "${1}"
			esac
		done

		unset CLEANUP

	__sx_num_cmp_arith "1${1}" "1${2}" || return "${?}"
	esac

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_l}" "${Q_r}"; then
		__sx_num_cmp_arith "${Q_l}" "${Q_r}"
	else
		__sx_num_cmp_nat0 "${Q_l}" "${Q_r}"
	fi || {
		set -- "${?}"
		unset CLEANUP
		return "${1}"
	}
}
|], [|num_cmp_nat0|])dnl
popdef([|CLEANUP|])dnl
