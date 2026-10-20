M_REQUIRE([|SX_STR_BLANK sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_blank - すべての引数が空白文字（タブ, スペース）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_blank [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて空白文字のみで構成されている (SX_EX_OK)
##    1  空白文字以外が含まれる、または空文字列が含まれる
sx_str_is_blank() {
	sx_str_is_of "${SX_STR_BLANK}" "${@}" || return
}

popdef([|CLEANUP|])dnl
