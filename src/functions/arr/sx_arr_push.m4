M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_push __sx_var_is_arr __sx_var_is_rw_deep sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_arr_push - 配列の末尾に要素を追加する
##
## 使い方:
##   sx_arr_push 配列名 [値 ...]
##
## 説明:
##   指定された sx 配列の末尾に 0 個以上の値を追加する。
##   配列名が有効でも、対象が sx 配列でない場合は SX_EX_DATAERR を返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  配列名が無効 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_push() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_push "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_arr "${1}" || return M_EX_DATAERR
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM

	__sx_arr_push "${@}"
}

popdef([|CLEANUP|])dnl
