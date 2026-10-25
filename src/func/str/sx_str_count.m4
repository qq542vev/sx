M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_nat0_safe __sx_str_count __sx_var_is_name __sx_var_is_rw sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_count - 文字列から指定された文字列の出現回数を取得する
##
## 使い方:
##   sx_str_count 結果変数名 [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   元文字列から検索文字列の出現回数を数え、結果変数に非負整数で格納する。
##   フラグの意味は sx_str_find と同一（SX_STR_COUNT_GLOB / SX_STR_COUNT_OVERLAP）。
##   実質的に __sx_str_find に委譲し、結果のスペース区切り件数を __sx_arg_len で取得する。
##   元文字列の長さと出現回数に SX_CFG_NUM_RANGE による上限は設けない。
##
##   バインド形式はサポートしない。結果変数名には単一の変数名のみ指定可能。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_count() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_count "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_count "${@}" || return
}

popdef([|CLEANUP|])dnl
