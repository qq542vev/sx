M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_nat0_base8or10|])dnl
### sx_num_is_nat0_base8or10 - すべての引数が 0 以上の自然数（符号なし整数） であるか確認する（基数 8or10）
##
## 使い方:
##   sx_num_is_nat0_base8or10 [文字列1 [文字列2 ...]]
##
## 説明:
##   基数 8or10 において、すべての引数が 0 以上の自然数（符号なし整数） であるか確認する。
##   プレフィックスを認めず、0 以外の数値における先行する 0 も認めない。
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる
sx_num_is_nat0_base8or10() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat0_base8or10 "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_is_nat0_base8or10|])

	__sx_num_is_nat0_base8or10 "${@}"
}
