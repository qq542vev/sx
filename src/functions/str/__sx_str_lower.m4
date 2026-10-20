dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_LOWER SX_STR_UPPER __sx_str_tr|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_lower - 文字列内のラテン大文字を小文字に変換する（内部用）
##
## 使い方:
##   __sx_str_lower 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   sx_str_lower の内部実装。引数チェックは行わない。
__sx_str_lower() {
	__sx_str_tr "${1}:" "${2-}" "${SX_STR_UPPER}" "${SX_STR_LOWER}" ${3+"${3}"}
}

popdef([|CLEANUP|])dnl
