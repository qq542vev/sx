dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_add1_arith __sx_num_add1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_isep_lit - 指定境界にリテラルを挿入する（内部用）
##
## 使い方:
##   __sx_str_isep_lit bind str sep abs lim type qm dir start end
##
## 説明:
##   内部実装。引数チェックは行わない。
##   変更しない引数は位置パラメータで参照し、残余文字列・出力・回数だけ変数で保持する。
##   上限0は呼び出し元で処理済みなので、開始端では上限判定をせず回数を1にする。
##   回数は上限に達するまで1ずつ増えるので、上限判定は文字列一致で行う。
##   パターンの空判定はループ前に一度だけ行い、上限到達時はパターン照合を省く。
##   反対側の端の境界は、残余長が間隔と等しいかで判定する。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_str Q_out Q_cnt|])dnl

__sx_str_isep_lit() {
	# 1:バインド形式 2:文字列 3:セパレータ 4:間隔絶対値 5:上限
	# 6:数値経路 7:?パターン 8:方向 9:開始端 10:終了端
	__sx_var_bind_init "${1}"
	Q_str="${2}"

	case "${9}" in
		0) Q_out= Q_cnt=0;;
		*) Q_out="${3}" Q_cnt=1;;
	esac

	case "${8}${7}" in
		0?*)
			while M_STR_NE([|"${Q_cnt}"|], [|"${5}"|]) && M_STR_MATCH([|"${Q_str}"|], [|${7}?*|]); do
				M_STR_APPEND([|Q_out|], [|"${Q_str%"${Q_str#${7}}"}${3}"|])
				Q_str="${Q_str#${7}}"
				"__sx_num_add1_${6}" Q_cnt "${Q_cnt}"
			done
			;&
		0) M_STR_APPEND([|Q_out|], [|"${Q_str}"|]);;
		1?*)
			while M_STR_NE([|"${Q_cnt}"|], [|"${5}"|]) && M_STR_MATCH([|"${Q_str}"|], [|${7}?*|]); do
				M_STR_PREPEND([|Q_out|], [|"${3}${Q_str#"${Q_str%${7}}"}"|])
				Q_str="${Q_str%${7}}"
				"__sx_num_add1_${6}" Q_cnt "${Q_cnt}"
			done
			;&
		1) M_STR_PREPEND([|Q_out|], [|"${Q_str}"|]);;
	esac

	case "${10}${Q_cnt}:${4}" in
		0* | ?${5}:*) __sx_var_bind '' "${1}" "${Q_out}" "${Q_cnt}";;
		*:${#Q_str})
			"__sx_num_add1_${6}" Q_cnt "${Q_cnt}"

			case "${8}" in
				0) __sx_var_bind '' "${1}" "${Q_out}${3}" "${Q_cnt}";;
				1) __sx_var_bind '' "${1}" "${3}${Q_out}" "${Q_cnt}";;
			esac
			;;
		*) __sx_var_bind '' "${1}" "${Q_out}" "${Q_cnt}";;
	esac || :

	unset CLEANUP
}
|], [|str_isep_lit|])dnl
popdef([|CLEANUP|])dnl
