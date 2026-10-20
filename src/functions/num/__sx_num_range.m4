dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_SYS_NUM_MIN __sx_num_add_int __sx_num_cmp_fixed __sx_num_divmod_int __sx_num_is_int_fit_dec __sx_num_sub_int __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_range - 数値の範囲を生成する（内部用）
##
## 使い方:
##   __sx_num_range 宛先 [引数...]
##
## 説明:
##   sx_num_range の内部実装。引数チェックを行わない。

define([|CLEANUP|], [|Q_bind Q_tmp Q_s Q_e Q_t Q_c Q_p Q_e1 Q_diff|])dnl

__sx_num_range() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	case "${#}" in
		1) set -- 0 "${1}" 1;;
		2) set -- "${1}" "${2}" 1;;
	esac

	Q_s="${1#+}" Q_e="${2}" Q_t="${3}"

	case "${Q_s}" in -0)
		Q_s=0
	esac

	# 高速経路: 全入力が設定幅に収まり、増分が最小値でない場合。
	# 最小値の増分は絶対値化で溢れるため低速経路に回す。
	# 幅と増分の組み合わせは新しい入力のみで判定する。
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${1}" "${2}" "${3}" && M_STR_NE([|"${3}"|], [|"${SX_SYS_NUM_MIN}"|]); then
		case "$((Q_s == Q_e || (Q_s < Q_e && Q_t < 0) || (Q_e < Q_s && 0 < Q_t)))" in 1)
			unset CLEANUP
			return
		esac

		# 最終要素の算出。空判定済みのため端の加減算は溢れない。
		# 中間結果は被演算子の大きさを超えない。
		# 符号は文字列で判定し、以降の算術は直線的に行う。
		Q_c=$((Q_t < 0 ? 1 : -1))
		Q_p="${Q_t#-}"
		Q_e1=$((Q_e + Q_c))
		Q_diff=$((((Q_s % Q_p) + Q_p * (Q_s < 0)) - ((Q_e1 % Q_p) + Q_p * (Q_e1 < 0))))
		# 被演算子の順番変更を行わないこと。桁溢れの可能性あり。
		Q_e=$((Q_diff - Q_t * (Q_c * Q_diff < 0) + Q_e1))

		while
			__sx_var_ubind Q_bind "${Q_bind}" "${Q_s}" || break

			case "${Q_s}" in "${Q_e}")
				break
			esac

			Q_s=$((Q_s + Q_t))
			continue
		do :; done
	else
		__sx_num_cmp_fixed "${Q_s}" "${Q_e}" || case "${?}${Q_t}" in 1-* | 2* | 3[!-]*)
			unset CLEANUP
			return
		esac

		__sx_num_sub_int Q_e1 "${Q_e}" "${Q_t%%[0-9]*}1"
		__sx_num_sub_int Q_tmp "${Q_s}" "${Q_e1}"
		__sx_num_divmod_int :Q_tmp: "${Q_tmp}" "${Q_t}"
		__sx_num_add_int Q_e "${Q_e1}" "${Q_tmp}"

		while
			__sx_var_ubind Q_bind "${Q_bind}" "${Q_s}" || break

			case "${Q_s}" in "${Q_e}")
				break
			esac

			__sx_num_add_int Q_s "${Q_s}" "${Q_t}"
			continue
		do :; done
	fi

	unset CLEANUP
}
|], [|num_range|])dnl
popdef([|CLEANUP|])dnl
