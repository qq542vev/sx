M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_nat1_base8|])dnl
### sx_num_is_nat1_base8 - すべての引数が 1 以上の自然数 であるか確認する（基数 8）
##
## 使い方:
##   sx_num_is_nat1_base8 [文字列1 [文字列2 ...]]
##
## 説明:
##   基数 8 において、すべての引数が 1 以上の自然数 であるか確認する。
##
## 終了ステータス:
##    0  すべて 1 以上の自然数である (SX_EX_OK)
##    1  1 以上の自然数ではない値が含まれる
sx_num_is_nat1_base8() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat1_base8 "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_is_nat1_base8|])

	__sx_num_is_nat1_base8 "${@}"
}
