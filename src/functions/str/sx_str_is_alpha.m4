dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_ALPHA sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_alpha - すべての引数が英字（A-Z, a-z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_alpha [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて英字のみで構成されている (SX_EX_OK)
##    1  英字以外が含まれる、または空文字列が含まれる
sx_str_is_alpha() {
	sx_str_is_of "${SX_STR_ALPHA}" "${@}" || return
}

popdef([|CLEANUP|])dnl
