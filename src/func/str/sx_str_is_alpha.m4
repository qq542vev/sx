M_REQUIRE([|__sx_str_is_alpha|])dnl
### sx_str_is_alpha - すべての引数が英字（A-Z, a-z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_alpha [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_alpha に委譲する。
##
## 終了ステータス:
##    0  すべて英字のみで構成されている (SX_EX_OK)
##    1  英字以外が含まれる、または空文字列が含まれる

sx_str_is_alpha() {
	M_CFG_CHECK([|sx_str_is_alpha|])

	__sx_str_is_alpha "${@}" || return
}
