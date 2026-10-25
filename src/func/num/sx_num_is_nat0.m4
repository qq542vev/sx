M_REQUIRE([|__sx_num_is_nat0|])dnl
### sx_num_is_nat0 - すべての引数が 0 以上の自然数（符号なし整数） であるか確認する
##
## 使い方:
##   sx_num_is_nat0 [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_nat0 に委譲する。
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる

sx_num_is_nat0() {
	M_CFG_CHECK([|sx_num_is_nat0|])

	__sx_num_is_nat0 "${@}" || return
}
