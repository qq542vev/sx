M_REQUIRE([|SX_STR_SWORD __sx_var_is_rw __sx_var_is_rw_deep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_bindable - バインド形式に含まれる変数が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_bindable バインド形式
##
## 説明:
##   コロン区切りのバインド形式を解析し、含まれるすべての変数名に対して
##   一括で書き込み権限を確認する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる

define([|CLEANUP|], [|Q_str Q_arr Q_arg Q_seg|])dnl

__sx_var_is_bindable() {
	Q_str=
	Q_arr=

	for Q_arg in "${@}"; do
		while
			Q_seg="${Q_arg%%:*}"

			case "${Q_seg}" in
				*@*) M_STR_APPEND([|Q_arr|], [|"${Q_seg#*@} "|]);;
				["${SX_STR_SWORD}"]*) M_STR_APPEND([|Q_str|], [|"${Q_seg} "|]);;
				*["${SX_STR_SWORD}"]*) M_STR_APPEND([|Q_str|], [|"M_STR_LTRIM([|Q_seg|], [|[!0-9]|]) "|]);;
			esac

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done
	done

	eval ${Q_str:+"__sx_var_is_rw ${Q_str}"} && eval ${Q_arr:+"__sx_var_is_rw_deep ${Q_arr}"} || {
		unset CLEANUP
		return 1
	}

	unset CLEANUP
}
|], [|var_is_bindable|])dnl
popdef([|CLEANUP|])dnl
