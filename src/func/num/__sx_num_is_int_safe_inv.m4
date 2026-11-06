M_REQUIRE([|SX_SYS_NUM_MIN __sx_num_is_int_safe __sx_str_any|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int_safe_inv - 符号反転可能な整数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_int_safe_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe_inv の内部実装。引数チェックは行わない。

__sx_num_is_int_safe_inv() {
	__sx_num_is_int_safe "${@}" && ! __sx_str_any "${SX_SYS_NUM_MIN}" "${@}" || return
}
|], [|num_is_int_safe_inv|])dnl
popdef([|CLEANUP|])dnl
