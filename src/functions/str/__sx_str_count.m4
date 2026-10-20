dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_arg_len __sx_str_find|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_count - 文字列から指定された文字列の出現回数を取得する（内部用）
##
## 使い方:
##   __sx_str_count 結果変数名 [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_count の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_count() {
	__sx_str_find Q_tmp "${2-}" "${3-}" "${4:-0}" || :
	eval __sx_arg_len '"${1}"' "${Q_tmp}"
	unset CLEANUP
}
|], [|str_count|])dnl
popdef([|CLEANUP|])dnl
