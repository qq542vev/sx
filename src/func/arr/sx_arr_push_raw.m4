M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_push_raw __sx_var_is_arr __sx_var_is_name __sx_var_is_rw_deep|])dnl
### sx_arr_push_raw - リビジョンを更新せず配列の末尾に要素を追加する
##
## 使い方:
##   sx_arr_push_raw 配列名 [値 ...]
##
## 説明:
##   sx_arr_push と同じ引数検証を行い、末尾に 0 個以上の値を追加する。
##   対象配列のリビジョンは更新しない。
##   参照・穴の解釈は sx_arr_push と同じである。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  配列名が無効 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arr_push_raw() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_push_raw "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arr_push_raw|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_arr "${1}" || return M_EX_DATAERR
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM

	__sx_arr_push_raw "${@}"
}
