M_REQUIRE([|__sx_str_tr0|])dnl
dnl 英字の位置に対応する [Aa]〜[Zz] の置換先引数列を生成する。
pushdef([|__sx_m4_gen_glob_esc_icase_args|], [|'[substr(M_STR_UPPER, $1, 1)[||]substr(M_STR_LOWER, $1, 1)]'ifelse($1, 25, [||], [| __sx_m4_gen_glob_esc_icase_args(incr($1))|])|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_glob_esc_icase - リテラル文字列を英字の大小を区別しない glob に変換する（内部用）
##
## 使い方:
##   __sx_glob_esc_icase 結果変数名 [文字列] [追加エスケープ文字]
##
## 説明:
##   sx_glob_esc_icase の内部実装。引数チェックは行わない。
##   特殊文字と英字を一つの対応表で置換し、置換先のブラケット式は再走査しない。
##   第3引数で指定された追加文字も glob のリテラル用ブラケット式に置換する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
define([|CLEANUP|], [|Q_res Q_str Q_extra Q_from Q_char|])dnl
__sx_glob_esc_icase() {
	case "${3:+${2}}" in *["${3-}"]*) ;; *)
		__sx_str_tr0 "${1}:" "${2-}" M_SH_QUOTE(M_GLOB_SP_NORM[||]M_STR_ALPHA) '' \
			M_GLOB_SP_NORM_ESC_ARGS \
			__sx_m4_gen_glob_esc_icase_args(0) \
			__sx_m4_gen_glob_esc_icase_args(0)
		return
	esac

	Q_res="${1}"
	Q_str="${2}"
	Q_extra="${3}"
	Q_from=M_SH_QUOTE(M_GLOB_SP_NORM()M_STR_ALPHA())"${Q_extra}"

	set --

	while M_STR_NE([|"${Q_extra}"|], [|''|]); do
		Q_char="${Q_extra%%"${Q_extra#?}"}"
		Q_extra="${Q_extra#?}"

		case "${Q_char}" in
			'!' | '^') set -- "${@}" "[[.${Q_char}.]]";;
			*) set -- "${@}" "[${Q_char}]";;
		esac
	done

	__sx_str_tr0 "${Q_res}:" "${Q_str}" "${Q_from}" '' \
		M_GLOB_SP_NORM_ESC_ARGS \
		__sx_m4_gen_glob_esc_icase_args(0) \
		__sx_m4_gen_glob_esc_icase_args(0) "${@}"
	unset CLEANUP
}
|], [|glob_esc_icase|])dnl
popdef([|CLEANUP|])dnl
popdef([|__sx_m4_gen_glob_esc_icase_args|])dnl
