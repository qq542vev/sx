M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_div_int __sx_num_is_int_base __sx_num_is_nat0_safe __sx_num_is_nzint_base __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_div_int - 符号付き整数の除算で実数商（整数商 + 小数部）を求める
##
## 使い方:
##   sx_num_div_int 結果変数名 小数桁数 被除数 [除数1 [除数2 ...]]
##
## 説明:
##   符号付き10進整数の除算を行い、実数商（整数商 + 小数部）を求める。
##   すべての除数を乗算した値を単一の除数として扱い、被除数をその除数で除算する。
##   小数部は小数桁数（最大桁数）までを floor（切り捨て）で求め、末尾の 0 は除去される。
##   小数部が 0 になる場合は実数商 = 整数商となる。
##   （例: d 2 -100 3 → d=-33.33 / d 2 5 -10 → d=-0.5 / d 3 -100 -2 5 → d=10）
##   被除数は任意の符号付き整数、各除数は 0 以外の符号付き整数、小数桁数は 0 以上の自然数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   小数桁数・被除数・除数は省略可能で、省略した場合はそれぞれ 0、0、1 として扱われる
##   （小数桁数省略時は実数商 = 整数商、除数省略時は被除数がそのまま実数商）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res Q_dp Q_u|])dnl

sx_num_div_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_div_int "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_div_int|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2:+"${2}"} && __sx_num_is_int_base 10 ${3:+"${3}"} || return M_EX_USAGE

	Q_res="${1}"
	Q_dp="${2:-0}"
	Q_u="${3:-0}"
	shift "$((0${2+1} + 0${3+1} + 1))"

	__sx_num_is_nzint_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_div_int "${Q_res}" "${Q_dp}" "${Q_u}" "${@}"
	unset CLEANUP
}
|], [|num_div_int|])dnl
popdef([|CLEANUP|])dnl
