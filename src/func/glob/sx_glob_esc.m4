M_REQUIRE([|SX_CFG_SKIP_CHK __sx_glob_esc __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_glob_esc - 文字列内の glob 特殊文字をエスケープする
##
## 使い方:
##   sx_glob_esc 結果変数名 [文字列]
##
## 説明:
##   指定された文字列に含まれる glob 特殊文字（* ? [ およびバックスラッシュ）を、
##   glob ブラケット式 [*] [?] [[] [\\] に変換する。
##   これにより、エスケープ後の文字列を case のパターン内で
##   安全に使用できる（リテラルマッチ）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  結果変数名が無効 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_glob_esc() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_esc "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_glob_esc|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_glob_esc "${@}" || return
}

popdef([|CLEANUP|])dnl
