dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_val sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_val - 変数が値を持ち、かつ空でないか確認する
##
## 使い方:
##   sx_var_is_val 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて値があり、空でない (SX_EX_OK)
##    1  設定されていない、または空の変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_val() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_val "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_val "${@}" || return
}

popdef([|CLEANUP|])dnl
