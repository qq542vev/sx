M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_int_safe|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_int_safe - 安全に処理できる数値範囲（SX_CFG_NUM_RANGE）の整数か確認する
##
## 使い方:
##   sx_num_is_int_safe [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の整数である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_num_is_int_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_safe "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_is_int_safe|])

	__sx_num_is_int_safe "${@}" || return
}

popdef([|CLEANUP|])dnl
