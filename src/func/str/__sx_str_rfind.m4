M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_fit_dec __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_find_bind __sx_var_bind_init|])dnl
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
##   出力形式フラグが未指定なら POS|LEN を既定とし、指定されていれば
##   __sx_str_find_bind へ委譲して POS:LEN:TEXT 順で出力する。
##   委譲時は各出力形式フラグを 1 または空文字列に正規化して渡す。

define([|CLEANUP|], [|Q_bind Q_tgt Q_off Q_pre Q_sts Q_match Q_after Q_fmt Q_overlap Q_type|])dnl

__sx_str_rfind() {
	set -- "${1}" "${2-}" "${3-}" "${4:-0}"
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_tgt="${2}"
	Q_fmt=$((${4} & (M_STR_RFIND_POS | M_STR_RFIND_LEN | M_STR_RFIND_TEXT)))

	case "${Q_fmt}" in
		0) Q_fmt=$((M_STR_RFIND_POS | M_STR_RFIND_LEN));;
	esac

	case $((Q_fmt & M_STR_RFIND_POS)) in
		0) set -- "${@}" '';;
		*) set -- "${@}" 1;;
	esac

	case $((Q_fmt & M_STR_RFIND_LEN)) in
		0) set -- "${@}" '';;
		*) set -- "${@}" 1;;
	esac

	case $((Q_fmt & M_STR_RFIND_TEXT)) in
		0) set -- "${@}" '';;
		*) set -- "${@}" 1;;
	esac

	Q_overlap=$((${4} & M_STR_RFIND_OVERLAP))

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${4} & M_STR_RFIND_GLOB|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		Q_off="${#Q_tgt}"
		Q_sts=M_EX_OK

		if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_off}"; then
			Q_type=arith
		else
			Q_type=nat0
		fi

		# 空 needle: len から 0 へ
		while
			__sx_str_find_bind Q_bind "${Q_bind}" "${5}" "${6}" "${7}" "${Q_off}" 0 '' || break

			case "${Q_off}" in 0)
				break
			esac

			"__sx_num_sub_${Q_type}" Q_off "${Q_off}" 1
			continue
		do :; done
	elif M_NUM_BOOL([|${4} & M_STR_RFIND_GLOB|]); then
		# ==== グロブモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|${3}|]); do
			Q_pre="${Q_tgt%${3}*}"
			Q_match="${Q_tgt##"${Q_pre}"}"
			Q_after="${Q_match#${3}}"
			Q_match="${Q_match%%"${Q_after}"}"
			: "${Q_sts=M_EX_OK}"

			__sx_str_find_bind Q_bind "${Q_bind}" "${5}" "${6}" "${7}" "${#Q_pre}" "${#Q_match}" "${Q_match}" || break

			case "${Q_overlap}" in
				0) Q_tgt="${Q_pre}";;
				*) Q_tgt="${Q_pre}${Q_match%?}";;
			esac
		done
	else
		# ==== リテラルモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|"${3}"|]); do
			Q_pre="${Q_tgt%"${3}"*}"
			: "${Q_sts=M_EX_OK}"

			__sx_str_find_bind Q_bind "${Q_bind}" "${5}" "${6}" "${7}" "${#Q_pre}" "${#3}" "${3}" || break

			case "${Q_overlap}" in
				0) Q_tgt="${Q_pre}";;
				*) Q_tgt="${Q_pre}${3%?}";;
			esac
		done
	fi

	set -- "${Q_sts-1}"
	unset CLEANUP
	return "${1}"
}
|], [|str_rfind|])dnl
popdef([|CLEANUP|])dnl
