M_REQUIRE([|__sx_str_is_punct|])dnl
### sx_str_is_punct - すべての引数が区切り記号（!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_punct [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_punct に委譲する。
##
## 終了ステータス:
##    0  すべて区切り記号のみで構成されている (SX_EX_OK)
##    1  区切り記号以外が含まれる、または空文字列が含まれる

sx_str_is_punct() {
	M_CFG_CHECK([|sx_str_is_punct|])

	__sx_str_is_punct "${@}" || return
}
