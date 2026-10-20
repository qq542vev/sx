dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_edivmod_arith __sx_num_is_divmod_arith_safe __sx_num_is_int_safe __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_edivmod_arith - 算術展開でユークリッド除算の商と余剰を求める
##
## 使い方:
##   sx_num_edivmod_arith バインド形式 [被除数 [除数]]
##
## 説明:
##   SX_CFG_NUM_RANGE 内の符号付き8・10・16進整数をユークリッド除算する。
##   a = b×q + r（0 ≤ r < |b|）を満たす商・余剰を10進表記で、
##   バインド形式（例: "q:r:"）へ商・余剰の順に渡す。
##   省略・空文字列の被除数は0、除数は1とし、余分な引数は無視する。
##   除数が0、または被除数がMINで除数が-1の場合は拒否する。
##   divmod_arith の安全判定を共用し、検証失敗時はバインド先を変更しない。
##   SX_CFG_SKIP_CHK=1 では安全判定を含むすべての引数検証を省略し、
##   正しい入力・非ゼロの除数・範囲内の商を保証する責任は呼び出し側にある。
##   SX_CFG_NUM_RANGE は実行シェルの算術域以下であることを前提とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  バインド・整数の形式不正、入力範囲外、ゼロ除算または商の桁溢れ (SX_EX_USAGE)
##   77  バインド先が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)
sx_num_edivmod_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_edivmod_arith "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_safe ${2:+"${2}"}  ${3:+"${3}"} && __sx_num_is_divmod_arith_safe "${2-}"  "${3-}" || return M_EX_USAGE

	__sx_num_edivmod_arith "${@}"
}

popdef([|CLEANUP|])dnl
