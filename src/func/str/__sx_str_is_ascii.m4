M_REQUIRE([|SX_STR_ASCII __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_ascii - すべての引数がASCII文字（0x00-0x7F）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_ascii [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべてASCII文字のみで構成されている (SX_EX_OK)
##    1  ASCII文字以外が含まれる、または空文字列が含まれる

__sx_str_is_ascii() {
	__sx_str_is_of "${SX_STR_ASCII}" "${@}" || return
}

popdef([|CLEANUP|])dnl
