M_REQUIRE([|SX_CFG_SIG_ARR __sx_num_is_nat0_base sx_str_sw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_arr - 指定された変数がsx配列であるか確認する（内部用）
##
## 使い方:
##   __sx_var_is_arr [変数名1 ...]
##
## 説明:
##   変数の値（シグネチャ）と長さ変数の妥当性をチェックする。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_is_arr() {
	for Q_arg in "${@}"; do
		if
			! eval sx_str_sw "\"\${${Q_arg}-}\"" '"${SX_CFG_SIG_ARR}":' ||
			! eval __sx_num_is_nat0_base 10 "\"\${${Q_arg}_len-}\""
		then
			unset CLEANUP
			return 1
		fi
	done

	unset CLEANUP
}
|], [|var_is_arr|])dnl
popdef([|CLEANUP|])dnl
