M_REQUIRE([|__sx_num_mul_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_mul_int - 複数の符号付き整数を乗算する（内部用）
##
## 使い方:
##   __sx_num_mul_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_mul_int の内部実装。引数チェックは行わない。
##   負号の個数で符号を決定し、__sx_num_mul_nat0 で絶対値乗算を行う。

define([|CLEANUP|], [|Q_res Q_qty Q_arg Q_abs_args Q_sign Q_acc|])dnl

__sx_num_mul_int() {
	Q_res="${1}"
	shift

	Q_qty=0
	Q_abs_args=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0 | +0 | -0)
				M_VAR_SET([|${Q_res}|], [|0|])
				unset CLEANUP
				return
				;;
			-*) Q_qty=$((~Q_qty));;
		esac

		M_STR_APPEND([|Q_abs_args|], [|" ${Q_arg#[+-]}"|])
	done

	case "$((Q_qty & 1))" in
		1) Q_sign=-;;
		*) Q_sign=;;
	esac

	eval __sx_num_mul_nat0 Q_acc "${Q_abs_args}"

	M_VAR_SET([|${Q_res}|], [|${Q_sign}${Q_acc}|])

	unset CLEANUP
}
|], [|num_mul_int|])dnl
popdef([|CLEANUP|])dnl
