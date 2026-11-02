M_REQUIRE([|__sx_str_tr0|])dnl
pushdef([|CLEANUP|])dnl
### __sx_glob_esc - 文字列内の glob 特殊文字をエスケープする（内部用）
##
## 使い方:
##   __sx_glob_esc 結果変数名 文字列
##
## 説明:
##   sx_glob_esc の内部実装。引数チェックは行わない。
##   M_GLOB_SP_NORM の各文字を [*] [?] [[] [\\] に置換する。
##
## 終了ステータス:
##    0  成功
__sx_glob_esc() {
	__sx_str_tr0 "${1}:" "${2-}" M_SH_QUOTE(M_GLOB_SP_NORM) '' '[*]' '[?]' '[[]' '[\\]'
}
popdef([|CLEANUP|])dnl
