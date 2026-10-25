M_REQUIRE([|__sx_str_is_word|])dnl
### sx_str_is_word - すべての引数が単語構成文字（英数字 + _）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_word [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_word に委譲する。
##
## 終了ステータス:
##    0  すべて単語構成文字のみで構成されている (SX_EX_OK)
##    1  単語構成文字以外が含まれる、または空文字列が含まれる

sx_str_is_word() {
	__sx_str_is_word "${@}" || return
}
