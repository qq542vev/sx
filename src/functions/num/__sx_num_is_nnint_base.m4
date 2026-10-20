M_REQUIRE([|__sx_num_is_pint_base|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nnint_base - 指定された基数で非負整数（0以上）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nnint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nnint_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_nnint_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_rad}${Q_arg}" in
			800 | 8[+-]00 | 100 | 10[+-]0 | 160[Xx]0 | 16[+-]0[Xx]0) continue;;
		esac

		__sx_num_is_pint_base "${Q_rad}" "${Q_arg}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nnint_base|])dnl
popdef([|CLEANUP|])dnl
