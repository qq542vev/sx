M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_nat0_base16|])dnl
### sx_num_is_nat0_base16 - すべての引数が 0 以上の自然数（符号なし整数） であるか確認する（基数 16）
##
## 使い方:
##   sx_num_is_nat0_base16 [文字列1 [文字列2 ...]]
##
## 説明:
##   基数 16 において、すべての引数が 0 以上の自然数（符号なし整数）であるか確認する。
##   各引数は '0x'/'0X' プレフィックスを必須とする。
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる
sx_num_is_nat0_base16() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat0_base16 "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_is_nat0_base16|])

	__sx_num_is_nat0_base16 "${@}"
}
