M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_name __sx_var_is_rw __sx_var_touch|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_touch - リビジョン番号を更新する
##
## 使い方:
##   sx_var_touch 変数名
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_var_touch() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_touch "${@}" || return; return 0;; esac

	__sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw "${@}" || return M_EX_NOPERM

	__sx_var_touch "${@}"
}

popdef([|CLEANUP|])dnl
