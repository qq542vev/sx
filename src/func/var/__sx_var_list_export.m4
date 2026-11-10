M_REQUIRE([|SX_SYS_CACHE_VAR_EXPORT_RAW SX_SYS_CACHE_VAR_EXPORT_NAMES __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_list_export - エクスポート属性付き変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_export 結果変数名（またはバインド形式）
##
## 説明:
##   sx_var_list_export の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_list Q_names Q_alias|])dnl

__sx_var_list_export() {
	__sx_var_bind_init "${1}"
	Q_list=$(export -p)

	case "${Q_list}" in "${SX_SYS_CACHE_VAR_EXPORT_RAW}")
		eval __sx_var_ubind '""' '"${1}"' "${SX_SYS_CACHE_VAR_EXPORT_NAMES}" || :
		unset CLEANUP
		return
	esac

	Q_names=
	Q_alias="alias $(alias export 2>&-)" || Q_alias='unalias export'

	alias export=__sx_var_list_export_cb

	eval "${Q_list}M_STR_LF()${Q_alias}"

	SX_SYS_CACHE_VAR_EXPORT_RAW="${Q_list}"
	SX_SYS_CACHE_VAR_EXPORT_NAMES="${Q_names# }"

	eval __sx_var_ubind '""' '"${1}"' "${SX_SYS_CACHE_VAR_EXPORT_NAMES}" || :

	unset CLEANUP
}

__sx_var_list_export_cb() {
	M_STR_APPEND([|Q_names|], [|" ${1%%=*}"|])
}
|], [|var_list_export|])dnl
popdef([|CLEANUP|])dnl
