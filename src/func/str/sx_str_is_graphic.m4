M_REQUIRE([|__sx_str_is_graphic|])dnl
### sx_str_is_graphic - すべての引数がASCII図形領域とGR領域のバイトのみで構成されているか確認する
##
## 使い方:
##   sx_str_is_graphic [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_graphic に委譲する。
##   ASCII図形領域（0x21-0x7E）とGR領域（0xA0-0xFF）の全190値を対象とする。
##   ASCIIのスペースは含めない。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて対象の図形領域のバイトのみで構成されている、または引数がない (SX_EX_OK)
##    1  対象の図形領域以外が含まれる、または空文字列が含まれる

sx_str_is_graphic() {
	M_CFG_CHECK([|sx_str_is_graphic|])

	__sx_str_is_graphic "${@}" || return
}
