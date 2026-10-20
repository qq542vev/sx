dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_len - 引数の個数を取得する（内部用）
##
## 使い方:
##   __sx_arg_len 結果変数名 [引数 ...]
##
## 説明:
##   引数チェックを行わずに個数の取得を行う。

define([|CLEANUP|], [|Q_res|])dnl

__sx_arg_len() {
	Q_res="${1}"
	shift
	M_VAR_SET([|${Q_res}|], [|${#}|])
	unset CLEANUP
}
|], [|arg_len|])dnl
popdef([|CLEANUP|])dnl
