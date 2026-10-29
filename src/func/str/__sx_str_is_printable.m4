M_REQUIRE([|__sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_printable - すべての引数がASCII印字領域とGR領域のバイトのみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_printable [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   ASCII印字領域（0x20-0x7E）とGR領域（0xA0-0xFF）の全191値を対象とする。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて対象の印字領域のバイトのみで構成されている、または引数がない (SX_EX_OK)
##    1  対象の印字領域以外が含まれる、または空文字列が含まれる

__sx_str_is_printable() {
	__sx_str_is_of $'M_STR_PRINTABLE' "${@}" || return
}

popdef([|CLEANUP|])dnl
