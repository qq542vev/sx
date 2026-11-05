M_REQUIRE([|__sx_str_escape_all __sx_str_tr0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_escape - 文字列内の指定された文字をエスケープする（内部用）
##
## 使い方:
##   __sx_str_escape 結果変数名 [元文字列 [エスケープ対象文字集合 [開始エスケープ文字列 [終了エスケープ文字列]]]]
##
## 説明:
##   sx_str_escape の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_str Q_esc Q_from Q_pref Q_suf Q_char|])dnl

__sx_str_escape() {
	case "${3:+${2}}" in
		'')
			M_VAR_SET([|${1}|], [|${2-}|])
			return
			;;
		*[!"${3}"]["${3}"]* | *["${3}"][!"${3}"]*) ;;
		*["${3}"]*)
			__sx_str_escape_all "${1}" "${2}" "${4-\\}" "${5-}"
			return
			;;
		*)
			M_VAR_SET([|${1}|], [|${2}|])
			return
		;;
	esac

	Q_res="${1}"
	Q_str="${2}"
	Q_esc="${3}"
	Q_from="${3}"
	Q_pref="${4-\\}"
	Q_suf="${5-}"

	set --

	while M_STR_NE([|"${Q_esc}"|], [|''|]); do
		Q_char="${Q_esc%%"${Q_esc#?}"}"
		Q_esc="${Q_esc#?}"

		set -- "${@}" "${Q_pref}${Q_char}${Q_suf}"
	done

	__sx_str_tr0 "${Q_res}:" "${Q_str}" "${Q_from}" '' "${@}"
	unset CLEANUP
}
|], [|str_escape|])dnl
popdef([|CLEANUP|])dnl
