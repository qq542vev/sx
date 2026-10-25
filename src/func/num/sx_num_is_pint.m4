M_REQUIRE([|__sx_num_is_pint|])dnl
### sx_num_is_pint - すべての引数が正の整数であるか確認する
##
## 使い方:
##   sx_num_is_pint [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_pint に委譲する。
##   任意で正の符号（+）を持つ、1 以上の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて正の整数である (SX_EX_OK)
##    1  正の整数ではない値が含まれる

sx_num_is_pint() {
	__sx_num_is_pint "${@}" || return
}
