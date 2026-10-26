M_REQUIRE([|__sx_str_is_alund|])dnl
### sx_str_is_alund - すべての引数が英字とアンダースコアのみで構成されているか確認する
##
## 使い方:
##   sx_str_is_alund [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_alund に委譲する。
##   受理する文字集合は SX_STR_ALUND と同じ英字（A-Z, a-z）と _。
##
## 終了ステータス:
##    0  すべて英字とアンダースコアのみで構成されている (SX_EX_OK)
##    1  それ以外の文字が含まれる、または空文字列が含まれる

sx_str_is_alund() {
	M_CFG_CHECK([|sx_str_is_alund|])

	__sx_str_is_alund "${@}" || return
}
