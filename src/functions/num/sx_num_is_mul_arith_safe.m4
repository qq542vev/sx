dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_safe __sx_num_is_mul_arith_safe sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_mul_arith_safe - 引数順の乗算で桁溢れしないか確認する
##
## 使い方:
##   sx_num_is_mul_arith_safe [整数1 [整数2 ...]]
##
## 説明:
##   8・10・16進の符号付き整数について、各入力値が SX_CFG_NUM_RANGE の
##   範囲内であることを検証し、引数順の乗算が安全に行えるか確認する。
##   全中間結果および最終結果が設定幅内に収まる場合のみ成功する。
##   数値省略時は成功する。SX_CFG_SKIP_CHK=1 では設定・入力検証を省略するが、
##   桁溢れ判定は行う。SX_CFG_NUM_RANGE は実行シェルの算術域以下を前提とする。
##
## 終了ステータス:
##    0  設定幅内で安全に乗算できる (SX_EX_OK)
##    1  乗算途中または最終結果が設定幅の範囲外
##   64  整数の形式不正または入力値が設定幅の範囲外 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_mul_arith_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_mul_arith_safe "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_int_safe "${@}" || return M_EX_USAGE

	__sx_num_is_mul_arith_safe "${@}" || return
}

popdef([|CLEANUP|])dnl
