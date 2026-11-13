M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_export __sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_export - 変数がエクスポート属性を持つか確認する
##
## 使い方:
##   sx_var_is_export 変数名1 [変数名2 ...]
##
## 説明:
##   指定されたすべての変数がエクスポート属性を持つか確認する。
##
## 終了ステータス:
##    0  すべてエクスポート属性付き (SX_EX_OK)
##    1  エクスポート属性のない変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
##   78  設定値が不正または未設定 (SX_EX_CONFIG)
sx_var_is_export() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_export "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_var_is_export|])

	__sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_export "${@}" || return
}

popdef([|CLEANUP|])dnl
