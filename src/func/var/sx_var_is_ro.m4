M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_name __sx_var_is_ro|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_ro - 変数が読み取り専用か確認する
##
## 使い方:
##   sx_var_is_ro 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて読み取り専用 (SX_EX_OK)
##    1  書き込み可能な変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_ro() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_ro "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_var_is_ro|])

	__sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_ro "${@}" || return
}

popdef([|CLEANUP|])dnl
