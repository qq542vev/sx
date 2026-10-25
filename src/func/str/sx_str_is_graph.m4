M_REQUIRE([|__sx_str_is_graph|])dnl
### sx_str_is_graph - すべての引数が図形文字（英数字 + 区切り記号）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_graph [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_graph に委譲する。
##
## 終了ステータス:
##    0  すべて図形文字のみで構成されている (SX_EX_OK)
##    1  図形文字以外が含まれる、または空文字列が含まれる

sx_str_is_graph() {
	M_CFG_CHECK([|sx_str_is_graph|])

	__sx_str_is_graph "${@}" || return
}
