M_REQUIRE([|__sx_num_add1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_tr0 - 分割済みの対応表で文字を文字列へ置換する（内部用）
##
## 使い方:
##   __sx_str_tr0 バインド形式 文字列 from文字列 limit [置換先 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   先頭4引数は必須。limit は空文字列、または符号付き10進整数（先行ゼロなし）。
##   空の limit は元文字列長（全置換）、負数は後方からの置換を表す。
##   置換先は分割済みの位置パラメータで渡し、空文字・複数文字も許可する。
##   from 内の最初の一致位置で対応する置換先を参照する。
##   一致位置の直前部分に空白を1文字足し、その文字列長を1始まりの添字とする。
##   対応する位置パラメータが未設定なら空文字として扱い、対象文字を削除する。
##   置換先の文字列は再走査せず、置換回数は元の文字への一致回数とする。
##   バインド形式で置換結果と置換回数を取得できる。
##   回数の加算は __sx_num_add1_nat0 に委譲し、算術域を超える値も扱う。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_str Q_from Q_out Q_lim Q_cnt Q_pre Q_suf Q_from_pre Q_idx Q_abs|])dnl

__sx_str_tr0() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2}"
	Q_from="${3}"
	Q_out=
	Q_lim="${4:-${#Q_str}}"
	Q_abs="${Q_lim#[+-]}"
	Q_cnt=0

	# 固定引数を保存したので、置換先だけを添字で参照する。
	shift 4

	case "${Q_lim}" in
		-*)
			while M_STR_NE([|"${Q_cnt}"|], [|"${Q_abs}"|]) && M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]); do
				Q_suf="${Q_str##*["${Q_from}"]}"
				Q_str="${Q_str%"${Q_suf}"}"
				Q_pre="${Q_str%?}"
				Q_from_pre=" ${Q_from%%"${Q_str##"${Q_pre}"}"*}"
				Q_idx="${#Q_from_pre}"
				Q_str="${Q_pre}"

				eval "Q_out=\"\${${Q_idx}-}\${Q_suf}\${Q_out}\""

				__sx_num_add1_nat0 Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${Q_bind}" "${Q_str}${Q_out}" "${Q_cnt}"
			;;
		*)
			while M_STR_NE([|"${Q_cnt}"|], [|"${Q_abs}"|]) && M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]); do
				Q_pre="${Q_str%%["${Q_from}"]*}"
				Q_str="${Q_str#"${Q_pre}"}"
				Q_suf="${Q_str#?}"
				Q_from_pre=" ${Q_from%%"${Q_str%%"${Q_suf}"}"*}"
				Q_idx="${#Q_from_pre}"
				Q_str="${Q_suf}"

				eval "Q_out=\"\${Q_out}\${Q_pre}\${${Q_idx}-}\""

				__sx_num_add1_nat0 Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${Q_bind}" "${Q_out}${Q_str}" "${Q_cnt}"
			;;
	esac || :

	unset CLEANUP
}
|], [|str_tr0|])dnl
popdef([|CLEANUP|])dnl
