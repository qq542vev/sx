M_REQUIRE([|__sx_str_escape_all __sx_str_tr0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_glob_esc_eq - 指定した文字を等価クラスにする glob を生成する（内部用）
##
## 使い方:
##   __sx_glob_esc_eq 結果変数名 [文字列] [等価クラス化する文字] [追加エスケープ文字]
##
## 説明:
##   sx_glob_esc_eq の内部実装。引数チェックは行わない。
##   第3引数に含まれる入力文字を、それぞれ glob の等価クラス表記に変換する。
##   等価クラスの照合内容は照合時のロケールに従う。等価クラス化は glob 特殊文字と
##   第4引数の追加エスケープ文字より優先する。
##   それ以外の glob 特殊文字と追加エスケープ文字は、リテラル用ブラケット式にする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
define([|CLEANUP|], [|Q_bind Q_str Q_eq Q_extra Q_from Q_rem Q_char|])dnl
__sx_glob_esc_eq() {
	case "${3:+${2-}}" in '' | *[!"${3-}"]*) ;; *)
		__sx_str_escape_all "${1}" "${2}" '[[=' '=]]'
		return
	esac

	Q_bind="${1}:"
	Q_str="${2-}"
	Q_eq="${3-}"
	Q_extra="${4-}"
	Q_from=

	set --

	case "${Q_eq:+${Q_str}}" in *["${Q_eq}"]*)
		Q_from="${Q_eq}"

		while M_STR_NE([|"${Q_eq}"|], [|''|]); do
			Q_char="${Q_eq%%"${Q_eq#?}"}"
			Q_eq="${Q_eq#?}"

			set -- "${@}" "[[=${Q_char}=]]"
		done
	esac

	M_STR_APPEND([|Q_from|], [|M_SH_QUOTE(M_GLOB_SP_NORM)"${Q_extra}"|])
	set -- "${@}" M_GLOB_SP_NORM_ESC_ARGS

	case "${Q_extra:+${Q_str}}" in *["${Q_extra}"]*)
		while M_STR_NE([|"${Q_extra}"|], [|''|]); do
			Q_char="${Q_extra%%"${Q_extra#?}"}"
			Q_extra="${Q_extra#?}"

			case "${Q_char}" in
				'!' | '^') set -- "${@}" "[[.${Q_char}.]]";;
				*) set -- "${@}" "[${Q_char}]";;
			esac
		done
	esac

	__sx_str_tr0 "${Q_bind}" "${Q_str}" "${Q_from}" '' "${@}"
	unset CLEANUP
}
|], [|glob_esc_eq|])dnl
popdef([|CLEANUP|])dnl
