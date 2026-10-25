M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_empty __sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_empty - 変数が設定されており、かつ空か確認する
##
## 使い方:
##   sx_var_is_empty 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて空である (SX_EX_OK)
##    1  設定されていない、または空でない変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_empty() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_empty "${@}" || return; return 0;; esac

	__sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_empty "${@}" || return
}

popdef([|CLEANUP|])dnl
