M_REQUIRE([|__sx_str_is_gr|])dnl
### sx_str_is_gr - すべての引数がGR領域のバイト（0xA0-0xFF）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_gr [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_gr に委譲する。
##   GR領域の全96値（0xA0-0xFF）を対象とする。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべてGR領域のバイトのみで構成されている、または引数がない (SX_EX_OK)
##    1  GR領域以外が含まれる、または空文字列が含まれる

sx_str_is_gr() {
	M_CFG_CHECK([|sx_str_is_gr|])

	__sx_str_is_gr "${@}" || return
}
