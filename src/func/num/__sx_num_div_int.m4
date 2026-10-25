M_REQUIRE([|__sx_num_div_nat0 __sx_num_mul_int|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_div_int - 符号付き整数の除算で実数商（整数商 + 小数部）を求める（内部用）
##
## 使い方:
##   __sx_num_div_int 結果変数名 小数桁数 被除数 [除数1 [除数2 ...]]
##
## 説明:
##   sx_num_div_int の内部実装。引数チェックは行わない。
##   前提: 小数桁数は 0 以上の自然数、被除数は任意の符号付き整数、
##   すべての除数は 0 以外の符号付き整数であること。

define([|CLEANUP|], [|Q_res Q_dp Q_u Q_den Q_q|])dnl

__sx_num_div_int() {
	Q_res="${1}"
	Q_dp="${2:-0}"
	Q_u="${3:-0}"
	shift "$((0${1+1} + 0${2+1} + 0${3+1}))"

	case "${Q_u}" in 0 | +0 | -0)
		M_VAR_SET([|${Q_res}|], [|0|])
		unset CLEANUP
		return
	esac

	__sx_num_mul_int Q_den "${@}"

	__sx_num_div_nat0 Q_q "${Q_dp}" "${Q_u#[+-]}" "${Q_den#[+-]}"

	case "${Q_u}:${Q_den}:${Q_q}" in -*:[!-]*:*[!0]* | [!-]*:-*:*[!0]*)
		M_STR_PREPEND([|Q_q|], [|-|])
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_q}|])
	unset CLEANUP
}
|], [|num_div_int|])dnl
popdef([|CLEANUP|])dnl
