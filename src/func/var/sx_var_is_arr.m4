M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_arr __sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_arr - 指定された変数がsx配列であるか確認する
##
## 使い方:
##   sx_var_is_arr 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべてsx配列である (SX_EX_OK)
##    1  sx配列ではない変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_var_is_arr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_arr "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_var_is_arr|])

	__sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_arr "${@}" || return
}

popdef([|CLEANUP|])dnl
