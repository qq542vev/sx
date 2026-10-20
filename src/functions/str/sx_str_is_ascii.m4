dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_ASCII sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_ascii - すべての引数がASCII文字（0x00-0x7F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_ascii [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべてASCII文字のみで構成されている (SX_EX_OK)
##    1  ASCII文字以外が含まれる、または空文字列が含まれる
sx_str_is_ascii() {
	sx_str_is_of "${SX_STR_ASCII}" "${@}" || return
}

popdef([|CLEANUP|])dnl
