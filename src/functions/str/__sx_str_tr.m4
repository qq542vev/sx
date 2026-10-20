dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_str_chunk __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_tr - 文字列内の文字を対応する文字で変換する（内部用）
##
## 使い方:
##   __sx_str_tr バインド形式 [文字列 [from文字列 [to文字列 [limit]]]]
##
## 説明:
##   sx_str_tr の内部実装。引数チェックは行わない。
##   バインド形式で置換結果と置換回数を取得できる。
##   例: res:（結果のみ）、res:cnt:（結果と回数）
##   limit は符号付き10進整数（先行ゼロなし）を前提とする。
##   文字列長・from/to の長さ・limit の絶対値が算術域内なら算術、
##   それ以外は多倍長で回数と添字を処理する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_str Q_from Q_to Q_out Q_lim Q_cnt Q_pre Q_suf Q_from_pre Q_idx Q_type Q_abs Q_n|])dnl

__sx_str_tr() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2-}"
	Q_from="${3-}"
	Q_out=
	Q_lim="${5:-${#Q_str}}"
	Q_abs="${Q_lim#[+-]}"
	Q_cnt=0

	case "${Q_str:+${Q_from:+X}}" in '')
		__sx_var_bind '' "${Q_bind}" "${Q_str}" "${Q_cnt}" || :
		unset CLEANUP
		return
	esac

	__sx_str_chunk Q_to "${4-}" 1
	eval set -- "${Q_to}"
	Q_n="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#Q_str}" "${#Q_from}" "${Q_n}" "${Q_abs}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	case "${Q_lim}" in
		-*)
			while M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]) && M_STR_NE([|"${Q_cnt}"|], [|"${Q_abs}"|]); do
				Q_suf="${Q_str##*["${Q_from}"]}"
				Q_str="${Q_str%"${Q_suf}"}"
				Q_pre="${Q_str%?}"
				Q_from_pre="${Q_from%%"${Q_str#"${Q_pre}"}"*}"
				Q_idx="${#Q_from_pre}"

				"__sx_num_cmp_${Q_type}" "${Q_idx}" "${Q_n}" || case "${?}" in
					1)
						"__sx_num_add1_${Q_type}" Q_idx "${Q_idx}"
						eval "Q_out=\"\${${Q_idx}}\${Q_suf}\${Q_out}\""
						;;
					*) M_STR_PREPEND([|Q_out|], [|"${Q_suf}"|]);;
				esac

				Q_str="${Q_pre}"
				"__sx_num_add1_${Q_type}" Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${Q_bind}" "${Q_str}${Q_out}" "${Q_cnt}"
			;;
		*)
			while M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]) && M_STR_NE([|"${Q_cnt}"|], [|"${Q_abs}"|]); do
				Q_pre="${Q_str%%["${Q_from}"]*}"
				Q_str="${Q_str#"${Q_pre}"}"
				Q_suf="${Q_str#?}"
				Q_from_pre="${Q_from%%"${Q_str%"${Q_suf}"}"*}"
				Q_idx="${#Q_from_pre}"

				"__sx_num_cmp_${Q_type}" "${Q_idx}" "${Q_n}" || case "${?}" in
					1)
						"__sx_num_add1_${Q_type}" Q_idx "${Q_idx}"
						eval "Q_out=\"\${Q_out}\${Q_pre}\${${Q_idx}}\""
						;;
					*) M_STR_APPEND([|Q_out|], [|"${Q_pre}"|]);;
				esac

				Q_str="${Q_suf}"
				"__sx_num_add1_${Q_type}" Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${Q_bind}" "${Q_out}${Q_str}" "${Q_cnt}"
			;;
	esac || :

	unset CLEANUP
}
|], [|str_tr|])dnl
popdef([|CLEANUP|])dnl
