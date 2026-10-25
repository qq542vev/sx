M_REQUIRE([|__sx_num_is_nzint|])dnl
### sx_num_is_nzint - すべての引数が 0 以外の整数であるか確認する
##
## 使い方:
##   sx_num_is_nzint [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_nzint に委譲する。
##   0（+0, -0 を含む）以外の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて 0 以外の整数である (SX_EX_OK)
##    1  0、または整数ではない値が含まれる

sx_num_is_nzint() {
	__sx_num_is_nzint "${@}" || return
}
