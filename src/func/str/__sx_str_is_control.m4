M_REQUIRE([|__sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_control - すべての引数がC0・C1・DELのみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_control [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   0x01-0x1Fと0x7F-0x9Fを対象とし、C0・C1・DELの混在も受理する。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべてC0・C1・DELのみで構成されている、または引数がない (SX_EX_OK)
##    1  範囲外が含まれる、または空文字列が含まれる

__sx_str_is_control() {
	__sx_str_is_of $'M_STR_CONTROL' "${@}" || return
}

popdef([|CLEANUP|])dnl
