M_REQUIRE([|__sx_str_is_sword|])dnl
### sx_str_is_sword - すべての引数が英字とアンダースコアのみで構成されているか確認する
##
## 使い方:
##   sx_str_is_sword [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_sword に委譲する。
##   受理する文字集合は SX_STR_SWORD と同じ英字（A-Z, a-z）と _。
##
## 終了ステータス:
##    0  すべて英字とアンダースコアのみで構成されている (SX_EX_OK)
##    1  それ以外の文字が含まれる、または空文字列が含まれる

sx_str_is_sword() {
	M_CFG_CHECK([|sx_str_is_sword|])

	__sx_str_is_sword "${@}" || return
}
