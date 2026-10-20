M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_rw_all sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_rw_all - 指定された変数およびその関連要素がすべて書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw_all 名前1 [名前2 ...]
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  読み取り専用が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_rw_all() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_rw_all "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw_all "${@}" || return
}

popdef([|CLEANUP|])dnl
