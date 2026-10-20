M_REQUIRE([|__sx_num_add1_arith __sx_num_add1_nat0 __sx_num_add_arith __sx_num_add_nat0 __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_var_bind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_isep_cb - 前方の挿入境界でコールバックを実行する
##
## 使い方:
##   __sx_arg_isep_cb bind cb abs type first count size [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   正規化済みの境界を左から処理し、元の値と挿入値を逐次バインドする。
##   状態を位置パラメータに保存し、一時変数を解放してからコールバックを呼ぶ。
##   末尾の空要素は終了端の処理用であり、元の値としては出力しない。
##   境界数が残っているときだけ次の位置を計算する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス

define([|CLEANUP|], [|Q_arg Q_i Q_cnt Q_skip Q_stat Q_bind Q_pos Q_left Q_ret|])dnl

__sx_arg_isep_cb() {
	# 1:位置 2:回数 3:skip 4:終了状態 5:bind 6:cb 7:間隔 8:数値経路
	# 9:次の境界 10:残り境界数 11:元の個数 12:現在の値
	set -- -12 0 0 0 "${@}"

	for Q_arg in "${@}" ''; do
		Q_i="${1}"
		case "${Q_i}" in
			-*) M_NUM_INCR([|Q_i|]);;
			*) "__sx_num_add1_${8}" Q_i "${Q_i}";;
		esac
		set -- "${Q_i}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${Q_arg}"

		case "${1}" in -*) continue;; esac
		case "${5}" in '') break;; esac

		if M_STR_EQ([|"${1}"|], [|"${9}"|]) && M_STR_NE([|"${10}"|], [|0|]); then
			"__sx_num_add1_${8}" Q_cnt "${2}"
			set -- "${1}" "${Q_cnt}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}"
			unset CLEANUP

			if "${6}" Q_ret "${1}" "${2}" "${3}"; then
				Q_bind="${5}" Q_skip="${3}" Q_stat="${4}" Q_pos="${9}"
				case "${Q_ret+X}" in
					X) __sx_var_bind Q_bind "${Q_bind}" "${Q_ret}" || :;;
					*) "__sx_num_add1_${8}" Q_skip "${Q_skip}";;
				esac
				"__sx_num_sub1_${8}" Q_left "${10}"
				case "${Q_left}" in 0) ;; *) "__sx_num_add_${8}" Q_pos "${Q_pos}" "${7}";; esac
			else
				Q_stat="${?}" Q_bind="${5}" Q_skip="${3}" Q_pos="${9}" Q_left=0
			fi

			set -- "${1}" "${2}" "${Q_skip}" "${Q_stat}" "${Q_bind}" "${6}" "${7}" "${8}" "${Q_pos}" "${Q_left}" "${11}" "${12}"
		fi

		case "${1}" in "${11}") break;; esac
		__sx_var_bind Q_bind "${5}" "${12}" || :
		set -- "${1}" "${2}" "${3}" "${4}" "${Q_bind}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}"
		unset CLEANUP
	done

	unset CLEANUP
	return "${4}"
}
|], [|arg_isep_cb|])dnl
popdef([|CLEANUP|])dnl
