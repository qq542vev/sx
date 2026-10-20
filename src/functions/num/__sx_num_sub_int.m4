dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_add_int __sx_num_add_nat0 __sx_num_cmp_nat0 __sx_num_sub_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_sub_int - 複数の符号付き整数を減算する（内部用）
##
## 使い方:
##   __sx_num_sub_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_sub_int の内部実装。引数チェックは行わない。
##   第2引数以降を __sx_num_add_int で合計し、第1引数と符号付き減算する。
##   符号の組み合わせに応じて __sx_num_cmp_nat0 / __sx_num_sub_nat0 /
##   __sx_num_add_nat0 で絶対値の演算を行う。

define([|CLEANUP|], [|Q_res Q_first Q_sign Q_sum Q_tmp|])dnl

__sx_num_sub_int() {
	Q_res="${1}"
	Q_first="${2-0}"
	Q_sign=

	shift "$((1 + 0${2+1}))"

	# $2...$n の合計（符号付き加算）
	__sx_num_add_int Q_sum "${@}"

	# 合計が 0 なら第1引数がそのまま結果
	case "${Q_sum}" in 0)
		M_VAR_SET([|${Q_res}|], [|${Q_first#+}|])
		unset CLEANUP
		return
	esac

	# a - sum を符号の組み合わせ4ケースに分けて直接演算
	case "${Q_first}${Q_sum}" in
		# ケース4: (-a) - (-s) = |s| - |a|
		-*-*)
			__sx_num_cmp_nat0 "${Q_first#-}" "${Q_sum#-}" || case "${?}" in
				1) __sx_num_sub_nat0 Q_tmp "${Q_sum#-}" "${Q_first#-}";;
				3)
					Q_sign='-'
					__sx_num_sub_nat0 Q_tmp "${Q_first#-}" "${Q_sum#-}"
					;;
			esac
			;;
		# ケース3: (-a) - s = -(a + s)
		-*) Q_sign='-';&
		# ケース2: a - (-s) = a + s
		*-*) __sx_num_add_nat0 Q_tmp "${Q_first#[+-]}" "${Q_sum#-}";;
		# ケース1: a - s
		*)
			__sx_num_cmp_nat0 "${Q_first#+}" "${Q_sum}" || case "${?}" in
				1)
					Q_sign='-'
					__sx_num_sub_nat0 Q_tmp "${Q_sum}" "${Q_first#+}"
					;;
				3) __sx_num_sub_nat0 Q_tmp "${Q_first#+}" "${Q_sum#+}";;
			esac
			;;
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_sign}${Q_tmp-0}|])
	unset CLEANUP
}
|], [|num_sub_int|])dnl
popdef([|CLEANUP|])dnl
