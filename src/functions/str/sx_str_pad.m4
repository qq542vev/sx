dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_pad __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_pad - 文字列を指定された長さになるように埋める
##
## 使い方:
##   sx_str_pad 結果変数名 文字列 長さ [埋め込み文字列]
##
## 説明:
##   文字列の長さが「長さ」の絶対値に満たない場合、埋め込み文字列で埋める。
##   長さが正の場合、左側に埋める（右寄せ）。
##   長さが負の場合、右側に埋める（左寄せ）。
##   埋め込み文字列が指定されない場合は半角スペースを使用する。
##   埋め込み文字列が明示的に空の場合は何もせずそのまま返す。
##   埋め込み文字列が複数文字の場合、必要な長さ分だけ使用される。
##   元の文字列が既に指定された長さ以上の場合は、そのまま返す。
##   長さは10進整数表記に限る。符号（+ または -）は任意で、先行する 0 は認めない。
##   長さの省略時は 0 とする。空文字列を明示した場合は引数不正とする。
##   元文字列・埋め込み文字列の長さと数値引数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_pad() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_pad "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${3+"${3}"} || return M_EX_USAGE

	__sx_str_pad "${@}"
}

popdef([|CLEANUP|])dnl
