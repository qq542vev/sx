M_REQUIRE([|SX_CFG_SKIP_CHK __sx_str_len __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_len - 各文字列の長さをバインド形式に従って順に代入する
##
## 使い方:
##   sx_str_len バインド形式 文字列 ...
##
## 説明:
##   第1引数のバインド形式に従い、第2引数以降の各文字列の長さ（${#str}）を
##   順に結果変数へ代入する。第1引数は必須（空文字列可）。空 bind では
##   何も代入せず成功する。文字列数がバインド先より多い場合、超過分は無視する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

sx_str_len() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_len "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_str_len|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_str_len "${@}"
}

popdef([|CLEANUP|])dnl
