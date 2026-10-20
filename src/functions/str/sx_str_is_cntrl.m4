dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_CNTRL sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_cntrl - すべての引数が制御文字（0x01-0x1F, 0x7F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_cntrl [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて制御文字のみで構成されている (SX_EX_OK)
##    1  制御文字以外が含まれる、または空文字列が含まれる
sx_str_is_cntrl() {
	sx_str_is_of "${SX_STR_CNTRL}" "${@}" || return
}

popdef([|CLEANUP|])dnl
