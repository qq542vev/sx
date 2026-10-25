M_REQUIRE([|SX_STR_ALNUM __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_alnum - すべての引数が英数字（A-Z, a-z, 0-9）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_alnum [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて英数字のみで構成されている (SX_EX_OK)
##    1  英数字以外が含まれる、または空文字列が含まれる

__sx_str_is_alnum() {
	__sx_str_is_of "${SX_STR_ALNUM}" "${@}" || return
}

popdef([|CLEANUP|])dnl
