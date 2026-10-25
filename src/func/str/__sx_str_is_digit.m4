M_REQUIRE([|SX_STR_DIGIT __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_digit - すべての引数が数字のみで構成されている（空でない）か確認する（内部用）
##
## 使い方:
##   __sx_str_is_digit [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて数字のみで構成されている (SX_EX_OK)
##    1  数字以外が含まれる、または空文字列が含まれる

__sx_str_is_digit() {
	__sx_str_is_of "${SX_STR_DIGIT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
