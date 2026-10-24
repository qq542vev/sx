M_REQUIRE([|SX_STR_OCT sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_oct - すべての引数が8進数文字（0-7）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_oct [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて8進数文字のみで構成されている (SX_EX_OK)
##    1  8進数文字以外が含まれる、または空文字列が含まれる
sx_str_is_oct() {
	sx_str_is_of "${SX_STR_OCT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
