dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_safe_inv sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_int_safe_inv - 安全に処理できる数値範囲（SX_CFG_NUM_RANGE）で符号反転可能な整数か確認する
##
## 使い方:
##   sx_num_is_int_safe_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe と同様に SX_CFG_NUM_RANGE に基づいて整数を検証するが、
##   INT_MIN（符号反転が不可能な最小値）を許可しない。
##   すなわち -(2^(n-1)-1) ～ 2^(n-1)-1 の範囲の整数のみを受理する。
##
## 終了ステータス:
##    0  すべて範囲内の符号反転可能な整数である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_int_safe_inv() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_safe_inv "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_int_safe_inv "${@}" || return
}

popdef([|CLEANUP|])dnl
