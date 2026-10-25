M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_name __sx_var_is_set|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_set - 変数が設定されているか確認する
##
## 使い方:
##   sx_var_is_set 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて設定されている (SX_EX_OK)
##    1  未設定の変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_set "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_var_is_set|])

	__sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_set "${@}" || return
}

popdef([|CLEANUP|])dnl
