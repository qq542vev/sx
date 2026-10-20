dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_quote - 引数をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_quote スキーマ [値 ...]
##
## 説明:
##   引数チェックを行わずに分配代入およびクォート結合処理を行う。

define([|CLEANUP|], [|Q_bind|])dnl

__sx_arg_quote() {
	__sx_var_bind_init "${1}"
	__sx_var_bind Q_bind "${@}" || :

	unset CLEANUP
}
|], [|arg_quote|])dnl
popdef([|CLEANUP|])dnl
