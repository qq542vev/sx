M_REQUIRE([|SX_STR_LF SX_STR_SWORD SX_STR_WORD __sx_var_bind_init __sx_var_is_set __sx_var_ubind sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_list_set - 設定されている変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_set 結果変数名（またはバインド形式）
##
## 説明:
##   sx_var_list_set の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_list Q_bind Q_mark Q_ln Q_vn|])dnl

__sx_var_list_set() {
	Q_list="$(set)${SX_STR_LF}"
	__sx_var_bind_init "${1-}"
	Q_bind="${1-}"
	Q_mark=

	while M_STR_HAS([|"${Q_list}"|], [|"${SX_STR_LF}"|]); do
		Q_ln="${Q_list%%${SX_STR_LF}*}"
		Q_list="${Q_list#*${SX_STR_LF}}"

		case "${Q_ln}" in ["${SX_STR_SWORD}"]=* | ["${SX_STR_SWORD}"]*["${SX_STR_WORD}"]=*)
			case "${Q_bind:+X}" in '')
				break
			esac

			Q_vn="${Q_ln%%=*}"

			if
				sx_var_is_name "${Q_vn}" &&
				! __sx_var_is_set "Q_v${Q_vn}_" &&
				__sx_var_is_set "${Q_vn}"
			then
				__sx_var_ubind Q_bind "${Q_bind}" "${Q_vn}"

				eval "Q_v${Q_vn}_="
				M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])
			fi
		esac
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_list_set|])dnl
popdef([|CLEANUP|])dnl
