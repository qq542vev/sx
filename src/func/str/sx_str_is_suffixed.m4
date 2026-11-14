M_REQUIRE([|__sx_str_is_suffixed|])dnl
### sx_str_is_suffixed - すべての文字列が指定された接尾辞で終わっているか確認する
##
## 使い方:
##   sx_str_is_suffixed 接尾辞 [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_suffixed に委譲する。
##
## 終了ステータス:
##    0  すべて接尾辞で終わっている、または文字列が 0 個 (SX_EX_OK)
##    1  いずれかが接尾辞で終わっていない

sx_str_is_suffixed() {
	M_CFG_CHECK([|sx_str_is_suffixed|])

	__sx_str_is_suffixed "${@}" || return
}
