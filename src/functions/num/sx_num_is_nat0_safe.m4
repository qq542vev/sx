dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_nat0_safe sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_nat0_safe - 安全に処理できる数値範囲（SX_CFG_NUM_RANGE）の自然数（0以上）か確認する
##
## 使い方:
##   sx_num_is_nat0_safe [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の自然数である (SX_EX_OK)
##    1  範囲外、または自然数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_nat0_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat0_safe "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_nat0_safe "${@}" || return
}

popdef([|CLEANUP|])dnl
