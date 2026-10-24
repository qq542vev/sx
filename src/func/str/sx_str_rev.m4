M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_nzint_base __sx_str_rev __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_rev - 文字列を反転する
##
## 使い方:
##   sx_str_rev 結果変数名 [元文字列 [チャンクサイズ]]
##
## 説明:
##   指定された文字列を反転（逆順）して結果変数に格納する。
##   空文字列が渡された場合は空文字列を格納する。
##   チャンクサイズが正の場合は先頭基準、負の場合は末尾基準でチャンク単位の反転を行う。
##   チャンクサイズは 0 以外の10進整数表記に限る。符号（+ または -）は任意で、先行する 0 は認めない。
##   チャンクサイズが 1、省略、または空の場合は文字単位の反転を行う。
##   元文字列の長さとチャンクサイズに SX_CFG_NUM_RANGE による上限は設けない。
##   チャンクサイズの絶対値が文字列長以上の場合は、パターンを生成せず元文字列をそのまま格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rev() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rev "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nzint_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_str_rev "${@}"
}

popdef([|CLEANUP|])dnl
