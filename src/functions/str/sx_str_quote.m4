dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_str_quote __sx_var_is_rw sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_quote - 文字列をシングルクォートで囲む
##
## 使い方:
##   sx_str_quote 結果変数名 [元文字列]
##
## 説明:
##   元文字列をシングルクォートで囲み、内部のシングルクォートを
##   '\'' 形式に置換して結果変数に格納する。
##   元文字列が省略された場合は、空文字列を引用した '' を格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_quote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_quote "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_str_quote "${@}"
}

popdef([|CLEANUP|])dnl
