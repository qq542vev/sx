M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_divceil_nat0 __sx_num_is_nat0_base __sx_num_is_nat1_base __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_divceil_nat0 - 絶対値の除算で切り上げ商を求める
##
## 使い方:
##   sx_num_divceil_nat0 結果変数名 被除数 [除数]
##
## 説明:
##   符号なし10進整数の絶対値の除算を行い、余りがあれば切り上げた商を求める。
##   ceil(被除数 ÷ 除数) に等しく、__sx_num_divmod_nat0 で求めた余りが 0 でなければ
##   __sx_num_add1_nat0 で商に 1 を加算する。
##   被除数は 0 以上の自然数、除数は 1 以上の自然数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

sx_num_divceil_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divceil_nat0 "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_divceil_nat0|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 ${2:+"${2}"} && __sx_num_is_nat1_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_num_divceil_nat0 "${@}"
}
|], [|num_divceil_nat0|])dnl
popdef([|CLEANUP|])dnl
