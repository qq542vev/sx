M_REQUIRE([|__sx_str_tr|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_swapcase - ラテン文字の大文字と小文字を反転する（内部用）
##
## 使い方:
##   __sx_str_swapcase 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   sx_str_swapcase の内部実装。引数チェックは行わない。
__sx_str_swapcase() {
	__sx_str_tr "${1}:" "${2-}" "M_STR_UPPER()[||]M_STR_LOWER()" "M_STR_LOWER()[||]M_STR_UPPER()" ${3+"${3}"}
}

popdef([|CLEANUP|])dnl
