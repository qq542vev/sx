dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_LOWER sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_lower - すべての引数が小文字英字（a-z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_lower [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて小文字英字のみで構成されている (SX_EX_OK)
##    1  小文字英字以外が含まれる、または空文字列が含まれる
sx_str_is_lower() {
	sx_str_is_of "${SX_STR_LOWER}" "${@}" || return
}

popdef([|CLEANUP|])dnl
