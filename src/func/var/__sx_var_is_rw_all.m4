M_REQUIRE([|__sx_var_is_rw __sx_var_list_dep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_rw_all - 指定された変数および関連要素が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_rw_all 名前1 [名前2 ...]
##
## 説明:
##   sx_var_is_rw_all の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_ls|])dnl

__sx_var_is_rw_all() {
	__sx_var_list_dep Q_ls "${@}"
	eval set -- "${Q_ls}"
	unset CLEANUP

	__sx_var_is_rw "${@}" || return
}
|], [|var_is_rw_all|])dnl
popdef([|CLEANUP|])dnl
