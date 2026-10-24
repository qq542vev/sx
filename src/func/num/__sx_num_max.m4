M_REQUIRE([|__sx_num_cmp_fixed __sx_num_norm|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_max - 与えられた数値の最大値を取得する（内部用）
##
## 使い方:
##   __sx_num_max 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_max の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_win Q_wnorm Q_arg Q_anorm|])dnl

__sx_num_max() {
	Q_res="${1}"
	Q_win="${2}"
	shift 2

	__sx_num_norm Q_wnorm "${Q_win}"

	for Q_arg in "${@}"; do
		__sx_num_norm Q_anorm "${Q_arg}"

		__sx_num_cmp_fixed "${Q_wnorm}" "${Q_anorm}" || case "${?}" in 1)
			Q_win="${Q_arg}"
			Q_wnorm="${Q_anorm}"
		esac
	done

	M_VAR_SET([|${Q_res}|], [|${Q_win}|])
	unset CLEANUP
}
|], [|num_max|])dnl
popdef([|CLEANUP|])dnl
