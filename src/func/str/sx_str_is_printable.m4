M_REQUIRE([|__sx_str_is_printable|])dnl
### sx_str_is_printable - すべての引数がASCII印字領域とGR領域のバイトのみで構成されているか確認する
##
## 使い方:
##   sx_str_is_printable [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_printable に委譲する。
##   ASCII印字領域（0x20-0x7E）とGR領域（0xA0-0xFF）の全191値を対象とする。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて対象の印字領域のバイトのみで構成されている、または引数がない (SX_EX_OK)
##    1  対象の印字領域以外が含まれる、または空文字列が含まれる

sx_str_is_printable() {
	M_CFG_CHECK([|sx_str_is_printable|])

	__sx_str_is_printable "${@}" || return
}
