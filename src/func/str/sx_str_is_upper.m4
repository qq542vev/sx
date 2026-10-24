M_REQUIRE([|SX_STR_UPPER sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_upper - すべての引数が大文字英字（A-Z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_upper [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて大文字英字のみで構成されている (SX_EX_OK)
##    1  大文字英字以外が含まれる、または空文字列が含まれる
sx_str_is_upper() {
	sx_str_is_of "${SX_STR_UPPER}" "${@}" || return
}

popdef([|CLEANUP|])dnl
