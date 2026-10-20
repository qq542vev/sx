dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_escape_cb - sx_str_escape 用コールバック（内部用）
##
## 使い方:
##   __sx_str_escape_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
__sx_str_escape_cb() {
	M_VAR_SET([|${1}|], [|${Q_cb_se}${2}${Q_cb_ee}|])
}
|], [|str_escape|])dnl
popdef([|CLEANUP|])dnl
