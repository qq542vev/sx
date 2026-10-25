M_REQUIRE([|__sx_str_is_ascii|])dnl
### sx_str_is_ascii - すべての引数がASCII文字（0x00-0x7F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_ascii [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_ascii に委譲する。
##
## 終了ステータス:
##    0  すべてASCII文字のみで構成されている (SX_EX_OK)
##    1  ASCII文字以外が含まれる、または空文字列が含まれる

sx_str_is_ascii() {
	__sx_str_is_ascii "${@}" || return
}
