M_REQUIRE([|__sx_str_is_lower|])dnl
### sx_str_is_lower - すべての引数が小文字英字（a-z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_lower [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_lower に委譲する。
##
## 終了ステータス:
##    0  すべて小文字英字のみで構成されている (SX_EX_OK)
##    1  小文字英字以外が含まれる、または空文字列が含まれる

sx_str_is_lower() {
	M_CFG_CHECK([|sx_str_is_lower|])

	__sx_str_is_lower "${@}" || return
}
