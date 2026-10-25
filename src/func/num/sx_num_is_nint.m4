M_REQUIRE([|__sx_num_is_nint|])dnl
### sx_num_is_nint - すべての引数が負の整数であるか確認する
##
## 使い方:
##   sx_num_is_nint [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_nint に委譲する。
##   負の符号（-）を必須で持ち、-1 以下の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて負の整数である (SX_EX_OK)
##    1  負の整数ではない値が含まれる

sx_num_is_nint() {
	__sx_num_is_nint "${@}" || return
}
