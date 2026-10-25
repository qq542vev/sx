M_REQUIRE([|__sx_str_is_print|])dnl
### sx_str_is_print - すべての引数が表示可能文字（図形文字 + スペース）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_print [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_print に委譲する。
##
## 終了ステータス:
##    0  すべて表示可能文字のみで構成されている (SX_EX_OK)
##    1  表示可能文字以外が含まれる、または空文字列が含まれる

sx_str_is_print() {
	M_CFG_CHECK([|sx_str_is_print|])

	__sx_str_is_print "${@}" || return
}
