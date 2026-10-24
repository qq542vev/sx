M_REQUIRE([|__sx_var_copy_script|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_copy - 変数の値を連鎖コピーする（内部用）
##
## 使い方:
##   __sx_var_copy [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_copy の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_asg|])dnl

__sx_var_copy() {
	__sx_var_copy_script Q_asg "${@}"

	# 代入の実行
	eval "${Q_asg}"

	# 内部用変数を掃除
	unset CLEANUP
}
|], [|var_copy|])dnl
popdef([|CLEANUP|])dnl
