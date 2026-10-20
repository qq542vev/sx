dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_add_nat0 __sx_num_cmp_nat0 __sx_num_sub_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_add_int - 複数の符号付き整数を加算する（内部用）
##
## 使い方:
##   __sx_num_add_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を加算する。まず正数と負数に分けてそれぞれ
##   __sx_num_add_nat0 で絶対値加算を行い、最後に絶対値を比較し
##   減算して符号を決定する。

define([|CLEANUP|], [|Q_res Q_pos Q_neg Q_arg Q_acc|])dnl

__sx_num_add_int() {
	Q_res="${1}"
	shift

	# Step 1: 正数と負数に分離
	Q_pos=
	Q_neg=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			-[1-9]*) M_STR_APPEND([|Q_neg|], [|" ${Q_arg#-}"|]);;
			*[1-9]*) M_STR_APPEND([|Q_pos|], [|" ${Q_arg#+}"|]);;
		esac
	done

	# Step 2: 正数の合計
	case "${Q_pos:+X}" in X)
		eval __sx_num_add_nat0 Q_pos "${Q_pos}"
	esac

	# Step 3: 負数（絶対値）の合計
	case "${Q_neg:+X}" in X)
		eval __sx_num_add_nat0 Q_neg "${Q_neg}"
	esac

	# Step 4: 絶対値を比較して最終結果を決定
	__sx_num_cmp_nat0 "${Q_pos:-0}" "${Q_neg:-0}" || case "${?}" in
		1)
			__sx_num_sub_nat0 Q_acc "${Q_neg}" ${Q_pos:+"${Q_pos}"}
			M_VAR_SET([|${Q_res}|], [|-${Q_acc}|])
			;;
		2) M_VAR_SET([|${Q_res}|], [|0|]);;
		3) __sx_num_sub_nat0 "${Q_res}" "${Q_pos}" ${Q_neg:+"${Q_neg}"};;
	esac

	unset CLEANUP
}
|], [|num_add_int|])dnl
popdef([|CLEANUP|])dnl
