M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_npint_base10or16|])dnl
### sx_num_is_npint_base10or16 - すべての引数が 0 以下の整数 であるか確認する（基数 10or16）
##
## 使い方:
##   sx_num_is_npint_base10or16 [文字列1 [文字列2 ...]]
##
## 説明:
##   基数 10or16 において、すべての引数が 0 以下の整数 であるか確認する。
##
## 終了ステータス:
##    0  すべて 0 以下の整数である (SX_EX_OK)
##    1  0 以下の整数ではない値が含まれる
sx_num_is_npint_base10or16() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_npint_base10or16 "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_is_npint_base10or16|])

	__sx_num_is_npint_base10or16 "${@}"
}
