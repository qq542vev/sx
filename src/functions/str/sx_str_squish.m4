dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_str_squish __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_squish - XSLT normalize-space 相当（trim + collapse）
##
## 使い方:
##   sx_str_squish 結果変数名 [文字列 [文字セット [区切り文字]]]
##
## 説明:
##   文字列の先頭と末尾から文字セットに含まれる文字を削除し、
##   内部の連続する文字セット文字を指定された区切り文字で置き換える。
##   文字セット省略時は SX_STR_SPACE（空白文字すべて）、
##   区切り文字省略時は半角スペース。
##   XSLT/XPath の normalize-space() 相当の機能。
##   元文字列の長さに SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_squish() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_squish "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_str_squish "${@}"
}

popdef([|CLEANUP|])dnl
