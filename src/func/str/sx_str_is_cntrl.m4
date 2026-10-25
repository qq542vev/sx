M_REQUIRE([|__sx_str_is_cntrl|])dnl
### sx_str_is_cntrl - すべての引数が制御文字（0x01-0x1F, 0x7F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_cntrl [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_cntrl に委譲する。
##
## 終了ステータス:
##    0  すべて制御文字のみで構成されている (SX_EX_OK)
##    1  制御文字以外が含まれる、または空文字列が含まれる

sx_str_is_cntrl() {
	M_CFG_CHECK([|sx_str_is_cntrl|])

	__sx_str_is_cntrl "${@}" || return
}
