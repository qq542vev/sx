dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SPACE sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_space - すべての引数が空白文字（タブ, 改行, 垂直タブ, 改ページ, 復帰, スペース）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_space [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて空白文字のみで構成されている (SX_EX_OK)
##    1  空白文字以外が含まれる、または空文字列が含まれる
sx_str_is_space() {
	sx_str_is_of "${SX_STR_SPACE}" "${@}" || return
}

popdef([|CLEANUP|])dnl
