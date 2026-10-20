M_REQUIRE([|__sx_arg_isep_lit __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_quote|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_isep_rcb - 後方の挿入境界でコールバックを実行する
##
## 使い方:
##   __sx_arg_isep_rcb bind cb abs type first count size [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   コールバックを右から実行し、成功した各境界の結果を逆順に保存する。
##   未設定の結果は空のマーカー、設定済みの結果は先頭に ':' を付けて保存する。
##   スキップした境界も保持するため、後続の挿入位置と元の値はずれない。
##   状態を位置パラメータに保存し、一時変数を解放してからコールバックを呼ぶ。
##   終了後は __sx_arg_isep_lit で元の値とともに左からバインドする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス

define([|CLEANUP|], [|Q_cnt Q_skip Q_out Q_bind Q_cb Q_abs Q_type Q_pos Q_left Q_ret Q_stat|])dnl

__sx_arg_isep_rcb() {
	# 1:回数 2:skip 3:クォート済みマーカー列 4:成功済み最左境界 5:bind 6:cb
	# 7:間隔 8:数値経路 9:次の境界 10:残り境界数 11:元の個数 12以降:元の値
	set -- 0 0 '' 0 "${@}"

	while M_STR_NE([|"${10}"|], [|0|]); do
		"__sx_num_add1_${8}" Q_cnt "${1}"
		Q_bind="${5}" Q_cb="${6}" Q_out="${3}"
		eval 'shift 11;' set -- "${Q_cnt}" "${2}" '"${Q_out}"' "${4}" '"${Q_bind}"' '"${Q_cb}"' "${7}" "${8}" "${9}" "${10}" "${11}" '"${@}"'
		unset CLEANUP

		"${6}" Q_ret "${9}" "${1}" "${2}" || {
			Q_stat="${?}"
			"__sx_num_sub1_${8}" Q_cnt "${1}"
			break
		}

		Q_skip="${2}"
		case "${Q_ret+X}" in '') "__sx_num_add1_${8}" Q_skip "${Q_skip}";; esac
		__sx_str_quote Q_ret "${Q_ret+:}${Q_ret-}"
		Q_out="${Q_ret} ${3}" Q_bind="${5}" Q_cb="${6}" Q_pos="${9}"
		"__sx_num_sub1_${8}" Q_left "${10}"
		case "${Q_left}" in 0) ;; *) "__sx_num_sub_${8}" Q_pos "${Q_pos}" "${7}";; esac

		eval 'shift 11;' set -- "${1}" "${Q_skip}" '"${Q_out}"' "${9}" '"${Q_bind}"' '"${Q_cb}"' "${7}" "${8}" "${Q_pos}" "${Q_left}" "${11}" '"${@}"'
		unset CLEANUP
	done

	Q_cnt="${Q_cnt-${1}}" Q_stat="${Q_stat-0}"
	Q_bind="${5}" Q_abs="${7}" Q_type="${8}" Q_pos="${4}" Q_out="${3}"
	shift 11
	# マーカー列は __sx_str_quote 済み。元の値は再評価せず位置パラメータで渡す。
	eval __sx_arg_isep_lit '"${Q_bind}"' "''" '"${Q_abs}"' '"${Q_type}"' '"${Q_pos}"' '"${Q_cnt}"' '"${Q_cnt}"' "${Q_out}" '"${@}"'

	set -- "${Q_stat}"
	unset CLEANUP
	return "${1}"
}
|], [|arg_isep_rcb|])dnl
popdef([|CLEANUP|])dnl
