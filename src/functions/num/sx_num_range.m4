dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_num_range __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_range - 数値の範囲を生成する (Python range 互換)
##
## 使い方:
##   sx_num_range 結果変数名（またはバインド形式） 終了
##   sx_num_range 結果変数名（またはバインド形式） 開始 終了
##   sx_num_range 結果変数名（またはバインド形式） 開始 終了 増分
##
## 説明:
##   指定された範囲の数値をスペース区切りで生成し、結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   Python の range() と同様に、終了値は含まない (exclusive)。
##   引数が1つの場合は、0 から 終了 - 1 まで増分 1。
##   引数が2つの場合は、開始 から 終了 - 1 まで増分 1。
##   引数が3つの場合は、開始 から 終了 (exclusive) まで指定された 増分 で生成する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_range "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 "${2-}" ${3+"${3}"} ${4+"${4}"} || return M_EX_USAGE

	case "${4-1}" in 0 | [+-]0)
		return M_EX_USAGE
	esac

	__sx_num_range "${@}"
}

popdef([|CLEANUP|])dnl
