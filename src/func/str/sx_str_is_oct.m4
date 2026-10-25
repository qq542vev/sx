M_REQUIRE([|__sx_str_is_oct|])dnl
### sx_str_is_oct - すべての引数が8進数文字（0-7）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_oct [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_oct に委譲する。
##
## 終了ステータス:
##    0  すべて8進数文字のみで構成されている (SX_EX_OK)
##    1  8進数文字以外が含まれる、または空文字列が含まれる

sx_str_is_oct() {
	__sx_str_is_oct "${@}" || return
}
