M_REQUIRE([|__sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_byte - すべての引数がバイト集合（0x01-0xFF）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_byte [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   ASCII集合と非ASCII集合を合わせた全255値（0x01-0xFF）を対象とする。
##   NULは集合に含めない。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべてバイト集合のみで構成されている、または引数がない (SX_EX_OK)
##    1  バイト集合以外の文字が含まれる、または空文字列が含まれる

__sx_str_is_byte() {
	__sx_str_is_of $'M_STR_BYTE' "${@}" || return
}

popdef([|CLEANUP|])dnl
