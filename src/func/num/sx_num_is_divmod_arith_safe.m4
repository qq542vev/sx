M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_divmod_arith_safe __sx_num_is_int_safe|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_divmod_arith_safe - 算術展開で安全に商と余剰を計算できるか確認する
##
## 使い方:
##   sx_num_is_divmod_arith_safe [被除数 [除数]]
##
## 説明:
##   符号付き8・10・16進整数の形式と SX_CFG_NUM_RANGE 内の入力範囲を検証し、
##   ゼロ除算・商の桁溢れを起こさず / と % を実行できるか確認する。
##   省略・空文字列の被除数は0、除数は1とし、余分な引数は無視する。
##   SX_CFG_SKIP_CHK=1 では設定・入力検証を省略するが、安全判定は行う。
##   SX_CFG_NUM_RANGE は実行シェルの算術域以下であることを前提とする。
##
## 終了ステータス:
##    0  設定幅内で安全に商と余剰を計算できる (SX_EX_OK)
##    1  ゼロ除算、または被除数がMINで除数が-1
##   64  整数の形式不正または入力値が設定幅の範囲外 (SX_EX_USAGE)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_num_is_divmod_arith_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_divmod_arith_safe "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_is_divmod_arith_safe|])

	__sx_num_is_int_safe ${1:+"${1}"} ${2:+"${2}"} || return M_EX_USAGE

	__sx_num_is_divmod_arith_safe "${@}" || return
}

popdef([|CLEANUP|])dnl
