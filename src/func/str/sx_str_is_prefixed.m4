M_REQUIRE([|__sx_str_is_prefixed|])dnl
### sx_str_is_prefixed - すべての文字列が指定された接頭辞で始まっているか確認する
##
## 使い方:
##   sx_str_is_prefixed 接頭辞 [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_prefixed に委譲する。
##
## 終了ステータス:
##    0  すべて接頭辞で始まっている、または文字列が 0 個 (SX_EX_OK)
##    1  いずれかが接頭辞で始まっていない

sx_str_is_prefixed() {
	M_CFG_CHECK([|sx_str_is_prefixed|])

	__sx_str_is_prefixed "${@}" || return
}
