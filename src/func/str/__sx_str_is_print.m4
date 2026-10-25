M_REQUIRE([|SX_STR_PRINT __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_print - すべての引数が表示可能文字（図形文字 + スペース）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_print [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて表示可能文字のみで構成されている (SX_EX_OK)
##    1  表示可能文字以外が含まれる、または空文字列が含まれる

__sx_str_is_print() {
	__sx_str_is_of "${SX_STR_PRINT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
