M_REQUIRE([|SX_SYS_NUM_MIN __sx_num_is_int_safe|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int_safe_inv - 符号反転可能な整数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_int_safe_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe_inv の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_n|])dnl

__sx_num_is_int_safe_inv() {
	__sx_num_is_int_safe "${@}" || return 1

	for Q_n in "${@}"; do
		case "$((Q_n == SX_SYS_NUM_MIN))" in 1)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_int_safe_inv|])dnl
popdef([|CLEANUP|])dnl
