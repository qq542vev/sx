M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_fit_dec __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_find_emit4 __sx_str_find_emit8 __sx_str_find_emit12 __sx_str_find_emit16 __sx_str_find_emit20 __sx_str_find_emit24 __sx_str_find_emit28 __sx_var_bind_init __sx_glob_esc_eq __sx_glob_esc_icase|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_rfind - 文字列から指定された文字列を後方一致で探す（内部用）
##
## 使い方:
##   __sx_str_rfind 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_rfind の内部実装。引数チェックは行わない。
##   空検索時の位置の減算は、文字列長が算術域内なら算術、それ以外は多倍長で行う。
##   リテラル・グロブ検索の位置と一致長はパラメータ展開で取得する。
##   出力形式フラグが未指定なら POS|LEN を既定とする。
##   フラグ値に対応する __sx_str_find_emit<fmt> をループ前に選択し、
##   ループ内ではフラグを検査せずに POS:LEN:TEXT 順で出力する。

define([|CLEANUP|], [|Q_bind Q_tgt Q_off Q_pre Q_match Q_after Q_fmt Q_overlap Q_type Q_fn Q_pat Q_glob|])dnl

__sx_str_rfind() {
	set -- "${1}" "${2-}" "${3-}" "${4:-0}"
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_tgt="${2}"
	Q_fmt=$((${4} & (M_STR_RFIND_POS | M_STR_RFIND_LEN | M_STR_RFIND_TEXT)))

	case "${Q_fmt}" in 0)
		Q_fmt=$((M_STR_RFIND_POS | M_STR_RFIND_LEN))
	esac

	Q_fn="__sx_str_find_emit${Q_fmt}"

	Q_overlap=$((${4} & M_STR_RFIND_OVERLAP))

	case 0 in
		"$((!(${4} & M_STR_RFIND_ICASE)))")
			__sx_glob_esc_icase Q_pat "${3}"
			Q_glob=1
			;;
		"$((!(${4} & M_STR_RFIND_EQC)))")
			__sx_glob_esc_eq Q_pat "${3}"
			Q_glob=1
			;;
		*) Q_pat="${3}" Q_glob=$((${4} & M_STR_RFIND_GLOB));;
	esac

	if
		M_STR_EQ([|"${Q_pat}"|], [|''|]) ||
		{ M_NUM_BOOL([|Q_glob|]) && ! M_STR_HAS([|"${Q_pat}"|], [|*[!*]*|]); }
	then
		Q_off="${#Q_tgt}"

		if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_off}"; then
			Q_type=arith
		else
			Q_type=nat0
		fi

		# 空 needle: len から 0 へ
		while
			"${Q_fn}" Q_bind "${Q_bind}" "${Q_off}" 0 '' || break

			case "${Q_off}" in 0)
				break
			esac

			"__sx_num_sub_${Q_type}" Q_off "${Q_off}" 1
			continue
		do :; done

		set -- 0
	elif M_NUM_BOOL([|Q_glob|]); then
		# ==== グロブモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|${Q_pat}|]); do
			Q_pre="${Q_tgt%${Q_pat}*}"
			Q_match="${Q_tgt##"${Q_pre}"}"
			Q_after="${Q_match#${Q_pat}}"
			Q_match="${Q_match%%"${Q_after}"}"

			"${Q_fn}" Q_bind "${Q_bind}" "${#Q_pre}" "${#Q_match}" "${Q_match}" || break

			case "${Q_overlap}" in
				0) Q_tgt="${Q_pre}";;
				*) Q_tgt="${Q_pre}${Q_match%?}";;
			esac
		done

		set -- ${Q_pre+'0'}
	else
		# ==== リテラルモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|"${Q_pat}"|]); do
			Q_pre="${Q_tgt%"${Q_pat}"*}"

			"${Q_fn}" Q_bind "${Q_bind}" "${#Q_pre}" "${#Q_pat}" "${Q_pat}" || break

			case "${Q_overlap}" in
				0) Q_tgt="${Q_pre}";;
				*) Q_tgt="${Q_pre}${Q_pat%?}";;
			esac
		done

		set -- ${Q_pre+'0'}
	fi

	unset CLEANUP
	return "${1-1}"
}
|], [|str_rfind|])dnl
popdef([|CLEANUP|])dnl
