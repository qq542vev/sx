dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_LF SX_STR_SWORD SX_STR_WORD __sx_var_bind_init __sx_var_is_ro __sx_var_is_set __sx_var_ubind sx_var_is_name|])dnl
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

define([|CLEANUP|], [|Q_list Q_bind Q_mark Q_vn|])dnl

__sx_var_list_ro() {
	Q_list="${SX_STR_LF}$(readonly -p)${SX_STR_LF}"
	__sx_var_bind_init "${1-}"
	Q_bind="${1-}"
	Q_mark=

	while M_STR_HAS([|"${Q_list}"|], [|"${SX_STR_LF}readonly "|]); do
		Q_list="${Q_list#*${SX_STR_LF}readonly }"

		case "${Q_list}" in ["${SX_STR_SWORD}"]*)
			case "${Q_bind:+X}" in '')
				break
			esac

			Q_vn="${Q_list%%[!"${SX_STR_WORD}"]*}"

			if
				sx_var_is_name "${Q_vn}" &&
				! __sx_var_is_set "Q_v${Q_vn}_" &&
				__sx_var_is_ro "${Q_vn}"
			then
				__sx_var_ubind Q_bind "${Q_bind}" "${Q_vn}"

				eval "Q_v${Q_vn}_="
				M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])
			fi
		esac
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_list_ro|])dnl
popdef([|CLEANUP|])dnl
