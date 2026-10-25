M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_gen __sx_var_is_name __sx_var_is_rw_deep|])dnl
pushdef([|CLEANUP|])dnl
### sx_arr_gen - 配列を初期化し、要素を追加する
##
## 使い方:
##   sx_arr_gen 配列名 [値 ...]
##
## 説明:
##   指定された配列を新規に作成（または既存の配列を削除して再作成）し、
##   引数で指定された値を要素として追加する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arr_gen() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_gen "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arr_gen|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM

	__sx_arr_gen "${@}"
}

popdef([|CLEANUP|])dnl
