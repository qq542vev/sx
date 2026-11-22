M_REQUIRE([|SX_CFG_NUM_RANGE __sx_arg_find_emit4 __sx_arg_find_emit16 __sx_arg_find_emit20 __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_rfind_lit - 引数リストから指定された値を後ろ向きに探す（内部用: リテラル/Glob）
##
## 使い方:
##   __sx_arg_rfind_lit 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   sx_arg_rfind のリテラル/Glob検索実装。末尾から先頭に向かって検索する。
##   引数チェックは行わない。
##   NOT フラグ指定時は一致しない要素を対象にする。
##   出力形式は POS|TEXT で指定し、未指定なら POS を既定とする。
##   フラグ値に対応する __sx_arg_find_emit<fmt> をループ前に選択し、
##   ループ内では形式を検査せずにバインドする。
##   データ個数が算術域内なら算術、それ以外は多倍長で添字を減らす。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_bind Q_match Q_glob Q_fmt Q_not Q_i Q_arg Q_sts Q_type|])dnl

__sx_arg_rfind_lit() {
	Q_bind="${1}"
	Q_match="${2}"
	Q_glob=$((${3} & M_ARG_RFIND_GLOB))
	Q_fmt=$((${3} & (M_ARG_RFIND_POS | M_ARG_RFIND_TEXT)))
	Q_not=$((${3} & M_ARG_RFIND_NOT))

	case "${Q_fmt}" in 0)
		Q_fmt=M_ARG_RFIND_POS
	esac

	shift 3
	Q_i="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_i}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	while
		eval "Q_arg=\"\${${Q_i}}\""

		case "${Q_glob}${Q_arg}" in
			"0${Q_match}" | M_ARG_RFIND_GLOB${Q_match}) case "${Q_not}" in [!0]*) ! :;; esac;;
			*) case "${Q_not}" in 0) ! :;; esac;;
		esac && "__sx_arg_find_emit${Q_fmt}" Q_bind "${Q_bind}" "${Q_i}" "${Q_arg}" && Q_sts=M_EX_OK

		case "${Q_bind:+${Q_i}}" in '' | 1)
			break
		esac

		"__sx_num_sub1_${Q_type}" Q_i "${Q_i}"
		continue
	do :; done

	set -- "${Q_sts-1}"

	unset CLEANUP
	return "${1}"
}
|], [|arg_rfind_lit|])dnl
popdef([|CLEANUP|])dnl
