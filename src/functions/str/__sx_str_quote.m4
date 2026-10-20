dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_quote - 文字列をシングルクォートで囲む（内部用）
##
## 使い方:
##   __sx_str_quote 結果変数名 [元文字列]
##
## 説明:
##   sx_str_quote の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_str Q_out|])dnl

__sx_str_quote() {
	Q_str="${2-}"
	Q_out=

	while M_STR_HAS([|"${Q_str}"|], [|"'"|]); do
		M_STR_APPEND([|Q_out|], [|"${Q_str%%"'"*}'\\''"|])
		Q_str="${Q_str#*"'"}"
	done

	eval "${1}=\"'\${Q_out}\${Q_str}'\""
	unset CLEANUP
}
|], [|str_quote|])dnl
popdef([|CLEANUP|])dnl
