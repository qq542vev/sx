dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_glob_escape __sx_var_is_rw sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_glob_escape - 文字列内の glob 特殊文字をエスケープする
##
## 使い方:
##   sx_glob_escape 結果変数名 [文字列]
##
## 説明:
##   指定された文字列に含まれる glob 特殊文字（* ? [）を、
##   glob ブラケット式 [*] [?] [[] に変換する。
##   これにより、エスケープ後の文字列を case のパターン内で
##   安全に使用できる（リテラルマッチ）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  結果変数名が無効 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_glob_escape() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_escape "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_glob_escape "${@}" || return
}

popdef([|CLEANUP|])dnl
