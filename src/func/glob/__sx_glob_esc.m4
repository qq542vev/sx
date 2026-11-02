M_REQUIRE([|__sx_str_tr0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_glob_esc - 文字列内の glob 特殊文字をエスケープする（内部用）
##
## 使い方:
##   __sx_glob_esc 結果変数名 文字列 [追加エスケープ文字]
##
## 説明:
##   sx_glob_esc の内部実装。引数チェックは行わない。
##   M_GLOB_SP_NORM および追加文字のうち glob でエスケープが必要な文字を置換する。
##
## 終了ステータス:
##    0  成功
define([|CLEANUP|], [|Q_bind Q_str Q_extra Q_rem Q_char|])dnl
__sx_glob_esc() {
	case "${3:+X}" in '')
		__sx_str_tr0 "${1}:" "${2-}" M_SH_QUOTE(M_GLOB_SP_NORM) '' M_GLOB_SP_NORM_ESC_ARGS "${@}"
		return
	esac

	Q_bind="${1}:"
	Q_str="${2-}"
	Q_extra="${3}"
	Q_rem="${Q_extra}"

	set --

	while M_STR_NE([|"${Q_rem}"|], [|''|]); do
		Q_char="${Q_rem%%"${Q_rem#?}"}"
		Q_rem="${Q_rem#?}"

		case "${Q_char}" in
			'!' | '^') set -- "${@}" "[[.${Q_char}.]]";;
			*) set -- "${@}" "[${Q_char}]";;
		esac
	done

	__sx_str_tr0 "${Q_bind}" "${Q_str}" M_SH_QUOTE(M_GLOB_SP_NORM)"${Q_extra}" '' M_GLOB_SP_NORM_ESC_ARGS "${@}"
	unset CLEANUP
}
|], [|glob_esc|])dnl
popdef([|CLEANUP|])dnl
