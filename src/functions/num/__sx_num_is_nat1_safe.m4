dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_fit sx_num_is_nat1|])dnl
pushdef([|CLEANUP|])dnl
### __sx_num_is_nat1_safe - 設定された数値範囲に基づいて 1 以上の自然数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_nat1_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat1_safe の内部実装。引数チェックは行わない。
__sx_num_is_nat1_safe() {
	sx_num_is_nat1 "${@}" || return
	__sx_num_is_int_fit "${SX_CFG_NUM_RANGE}" "${@}" || return
}

popdef([|CLEANUP|])dnl
