M_REQUIRE([|__sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_c0 - すべての引数がNULを除くC0領域（0x01-0x1F）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_c0 [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   NULを除くC0領域の全31値（0x01-0x1F）を対象とし、DELは含めない。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて対象のC0領域のみで構成されている、または引数がない (SX_EX_OK)
##    1  対象のC0領域以外が含まれる、または空文字列が含まれる

__sx_str_is_c0() {
	__sx_str_is_of M_SH_QUOTE(M_STR_C0) "${@}" || return
}

popdef([|CLEANUP|])dnl
