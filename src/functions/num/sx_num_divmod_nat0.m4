dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_divmod_nat0 __sx_num_is_nat0_base __sx_num_is_nat1_base __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_divmod_nat0 - 絶対値の除算で整数商と余剰を同時に求める
##
## 使い方:
##   sx_num_divmod_nat0 バインド形式 被除数 [除数]
##
## 説明:
##   符号なし10進整数の絶対値の除算を行い、整数商と余剰を同時に求める。
##   第一引数は商・余剰の割り当て先を指定する分配代入バインド形式（例: "q:r:"）。
##   第1セグメントには整数商、第2セグメントには余剰が格納される。
##   実数商（整数商 + 小数部）を求める場合は sx_num_div_nat0 を使用する。
##   被除数は 0 以上の自然数、除数は 1 以上の自然数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_divmod_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divmod_nat0 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 ${2:+"${2}"} && __sx_num_is_nat1_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_num_divmod_nat0 "${@}"
}

popdef([|CLEANUP|])dnl
