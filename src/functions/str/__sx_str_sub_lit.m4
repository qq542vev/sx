M_REQUIRE([|__sx_num_add1_arith __sx_num_add1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_sub_lit - 非空パターンをリテラル/Glob置換する（内部用）
##
## 使い方:
##   __sx_str_sub_lit bind str pat rep lim glob type dir
##
## 説明:
##   内部実装。引数チェックは行わない。
##   lim は符号なし10進整数または空文字列、dir は 1（前方）/-1（後方）。
##   上限判定は置換回数との文字列一致で行う。
##   バインド形式で置換結果と置換回数を取得できる。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_str Q_out Q_cnt|])dnl

__sx_str_sub_lit() {
	# 1:バインド形式 2:元文字列 3:検索パターン 4:置換文字列
	# 5:回数上限（空は無制限）6:Globフラグ 7:数値経路（arith/nat0）8:方向（1:前方/-1:後方）
	__sx_var_bind_init "${1}"
	Q_str="${2}" Q_out='' Q_cnt=0

	case "${8}:${6}" in
		1:0)
			while M_STR_NE([|"${Q_cnt}"|], [|"${5}"|]) && M_STR_HAS([|"${Q_str}"|], [|"${3}"|]); do
				M_STR_APPEND([|Q_out|], [|"${Q_str%%"${3}"*}${4}"|])
				Q_str="${Q_str#*"${3}"}"
				"__sx_num_add1_${7}" Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${1}" "${Q_out}${Q_str}" "${Q_cnt}"
			;;
		1:*)
			while M_STR_NE([|"${Q_cnt}"|], [|"${5}"|]) && M_STR_HAS([|"${Q_str}"|], [|${3}|]); do
				M_STR_APPEND([|Q_out|], [|"${Q_str%%${3}*}${4}"|])
				Q_str="${Q_str#*${3}}"
				"__sx_num_add1_${7}" Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${1}" "${Q_out}${Q_str}" "${Q_cnt}"
			;;
		*:0)
			while M_STR_NE([|"${Q_cnt}"|], [|"${5}"|]) && M_STR_HAS([|"${Q_str}"|], [|"${3}"|]); do
				M_STR_PREPEND([|Q_out|], [|"${4}${Q_str##*"${3}"}"|])
				Q_str="${Q_str%"${3}"*}"
				"__sx_num_add1_${7}" Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${1}" "${Q_str}${Q_out}" "${Q_cnt}"
			;;
		*:*)
			while M_STR_NE([|"${Q_cnt}"|], [|"${5}"|]) && M_STR_HAS([|"${Q_str}"|], [|${3}|]); do
				M_STR_PREPEND([|Q_out|], [|"${4}${Q_str##*${3}}"|])
				Q_str="${Q_str%${3}*}"
				"__sx_num_add1_${7}" Q_cnt "${Q_cnt}"
			done

			__sx_var_bind '' "${1}" "${Q_str}${Q_out}" "${Q_cnt}"
			;;
	esac || :

	unset CLEANUP
}
|], [|str_sub_lit|])dnl
popdef([|CLEANUP|])dnl
