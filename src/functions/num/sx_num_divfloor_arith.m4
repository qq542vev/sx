dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_divfloor_arith __sx_num_is_divmod_arith_safe __sx_num_is_int_safe __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_divfloor_arith - 算術展開で符号付き整数の切り捨て商を求める
##
## 使い方:
##   sx_num_divfloor_arith 結果変数名 [被除数 [除数]]
##
## 説明:
##   SX_CFG_NUM_RANGE 内の符号付き8・10・16進整数を除算し、
##   負の無限大方向へ丸めた整数商を10進表記で結果変数に格納する。
##   省略・空文字列の被除数は0、除数は1とし、余分な引数は無視する。
##   除数が0、または被除数がMINで除数が-1の場合は拒否する。
##   divmod_arith の安全判定を共用し、検証失敗時は結果変数を変更しない。
##   SX_CFG_SKIP_CHK=1 ではすべての引数検証を省略し、安全な入力を
##   保証する責任は呼び出し側にある。SX_CFG_NUM_RANGE は実行シェルの算術域以下を前提とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正、整数の形式不正、入力範囲外、ゼロ除算または商の桁溢れ (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)
sx_num_divfloor_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divfloor_arith "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_safe ${2:+"${2}"}  ${3:+"${3}"} && __sx_num_is_divmod_arith_safe "${2-}"  "${3-}" || return M_EX_USAGE

	__sx_num_divfloor_arith "${@}"
}

popdef([|CLEANUP|])dnl
