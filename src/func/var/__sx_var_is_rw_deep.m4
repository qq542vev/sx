M_REQUIRE([|SX_SYS_CACHE_VAR_RO_NAMES __sx_var_list_ro|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_rw_deep - 変数およびその配下のサブ変数がすべて書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_rw_deep 変数名 [変数名 ...]
##
## 説明:
##   sx_var_is_rw_deep の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_is_rw_deep() {
	__sx_var_list_ro ''

	for Q_arg in "${@}"; do
		case " ${SX_SYS_CACHE_VAR_RO_NAMES} " in *" ${Q_arg} "* | *" ${Q_arg}_"*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|var_is_rw_deep|])dnl
popdef([|CLEANUP|])dnl
