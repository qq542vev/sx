M_REQUIRE([|SX_STR_DIGIT sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_digit - すべての引数が数字のみで構成されている（空でない）か確認する
##
## 使い方:
##   sx_str_is_digit [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて数字のみで構成されている (SX_EX_OK)
##    1  数字以外が含まれる、または空文字列が含まれる
sx_str_is_digit() {
	sx_str_is_of "${SX_STR_DIGIT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
