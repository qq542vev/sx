dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_arg_find __sx_arg_len|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_count - 引数リストから指定された値の出現回数を取得する（内部用）
##
## 使い方:
##   __sx_arg_count 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##   __sx_arg_count 結果変数名 [検索対象 [値 ...]]
##
## 説明:
##   sx_arg_count の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_tmp|])dnl

__sx_arg_count() {
	Q_res="${1}"
	shift

	__sx_arg_find Q_tmp "${@}" || :

	eval __sx_arg_len "${Q_res}" "${Q_tmp}"

	unset CLEANUP
}
|], [|arg_count|])dnl
popdef([|CLEANUP|])dnl
