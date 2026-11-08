M_REQUIRE([|__sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_list_ro - 読み取り専用変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_ro 結果変数名（またはバインド形式）
##
## 説明:
##   sx_var_list_ro の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_list Q_vars Q_alias|])dnl

__sx_var_list_ro() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_list=$(readonly -p)
	Q_vars=
	Q_alias="alias $(alias readonly 2>&-)" || Q_alias='unalias readonly'

	alias readonly=__sx_var_list_ro_cb

	eval "${Q_list}M_STR_LF()${Q_alias}"
	eval __sx_var_ubind '""' '"${Q_bind}"' "${Q_vars}" || :

	unset CLEANUP
}

__sx_var_list_ro_cb() {
	M_STR_APPEND([|Q_vars|], [|" ${1%%=*}"|])
}
|], [|var_list_ro|])dnl
popdef([|CLEANUP|])dnl
