dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_XDIGIT sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_hex - すべての引数が16進数文字（0-9, a-f, A-F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_hex [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて16進数文字のみで構成されている (SX_EX_OK)
##    1  16進数文字以外が含まれる、または空文字列が含まれる
sx_str_is_hex() {
	sx_str_is_of "${SX_STR_XDIGIT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
