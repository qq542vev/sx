M_REQUIRE([|SX_CFG_NUM_RANGE __sx_arr_to_int __sx_num_cmp_nat0 __sx_num_divmod_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_nat0 __sx_num_sub_int __sx_num_sub_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_has - 配列の全 spec が1要素以上に一致するか確認する（内部用）
##
## 使い方:
##   __sx_arr_has 配列名 [spec ...]
##
## 説明:
##   sx_arr_has の内部実装。
##   引数チェックは行わない。
##   各 spec を正確な等差数列と定義域の交叉で評価し（sx_arr_get と同一式）、
##   始点を定義域へ寄せた後、最初の有効な添字の有無だけを判定する。
##   空の spec があれば 1 を返し、完走すれば 0 を返す。書き込みは行わない。

define([|CLEANUP|], [|Q_len Q_spec Q_s Q_e Q_t Q_c Q_tmp|])dnl

__sx_arr_has() {
	eval "Q_len=\"\${${1}_len}\""
	shift

	case "${Q_len}${#}" in 0[1-9]*)
		unset CLEANUP
		return 1
		;;
	esac

	for Q_spec in "${@}"; do
		case "${Q_spec}" in
			*:*)
				Q_e="${Q_spec#*:}"

				case "${Q_e}" in
					*:*) Q_t="${Q_e#*:}" Q_e="${Q_e%:*}";;
					*) Q_t=1;;
				esac

			case "${Q_spec%%:*}:${Q_t}" in
				:-*) __sx_num_sub1_nat0 Q_s "${Q_len}";;
				:*) Q_s=0;;
				*) __sx_arr_to_int Q_s "${Q_spec%%:*}" "${Q_len}";;
			esac

			case "${Q_e}:${Q_t}" in
				:-*) Q_e=0;;
				:*) Q_e="${Q_len}";;
				*) __sx_arr_to_int Q_e "${Q_e}" "${Q_len}";;
			esac

			case "${Q_t}" in
				-*)
					case "${Q_s}" in -*) unset CLEANUP; return 1;; esac
					case "${Q_e}" in -*) Q_e=0;; esac
					Q_t="${Q_t#-}"

					if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_s}" "${Q_e}" "${Q_t}"; then
						# 定義域内の元の始点と同じ剰余を持つ最大の値へ寄せる。
						case "$((Q_len <= Q_s))" in 1)
							Q_s=$((Q_len - Q_t + ((Q_s - Q_len) % Q_t)))
						esac
						case "$((Q_s < Q_e))" in 1) unset CLEANUP; return 1;; esac
					else
						__sx_num_cmp_nat0 "${Q_s}" "${Q_len}" || case "${?}" in [23])
							__sx_num_sub1_nat0 Q_c "${Q_len}"
							__sx_num_sub_nat0 Q_tmp "${Q_s}" "${Q_c}"
							__sx_num_divmod_nat0 :Q_tmp: "${Q_tmp}" "${Q_t}"

							case "${Q_tmp}" in
								0) Q_s="${Q_c}";;
								*) __sx_num_sub_nat0 Q_tmp "${Q_t}" "${Q_tmp}"
									__sx_num_sub_int Q_s "${Q_c}" "${Q_tmp}"
									;;
							esac
						esac

						case "${Q_s}" in -*) unset CLEANUP; return 1;; esac
						__sx_num_cmp_nat0 "${Q_s}" "${Q_e}" || case "${?}" in 1)
							unset CLEANUP
							return 1
						esac
					fi
					;;
				*)
					# 正方向の終点は排他的。0 以下なら必ず空となる。
					case "${Q_e}" in [-0]*) unset CLEANUP; return 1;; esac

					if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_s}" "${Q_e}" "${Q_t}"; then
						# 負の始点を位相を保って 0 以上へ寄せる。MIN の反転を避ける。
						case "${Q_s}" in -*)
							Q_s=$((Q_t - 1 + ((Q_s + 1) % Q_t)))
						esac
						case "$((Q_s < Q_e && Q_s < Q_len))" in 0) unset CLEANUP; return 1;; esac
					else
						Q_t="${Q_t#+}"
						case "${Q_s}" in -*)
							__sx_num_divmod_nat0 :Q_tmp: "${Q_s#-}" "${Q_t}"

							case "${Q_tmp}" in
								0) Q_s=0;;
								*) __sx_num_sub_nat0 Q_s "${Q_t}" "${Q_tmp}";;
							esac
							esac

						__sx_num_cmp_nat0 "${Q_s}" "${Q_e}" || case "${?}" in [23]) unset CLEANUP; return 1;; esac
						__sx_num_cmp_nat0 "${Q_s}" "${Q_len}" || case "${?}" in [23]) unset CLEANUP; return 1;; esac
					fi
					;;
				esac
				;;
			*)
				__sx_num_cmp_nat0 "${Q_spec#[+-]}" "${Q_len}" || case "${?}${Q_spec}" in
					1* | 2-*) ;;
					*) unset CLEANUP; return 1;;
				esac
				;;
		esac
	done

	unset CLEANUP
}
|], [|arr_has|])dnl
popdef([|CLEANUP|])dnl
