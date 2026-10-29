M_REQUIRE([|__sx_str_is_nonascii|])dnl
### sx_str_is_nonascii - すべての引数が非ASCII文字のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_nonascii [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_nonascii に委譲する。
##   ASCII文字を含まない、空でない文字列を受理する。
##   UTF-8の日本語なども対象とし、文字の範囲を0x80-0xFFに限定しない。
##   引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて非ASCII文字のみで構成されている、または引数がない (SX_EX_OK)
##    1  ASCII文字が含まれる、または空文字列が含まれる

sx_str_is_nonascii() {
	M_CFG_CHECK([|sx_str_is_nonascii|])

	__sx_str_is_nonascii "${@}" || return
}
