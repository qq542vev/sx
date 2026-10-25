M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_dump __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_dump - 変数や配列の状態を文字列として取得する
##
## 使い方:
##   sx_var_dump 結果変数名 [名前1 ...]
##
## 説明:
##   指定された変数（または配列）の現在の状態を、代入式（name='value'）の
##   形式で取得し、結果変数に格納する。配列の場合は関連する全要素を含む。
##   変数が設定されていない場合は 'unset -v name' の形式となる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_dump() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_dump "${@}" || return; return 0;; esac

	__sx_var_is_name "${1-}" "${@}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_var_dump "${@}"
}

popdef([|CLEANUP|])dnl
