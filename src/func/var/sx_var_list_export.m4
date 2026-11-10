M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_bind __sx_var_is_bindable __sx_var_list_export|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_list_export - エクスポート属性付き変数の一覧を取得する
##
## 使い方:
##   sx_var_list_export 結果変数名（またはバインド形式）
##
## 説明:
##   現在のシェルでエクスポート属性として設定されている全ての変数名（重複除去済み）を
##   スペース区切りの文字列として取得し、指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_var_list_export() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_list_export "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_var_list_export|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_var_list_export "${@}"
}

popdef([|CLEANUP|])dnl
