M_REQUIRE([|__sx_str_is_digit|])dnl
### sx_str_is_digit - すべての引数が数字のみで構成されている（空でない）か確認する
##
## 使い方:
##   sx_str_is_digit [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_digit に委譲する。
##
## 終了ステータス:
##    0  すべて数字のみで構成されている (SX_EX_OK)
##    1  数字以外が含まれる、または空文字列が含まれる

sx_str_is_digit() {
	__sx_str_is_digit "${@}" || return
}
