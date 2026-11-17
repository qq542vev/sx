M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_pint_base10|])dnl
### sx_num_is_pint_base10 - すべての引数が 1 以上の整数 であるか確認する（基数 10）
##
## 使い方:
##   sx_num_is_pint_base10 [文字列1 [文字列2 ...]]
##
## 説明:
##   基数 10 において、すべての引数が 1 以上の整数 であるか確認する。
##
## 終了ステータス:
##    0  すべて 1 以上の整数である (SX_EX_OK)
##    1  1 以上の整数ではない値が含まれる
sx_num_is_pint_base10() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_pint_base10 "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_is_pint_base10|])

	__sx_num_is_pint_base10 "${@}"
}
