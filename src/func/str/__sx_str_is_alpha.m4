M_REQUIRE([|SX_STR_ALPHA __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_alpha - すべての引数が英字（A-Z, a-z）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_alpha [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて英字のみで構成されている (SX_EX_OK)
##    1  英字以外が含まれる、または空文字列が含まれる

__sx_str_is_alpha() {
	__sx_str_is_of "${SX_STR_ALPHA}" "${@}" || return
}

popdef([|CLEANUP|])dnl
