M_REQUIRE([|__sx_num_is_nat1|])dnl
### sx_num_is_nat1 - すべての引数が 1 以上の自然数（符号なし整数） であるか確認する
##
## 使い方:
##   sx_num_is_nat1 [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_nat1 に委譲する。
##
## 終了ステータス:
##    0  すべて 1 以上の自然数である (SX_EX_OK)
##    1  1 以上の自然数ではない値が含まれる

sx_num_is_nat1() {
	__sx_num_is_nat1 "${@}" || return
}
