M_REQUIRE([|__sx_str_is_space|])dnl
### sx_str_is_space - すべての引数が空白文字（タブ, 改行, 垂直タブ, 改ページ, 復帰, スペース）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_space [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_space に委譲する。
##
## 終了ステータス:
##    0  すべて空白文字のみで構成されている (SX_EX_OK)
##    1  空白文字以外が含まれる、または空文字列が含まれる

sx_str_is_space() {
	M_CFG_CHECK([|sx_str_is_space|])

	__sx_str_is_space "${@}" || return
}
