dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_width|])dnl
pushdef([|CLEANUP|])dnl
### __sx_num_is_int_safe - 設定された数値範囲に基づいて検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_int_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe の内部実装。引数チェックは行わない。
__sx_num_is_int_safe() {
	__sx_num_is_int_width "${SX_CFG_NUM_RANGE}" "${@}" || return
}

popdef([|CLEANUP|])dnl
