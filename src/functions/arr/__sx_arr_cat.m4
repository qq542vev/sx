M_REQUIRE([|__sx_arr_bind __sx_arr_bind_commit __sx_num_add1_nat0 __sx_var_to_ebind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_cat - 配列連結の内部実装
##
## 使い方:
##   __sx_arr_cat bind arr1 [arr2 ...]
##
## 説明:
##   sx_arr_cat の本体実装（chain 構築・一括書き込み・コミット）。
##   引数チェック（bind 形式・変数名・配列判定・書き込み権限）は行わない。

define([|CLEANUP|], [|Q_bind Q_chain Q_borg Q_arr Q_len Q_i|])dnl

__sx_arr_cat() {
	__sx_var_to_ebind Q_bind "${1}"
	Q_borg="${Q_bind}"
	Q_chain=
	shift

	# 1) 要素ストリームを1つずつ __sx_arr_bind で処理し、chain を構築する（読み取りのみ）
	for Q_arr in "${@}"; do
		eval "Q_len=\"\${${Q_arr}_len}\""
		Q_i=0

		while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
			__sx_arr_bind Q_bind Q_chain "${Q_bind}" "${Q_arr}_${Q_i}" || break 2
			M_NUM_INCRM1([|Q_i|])
		done
	done

	# 2) chain 適用とコミット: bind_org と残り bind の後方比較を __sx_arr_bind_commit に委譲する
	eval __sx_arr_bind_commit '"${Q_borg}"' '"${Q_bind}"' "${Q_chain}"

	unset CLEANUP
}
|], [|arr_cat|])dnl
popdef([|CLEANUP|])dnl
