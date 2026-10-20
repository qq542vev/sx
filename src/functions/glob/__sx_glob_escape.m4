dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_str_escape|])dnl
pushdef([|CLEANUP|])dnl
### __sx_glob_escape - 文字列内の glob 特殊文字をエスケープする（内部用）
##
## 使い方:
##   __sx_glob_escape 結果変数名 文字列
##
## 説明:
##   sx_glob_escape の内部実装。引数チェックは行わない。
__sx_glob_escape() {
	__sx_str_escape "${1}" "${2-}" '*?[' '[' ']' || return
}

# ========================================
#  ARR (Array Operations)
# ========================================

popdef([|CLEANUP|])dnl
