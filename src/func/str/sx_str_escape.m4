M_REQUIRE([|SX_CFG_SKIP_CHK __sx_str_escape __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_escape - 文字列内の指定された文字をエスケープする
##
## 使い方:
##   sx_str_escape 結果変数名 [元文字列 [エスケープ対象文字集合 [開始エスケープ文字列 [終了エスケープ文字列]]]]
##
## 説明:
##   元文字列の中に含まれるエスケープ対象文字の各文字を、
##   開始エスケープ文字列 + その文字 + 終了エスケープ文字列 で置換する。
##   エスケープ対象文字集合が空の場合は、元の文字列をそのまま結果変数に格納する。
##   元文字列の長さに SX_CFG_NUM_RANGE による上限は設けない。
##   s=\, e=空 の場合はバックスラッシュエスケープ（シェルエスケープ）として動作する。
##   s=[, e=] の場合は glob ブラケット式による quoting として動作する。
##   s=', e=' の場合は SQL LIKE エスケープとして動作する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_str_escape() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_escape "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_str_escape|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_str_escape "${@}"
}

popdef([|CLEANUP|])dnl
