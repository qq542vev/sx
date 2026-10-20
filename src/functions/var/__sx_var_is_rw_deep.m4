dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_ALNUM SX_STR_LF __sx_var_is_rw sx_str_is_word|])dnl
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

define([|CLEANUP|], [|Q_ro Q_out Q_arg Q_rest Q_tmp|])dnl

__sx_var_is_rw_deep() {
	Q_ro="${SX_STR_LF}$(readonly -p)${SX_STR_LF}"
	Q_out=

	for Q_arg in "${@}"; do
		Q_rest="${Q_ro}"

		while M_STR_HAS([|"${Q_rest}"|], [|"${SX_STR_LF}readonly ${Q_arg}"|]); do
			Q_rest="${Q_rest#*"${SX_STR_LF}readonly ${Q_arg}"}"

			case "${Q_rest}" in
				[${SX_STR_LF}=]*) M_STR_APPEND([|Q_out|], [|" ${Q_arg}"|]);;
				_[${SX_STR_ALNUM}]*)
					Q_tmp="${Q_rest%%[${SX_STR_LF}=]*}"

					if ! M_STR_MATCH([|${Q_tmp}|], [|*_|]) && sx_str_is_word "${Q_tmp}"; then
						M_STR_APPEND([|Q_out|], [|" ${Q_arg}_${Q_tmp#_}"|])
					fi
					;;
			esac
		done
	done

	eval set -- "${Q_out}"
	unset CLEANUP

	__sx_var_is_rw "${@}" || return
}
|], [|var_is_rw_deep|])dnl
popdef([|CLEANUP|])dnl
