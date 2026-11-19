M_REQUIRE([|__sx_num_cmp_nat0 __sx_num_sub_int __sx_num_sub_nat0 __sx_str_splice __sx_str_zr __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_norm - 数値を10進固定小数点形式に正規化する（内部用）
##
## 使い方:
##   __sx_num_norm バインド形式 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_norm の内部実装。引数の検証は行わない。

define([|CLEANUP|], [|Q_bind Q_arg Q_in Q_mnt Q_dig Q_shift Q_dlen Q_frac|])dnl

__sx_num_norm() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"

	shift

	for Q_arg in ${Q_bind:+"${@}"}; do
		Q_in="${Q_arg#[+-]}"

		case "${Q_in}" in
			0[0-9Xx]*)
				__sx_var_ubind Q_bind "${Q_bind}" "$((Q_arg))" || break
				continue
				;;
			*[Ee]0 | *[Ee][+-]0) Q_in="${Q_in%%[Ee]*}";;
			*[Ee]*)
				# 指数表記の展開
				Q_mnt="${Q_in%%[Ee]*}"

				# ゼロの仮数は指数によらずゼロ
				case "${Q_mnt}" in *[1-9]*) ;; *)
					__sx_var_ubind Q_bind "${Q_bind}" 0 || break
					continue
				esac

				case "${Q_mnt}" in
					*.*)
						Q_frac="${Q_mnt#*.}"
						Q_dig="${Q_mnt%%.*}${Q_frac}"
						__sx_num_sub_int Q_shift "${Q_in#*[Ee]}" "${#Q_frac}"
						;;
					*) Q_dig="${Q_mnt}" Q_shift="${Q_in#*[Ee]}";;
				esac

				Q_dlen="${#Q_dig}"

				if M_STR_MATCH([|"${Q_shift}"|], [|[!-]*|]); then
					__sx_str_zr Q_mnt "${Q_shift}"
					Q_in="M_STR_LTRIM([|Q_dig|], [|[!0]|])${Q_mnt}"
				else
					Q_shift="${Q_shift#-}"

					__sx_num_cmp_nat0 "${Q_shift}" "${Q_dlen}" || case "${?}" in
						1)
							__sx_num_sub_nat0 Q_in "${Q_dlen}" "${Q_shift}"
							__sx_str_splice Q_in "${Q_dig}" "${Q_in}" 0 .

							case "${Q_in}" in
								0*[1-9]*.*) Q_in="M_STR_LTRIM([|Q_in|], [|[!0]|])";;
								00*) Q_in="0.${Q_in#*.}";;
							esac
							;;
						*)
							__sx_num_sub_nat0 Q_in "${Q_shift}" "${Q_dlen}"
							__sx_str_zr Q_mnt "${Q_in}"
							Q_in="${Q_mnt}${Q_dig}"
							M_STR_PREPEND([|Q_in|], [|0.|])
							;;
					esac
				fi
				;;
		esac

		# 小数点以下のクリーンアップ
		case "${Q_in}" in *.*0)
			Q_in="M_STR_RTRIM([|Q_in|], [|[!0]|])"
			Q_in="${Q_in%.}"
		esac

		case "${Q_in}" in 0)
			Q_arg=
		esac

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_arg%%[!-]*}${Q_in}" || break
	done

	unset CLEANUP
}
|], [|num_norm|])dnl
popdef([|CLEANUP|])dnl
