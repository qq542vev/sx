M_REQUIRE([|SX_STR_ALPHA SX_STR_CAPITAL_KEEP SX_STR_CAPITAL_SENT __sx_str_lower __sx_str_upper_cb|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_capital - sx_str_capital の内部実装（内部用）
##
## 使い方:
##   __sx_str_capital 結果変数名 [元文字列 [フラグ]]
##
## 説明:
##   sx_str_capital の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_str Q_out Q_tmp|])dnl

__sx_str_capital() {
	set -- "${1}" "${2-}" "${3:-0}"
	Q_str="${2}"
	Q_out=

	case "$(((${3} & SX_STR_CAPITAL_SENT) != 0))${2}" in 0["${SX_STR_ALPHA}"]* | 1*["${SX_STR_ALPHA}"]*)
		Q_out="${2%%["${SX_STR_ALPHA}"]*}"
		Q_str="${2#"${Q_out}"}"
		__sx_str_upper_cb Q_tmp "${Q_str%"${Q_str#?}"}"
		M_STR_APPEND([|Q_out|], [|"${Q_tmp}"|])
		Q_str="${Q_str#?}"
	esac

	case "$((${3} & SX_STR_CAPITAL_KEEP))" in 0)
		__sx_str_lower Q_str "${Q_str}"
	esac

	M_VAR_SET([|${1}|], [|${Q_out}${Q_str}|])
	unset CLEANUP
}
|], [|str_capital|])dnl
popdef([|CLEANUP|])dnl
