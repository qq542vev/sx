M_REQUIRE([|SX_STR_UPPER __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_upper - すべての引数が大文字英字（A-Z）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_upper [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて大文字英字のみで構成されている (SX_EX_OK)
##    1  大文字英字以外が含まれる、または空文字列が含まれる

__sx_str_is_upper() {
	__sx_str_is_of "${SX_STR_UPPER}" "${@}" || return
}

popdef([|CLEANUP|])dnl
