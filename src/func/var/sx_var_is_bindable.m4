M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_bindable - バインド形式が有効であり、かつ全変数が書き込み可能か確認する
##
## 使い方:
##   sx_var_is_bindable [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   指定されたバインド形式が妥当な名前で構成されており、かつ含まれるすべての変数が
##   書き込み可能（読み取り専用でない）であることを確認する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる (SX_EX_NOPERM)
##   64  バインド形式が不正 (SX_EX_USAGE)
sx_var_is_bindable() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_bindable "${@}" || return; return 0;; esac

	__sx_var_is_bind "${@}" || return M_EX_USAGE

	__sx_var_is_bindable "${@}" || return
}

popdef([|CLEANUP|])dnl
