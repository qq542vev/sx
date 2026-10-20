dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_PUNCT sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_punct - すべての引数が区切り記号（!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_punct [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて区切り記号のみで構成されている (SX_EX_OK)
##    1  区切り記号以外が含まれる、または空文字列が含まれる
sx_str_is_punct() {
	sx_str_is_of "${SX_STR_PUNCT}" "${@}" || return
}

popdef([|CLEANUP|])dnl
