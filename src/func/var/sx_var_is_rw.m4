M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_rw - 変数が書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  読み取り専用が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_rw() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_rw "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_var_is_rw|])

	__sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_rw "${@}" || return
}

popdef([|CLEANUP|])dnl
