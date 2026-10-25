M_REQUIRE([|SX_STR_GRAPH __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_graph - すべての引数が図形文字（英数字 + 区切り記号）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_graph [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて図形文字のみで構成されている (SX_EX_OK)
##    1  図形文字以外が含まれる、または空文字列が含まれる

__sx_str_is_graph() {
	__sx_str_is_of "${SX_STR_GRAPH}" "${@}" || return
}

popdef([|CLEANUP|])dnl
