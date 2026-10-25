M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arg_len __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_len - 引数の個数を取得する
##
## 使い方:
##   sx_arg_len 結果変数名 [引数 ...]
##
## 説明:
##   第2引数以降に渡された引数の個数を数え、その結果を結果変数に格納する。
##   引数個数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_len() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_len "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arg_len|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_arg_len "${@}"
}

popdef([|CLEANUP|])dnl
