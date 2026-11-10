M_REQUIRE([|SX_SYS_CACHE_VAR_EXPORT_NAMES __sx_var_list_export|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_export - 変数がエクスポート属性を持つか確認する（内部用）
##
## 使い方:
##   __sx_var_is_export 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数がエクスポート属性を持つか確認する。
##   照合前にエクスポート属性付き変数の一覧を確認し、必要に応じてキャッシュを更新する。
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべてエクスポート属性付き (SX_EX_OK)
##    1  エクスポート属性のない変数が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_is_export() {
	__sx_var_list_export ''

	for Q_arg in "${@}"; do
		case " ${SX_SYS_CACHE_VAR_EXPORT_NAMES} " in
			*" ${Q_arg} "*) ;;
			*)
				unset CLEANUP
				return 1
				;;
		esac
	done

	unset CLEANUP
}
|], [|var_is_export|])dnl
popdef([|CLEANUP|])dnl
