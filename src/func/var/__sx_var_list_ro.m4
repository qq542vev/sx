M_REQUIRE([|SX_SYS_CACHE_VAR_RO_NAMES SX_SYS_CACHE_VAR_RO_RAW __sx_var_bind_init __sx_var_ubind|])dnl
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

define([|CLEANUP|], [|Q_list Q_names Q_alias|])dnl

__sx_var_list_ro() {
	__sx_var_bind_init "${1}"
	Q_list=$(readonly -p)

	case "${Q_list}" in "${SX_SYS_CACHE_VAR_RO_RAW}")
		eval __sx_var_ubind '""' '"${1}"' "${SX_SYS_CACHE_VAR_RO_NAMES}" || :
		unset CLEANUP
		return
	esac

	Q_names=
	Q_alias="alias $(alias readonly 2>&-)" || Q_alias='unalias readonly'

	alias readonly=__sx_var_list_ro_cb

	eval "${Q_list}M_STR_LF()${Q_alias}"

	SX_SYS_CACHE_VAR_RO_RAW="${Q_list}"
	SX_SYS_CACHE_VAR_RO_NAMES="${Q_names}"

	eval __sx_var_ubind '""' '"${1}"' "${Q_names}" || :

	unset CLEANUP
}

__sx_var_list_ro_cb() {
	M_STR_APPEND([|Q_names|], [|" ${1%%=*}"|])
}
|], [|var_list_ro|])dnl
popdef([|CLEANUP|])dnl
