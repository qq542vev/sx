dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_WORD sx_str_is_of|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_is_word - すべての引数が単語構成文字（英数字 + _）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_word [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて単語構成文字のみで構成されている (SX_EX_OK)
##    1  単語構成文字以外が含まれる、または空文字列が含まれる
sx_str_is_word() {
	sx_str_is_of "${SX_STR_WORD}" "${@}" || return
}

popdef([|CLEANUP|])dnl
