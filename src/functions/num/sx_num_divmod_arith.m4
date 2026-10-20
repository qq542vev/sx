M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_divmod_arith __sx_num_is_divmod_arith_safe __sx_num_is_int_safe __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_divmod_arith - 算術展開で符号付き整数の商と余剰を求める
##
## 使い方:
##   sx_num_divmod_arith バインド形式 [被除数 [除数]]
##
## 説明:
##   SX_CFG_NUM_RANGE 内の符号付き8・10・16進整数を算術展開で除算する。
##   商はゼロ方向へ丸め、余剰は0または被除数と同じ符号になる。
##   結果は10進表記で、バインド形式（例: "q:r:"）へ商・余剰の順に渡す。
##   sx_num_divmod_int と同様、省略・空文字列の被除数は0、除数は1とし、
##   余分な引数は無視する。除数が0、または被除数がMINで除数が-1の場合は拒否する。
##   検証失敗時はバインド先を変更しない。
##   SX_CFG_SKIP_CHK=1 では安全判定を含むすべての引数検証を省略し、
##   正しい入力・非ゼロの除数・範囲内の商を保証する責任は呼び出し側にある。
##   SX_CFG_NUM_RANGE は実行シェルの算術域以下であることを前提とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  バインド・整数の形式不正、入力値が範囲外、ゼロ除算または商の桁溢れ (SX_EX_USAGE)
##   77  バインド先が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)
sx_num_divmod_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divmod_arith "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_safe ${2:+"${2}"}  ${3:+"${3}"} && __sx_num_is_divmod_arith_safe "${2-}"  "${3-}" || return M_EX_USAGE

	__sx_num_divmod_arith "${@}"
}

popdef([|CLEANUP|])dnl
