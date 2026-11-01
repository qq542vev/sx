M_REQUIRE([|__sx_num_add1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
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
##   to を1文字ずつ位置パラメータに格納し、from 内の最初の一致位置で参照する。
##   一致位置の直前部分に空白を1文字足し、その文字列長を1始まりの添字とする。
##   対応する位置パラメータが未設定なら空文字として扱い、対象文字を削除する。
##   回数の加算は __sx_num_add1_nat0 に委譲し、算術域を超える値も扱う。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_str Q_from Q_to Q_out Q_lim Q_cnt Q_pre Q_suf Q_from_pre Q_idx Q_abs|])dnl

__sx_str_tr() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2-}"
	Q_from="${3-}"
	Q_out=
	Q_lim="${5:-${#Q_str}}"
	Q_abs="${Q_lim#[+-]}"
	Q_cnt=0

	case "${Q_abs}:${Q_str}" in ${Q_from:+[!0]*:*["${Q_from}"]*}) ;; *)
		__sx_var_bind '' "${Q_bind}" "${Q_str}" 0 || :
		unset CLEANUP
		return
	esac

	Q_to="${4-}"
	set --
	while M_STR_NE([|"${Q_to:+X}"|], [|''|]); do
		set -- "${@}" "${Q_to%%"${Q_to#?}"}"
		Q_to="${Q_to#?}"
	done

	case "${Q_lim}" in
		-*)
			while
				Q_suf="${Q_str##*["${Q_from}"]}"
				Q_str="${Q_str%"${Q_suf}"}"
				Q_pre="${Q_str%?}"
				Q_from_pre=" ${Q_from%%"${Q_str#"${Q_pre}"}"*}"
				Q_idx="${#Q_from_pre}"
				Q_str="${Q_pre}"

				eval "Q_out=\"\${${Q_idx}-}\${Q_suf}\${Q_out}\""

				__sx_num_add1_nat0 Q_cnt "${Q_cnt}"

				if M_STR_NE([|"${Q_cnt}"|], [|"${Q_abs}"|]) && M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]); then
					continue
				fi

				break
			do :; done

			__sx_var_bind '' "${Q_bind}" "${Q_str}${Q_out}" "${Q_cnt}"
			;;
		*)
			while
				Q_pre="${Q_str%%["${Q_from}"]*}"
				Q_str="${Q_str#"${Q_pre}"}"
				Q_suf="${Q_str#?}"
				Q_from_pre=" ${Q_from%%"${Q_str%"${Q_suf}"}"*}"
				Q_idx="${#Q_from_pre}"
				Q_str="${Q_suf}"

				eval "Q_out=\"\${Q_out}\${Q_pre}\${${Q_idx}-}\""

				__sx_num_add1_nat0 Q_cnt "${Q_cnt}"

				if M_STR_NE([|"${Q_cnt}"|], [|"${Q_abs}"|]) && M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]); then
					continue
				fi

				break
			do :; done

			__sx_var_bind '' "${Q_bind}" "${Q_out}${Q_str}" "${Q_cnt}"
			;;
	esac || :

	unset CLEANUP
}
|], [|str_tr|])dnl
popdef([|CLEANUP|])dnl
