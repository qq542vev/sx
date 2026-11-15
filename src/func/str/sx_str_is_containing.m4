M_REQUIRE([|__sx_str_is_containing|])dnl
### sx_str_is_containing - すべての文字列が指定された部分文字列を含んでいるか確認する
##
## 使い方:
##   sx_str_is_containing 部分文字列 [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_containing に委譲する。
##   第2引数以降のすべての文字列が、第1引数で指定された部分文字列を
##   含んでいるかを確認する。
##   部分文字列が空の場合、または文字列が 0 個の場合は成功する。
##
## 終了ステータス:
##    0  すべて部分文字列を含んでいる、または文字列が 0 個 (SX_EX_OK)
##    1  いずれかが部分文字列を含んでいない

sx_str_is_containing() {
	M_CFG_CHECK([|sx_str_is_containing|])

	__sx_str_is_containing "${@}" || return
}
