M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_escape_all - 文字列の各文字を指定文字列で囲む（内部用）
##
## 使い方:
##   __sx_str_escape_all 結果変数名 [元文字列 [開始文字列 [終了文字列]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   元文字列をロケール上の1文字ずつに分け、各文字を開始文字列と終了文字列で囲む。
##   文字列・開始文字列・終了文字列の省略は空文字列として扱う。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
define([|CLEANUP|], [|Q_str Q_pref Q_suf Q_char Q_out|])dnl
__sx_str_escape_all() {
	Q_str="${2-}"
	Q_pref="${3-}"
	Q_suf="${4-}"
	Q_out=

	while M_STR_NE([|"${Q_str}"|], [|''|]); do
		Q_char="${Q_str%%"${Q_str#?}"}"
		Q_str="${Q_str#?}"
		M_STR_APPEND([|Q_out|], [|"${Q_pref}${Q_char}${Q_suf}"|])
	done

	M_VAR_SET([|${1}|], [|${Q_out}|])
	unset CLEANUP
}
|], [|str_escape_all|])dnl
popdef([|CLEANUP|])dnl
