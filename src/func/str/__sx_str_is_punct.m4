M_REQUIRE([|SX_STR_PUNCT __sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_is_punct - すべての引数が区切り記号（!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~）のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_punct [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて区切り記号のみで構成されている (SX_EX_OK)
##    1  区切り記号以外が含まれる、または空文字列が含まれる

__sx_str_is_punct() {
	__sx_str_is_of "${SX_STR_PUNCT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
