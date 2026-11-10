M_REQUIRE([|SX_SYS_CACHE_VAR_RO_NAMES __sx_var_list_ro|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_ro - 変数が読み取り専用か確認する（内部用）
##
## 使い方:
##   __sx_var_is_ro 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が読み取り専用か確認する。
##   一覧は増加のみのため、未登録名がある場合に一度だけキャッシュを更新する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_update|])dnl

__sx_var_is_ro() {
	Q_update=0

	for Q_arg in "${@}"; do
		case " ${SX_SYS_CACHE_VAR_RO_NAMES} " in
			*" ${Q_arg} "*) ;;
			*)
				case "${Q_update}" in
					0)
						__sx_var_list_ro ''
						Q_update=1

						case " ${SX_SYS_CACHE_VAR_RO_NAMES} " in
							*" ${Q_arg} "*) ;;
							*)
								unset CLEANUP
								return 1
								;;
						esac
						;;
					*)
						unset CLEANUP
						return 1
						;;
				esac
				;;
		esac
	done

	unset CLEANUP
}
|], [|var_is_ro|])dnl
popdef([|CLEANUP|])dnl
