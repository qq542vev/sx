M_REQUIRE([|SX_STR_XDIGIT __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_hex - すべての引数が16進数文字（0-9, a-f, A-F）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_hex [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて16進数文字のみで構成されている (SX_EX_OK)
##    1  16進数文字以外が含まれる、または空文字列が含まれる

__sx_str_is_hex() {
	__sx_str_is_of "${SX_STR_XDIGIT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
