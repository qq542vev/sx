dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arg_range __sx_num_is_nat0_safe __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_range - 位置パラメータの参照文字列を生成する
##
## 使い方:
##   sx_arg_range 宛先 終了
##   sx_arg_range 宛先 開始 終了
##   sx_arg_range 宛先 開始 終了 増分
##
## 説明:
##   指定された範囲のインデックスに対応する位置パラメータの参照文字列
##   （例: '"${1}" "${2}"'）を生成し、宛先変数に格納する。
##   引数の仕様は sx_num_range と同一（Python の range 互換）だが、
##   すべての数値引数は 0 以上の整数 (nat0) である必要がある。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  宛先変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_range "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe "${2-}" ${3+"${3}"} ${4+"${4}"} || return M_EX_USAGE

	case "${4-1}" in 0)
		return M_EX_USAGE
	esac

	__sx_arg_range "${@}"
}

popdef([|CLEANUP|])dnl
