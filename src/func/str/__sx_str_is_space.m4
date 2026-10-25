M_REQUIRE([|SX_STR_SPACE __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_space - すべての引数が空白文字（タブ, 改行, 垂直タブ, 改ページ, 復帰, スペース）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_space [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて空白文字のみで構成されている (SX_EX_OK)
##    1  空白文字以外が含まれる、または空文字列が含まれる

__sx_str_is_space() {
	__sx_str_is_of "${SX_STR_SPACE}" "${@}" || return
}

popdef([|CLEANUP|])dnl
