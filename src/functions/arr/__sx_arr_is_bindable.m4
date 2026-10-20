dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SWORD __sx_var_is_rw_deep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_is_bindable - バインド形式に含まれる変数が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_bindable バインド形式
##
## 説明:
##   sx_arr_is_bindable の内部実装。
##   コロン区切りのバインド形式を解析し、配列セグメントの _len を含む
##   すべての変数名に対して一括で書き込み権限を確認する。
##   引数チェック（構文検査）は行わない。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる

define([|CLEANUP|], [|Q_chk Q_arg Q_name|])dnl

__sx_arr_is_bindable() {
	Q_chk=

	for Q_arg in "${@}"; do
		while
			case "${Q_arg}" in
				[1-9]*)
					Q_name="${Q_arg%%:*}"

					case "${Q_name}" in *["${SX_STR_SWORD}"]*)
						Q_name="M_STR_LTRIM([|Q_name|], [|[!0-9/]|])"
						M_STR_APPEND([|Q_chk|], [|" ${Q_name}"|])
					esac
					;;
				:*) ;;
				*:*) M_STR_APPEND([|Q_chk|], [|" ${Q_arg%%:*}"|]);;
				?*) M_STR_APPEND([|Q_chk|], [|" ${Q_arg}"|]);&
				*) ! :;;
			esac
		do
			Q_arg="${Q_arg#*:}"
		done
	done

	eval set -- "${Q_chk}"
	unset CLEANUP

	__sx_var_is_rw_deep "${@}" || return
}
|], [|arr_is_bindable|])dnl
popdef([|CLEANUP|])dnl
