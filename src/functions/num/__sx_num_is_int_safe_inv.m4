M_REQUIRE([|SX_CFG_NUM_RANGE SX_NUM_I128_MIN SX_NUM_I32_MIN SX_NUM_I64_MIN __sx_num_is_int_safe|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int_safe_inv - 符号反転可能な整数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_int_safe_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe_inv の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_min Q_arg|])dnl

__sx_num_is_int_safe_inv() {
	__sx_num_is_int_safe "${@}" || return

	eval "Q_min=\"\${SX_NUM_I${SX_CFG_NUM_RANGE}_MIN}\""

	for Q_arg in "${@}"; do
		case "${Q_arg}" in "${Q_min}")
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_int_safe_inv|])dnl
popdef([|CLEANUP|])dnl
