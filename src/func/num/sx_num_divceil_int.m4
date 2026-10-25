M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_divceil_int __sx_num_is_int_base __sx_num_is_nzint_base __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_divceil_int - 符号付き整数の除算で切り上げ商を求める
##
## 使い方:
##   sx_num_divceil_int 結果変数名 被除数 [除数]
##
## 説明:
##   符号付き10進整数の除算を行い、数学的 ceil（正の無限大方向）の商を求める。
##   同符号では ceil（絶対値の商）、異符号では -floor（絶対値の商）に等しい。
##   __sx_num_divmod_nat0 で絶対値の商 q0 と余り r0 を求め、
##   余りがあり被除数と除数が同符号の場合のみ __sx_num_add1_nat0 で 1 を加算し、
##   異符号で商が 0 でない場合は負号を付与する。
##   被除数は任意の符号付き整数、除数は 0 以外の符号付き整数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

sx_num_divceil_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divceil_int "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_divceil_int|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${2:+"${2}"} && __sx_num_is_nzint_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_num_divceil_int "${@}"
}
|], [|num_divceil_int|])dnl
popdef([|CLEANUP|])dnl
