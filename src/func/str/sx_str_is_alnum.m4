M_REQUIRE([|SX_STR_ALNUM sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_alnum - すべての引数が英数字（A-Z, a-z, 0-9）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_alnum [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて英数字のみで構成されている (SX_EX_OK)
##    1  英数字以外が含まれる、または空文字列が含まれる
sx_str_is_alnum() {
	sx_str_is_of "${SX_STR_ALNUM}" "${@}" || return
}

popdef([|CLEANUP|])dnl
