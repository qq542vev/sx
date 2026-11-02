M_REQUIRE([|__sx_str_tr0|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_upper - 文字列内のラテン小文字を大文字に変換する（内部用）
##
## 使い方:
##   __sx_str_upper 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   sx_str_upper の内部実装。引数チェックは行わない。
__sx_str_upper() {
	__sx_str_tr0 "${1}:" "${2-}" "M_STR_LOWER()" "${3-}" M_STR_UPPER_ARGS()
}

popdef([|CLEANUP|])dnl
