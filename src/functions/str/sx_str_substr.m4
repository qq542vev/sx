dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_substr __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_substr - 文字列の指定した位置から指定した長さの部分文字列を取得する
##
## 使い方:
##   sx_str_substr 結果変数名 [元文字列 [オフセット [長さ]]]
##
## 説明:
##   元文字列のオフセット（0開始）から指定された長さ分だけ抽出し、結果変数に格納する。
##   オフセットが負の場合は、文字列末尾からの位置として扱う。
##   負のオフセットが先頭を越える場合も、指定範囲のうち文字列と重なる部分だけ抽出する。
##   長さが省略された場合、または末尾を超える場合は末尾まで抽出する。
##   長さが負の場合は、抽出対象の末尾から指定文字数を除外する。
##   オフセットが文字列長以上の場合は空文字列を返す。
##   Perl の substr が undef を返す範囲外の指定も、警告なしで空文字列を格納して成功する。
##   オフセットと長さは10進整数表記に限る。符号（+ または -）は任意で、先行する 0 は認めない。
##   オフセットは省略時に 0 とする。数値引数に空文字列を明示した場合は引数不正とする。
##   元文字列の長さ、オフセット、長さに SX_CFG_NUM_RANGE による上限は設けない。
##   元文字列の長さとの比較後、必要な範囲だけパターンを生成して抽出する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_substr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_substr "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${3+"${3}"} ${4+"${4}"} || return M_EX_USAGE

	__sx_str_substr "${@}"
}

popdef([|CLEANUP|])dnl
