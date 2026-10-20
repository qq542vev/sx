dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_divmod_int __sx_num_is_int_base __sx_num_is_nzint_base __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_divmod_int - 符号付き整数の除算で整数商と余剰を同時に求める（Truncated）
##
## 使い方:
##   sx_num_divmod_int バインド形式 被除数 [除数]
##
## 説明:
##   符号付き10進整数の除算（Truncated 規約: 商はゼロ方向へ丸め、
##   余剰は被除数と同じ符号を持つ）を行い、整数商と余剰を同時に求める。
##   第一引数は商・余剰の割り当て先を指定する分配代入バインド形式（例: "q:r:"）。
##   被除数は任意の符号付き整数、除数は 0 以外の符号付き整数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_divmod_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divmod_int "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${2:+"${2}"} && __sx_num_is_nzint_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_num_divmod_int "${@}"
}

popdef([|CLEANUP|])dnl
