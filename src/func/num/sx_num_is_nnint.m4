M_REQUIRE([|__sx_num_is_nnint|])dnl
### sx_num_is_nnint - すべての引数が非負整数（0以上の整数）であるか確認する
##
## 使い方:
##   sx_num_is_nnint [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_nnint に委譲する。
##   0（+0, -0 を含む）または正の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて非負整数である (SX_EX_OK)
##    1  非負整数ではない値が含まれる

sx_num_is_nnint() {
	M_CFG_CHECK([|sx_num_is_nnint|])

	__sx_num_is_nnint "${@}" || return
}
