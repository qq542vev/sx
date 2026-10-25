M_REQUIRE([|__sx_num_is_npint|])dnl
### sx_num_is_npint - すべての引数が非正整数（0以下の整数）であるか確認する
##
## 使い方:
##   sx_num_is_npint [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_npint に委譲する。
##   0（+0, -0 を含む）または負の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて非正整数である (SX_EX_OK)
##    1  非正整数ではない値が含まれる

sx_num_is_npint() {
	M_CFG_CHECK([|sx_num_is_npint|])

	__sx_num_is_npint "${@}" || return
}
