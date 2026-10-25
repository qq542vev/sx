M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_center __sx_var_is_name __sx_var_is_rw sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_center - 文字列を指定された幅で中央寄せする
##
## 使い方:
##   sx_str_center 結果変数名 文字列 幅 [左埋め文字列 [右埋め文字列]]
##
## 説明:
##   文字列の長さが「幅」の絶対値に満たない場合、埋め込み文字列で中央寄せするように埋める。
##   幅が正の場合、余り（奇数の場合）は右側に振る。
##   幅が負の場合、余りは左側に振る。
##   左埋め文字列のみ指定された場合は右側にも同じ文字列を使用する（後方互換）。
##   左埋め文字列も右埋め文字列も指定されない場合は半角スペースを使用する。
##   左埋め文字列が明示的に空の場合は左側に何も埋めない。
##   右埋め文字列が明示的に空の場合は右側に何も埋めない。
##   両方とも明示的に空の場合は何もせずそのまま返す。
##   元の文字列が既に指定された幅以上の場合は、そのまま返す。
##   幅は10進整数表記に限る。符号（+ または -）は任意で、先行する 0 は認めない。
##   幅の省略時は 0 とする。空文字列を明示した場合は引数不正とする。
##   元文字列・左右の埋め文字列の長さと幅に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_center() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_center "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${3+"${3}"} || return M_EX_USAGE

	__sx_str_center "${@}"
}

popdef([|CLEANUP|])dnl
