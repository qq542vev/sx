M_REQUIRE([|__sx_num_is_int|])dnl
### sx_num_is_int - すべての引数が整数であるか確認する
##
## 使い方:
##   sx_num_is_int [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_int に委譲する。
##   任意で符号（+ または -）を持つ整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて整数である (SX_EX_OK)
##    1  整数ではない値が含まれる

sx_num_is_int() {
	__sx_num_is_int "${@}" || return
}
