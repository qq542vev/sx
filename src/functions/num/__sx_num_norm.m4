M_REQUIRE([|__sx_str_pad __sx_str_splice __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_norm - 数値を10進固定小数点形式に正規化する（内部用）
##
## 使い方:
##   __sx_num_norm バインド形式 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_norm の内部実装。引数の検証は行わない。

define([|CLEANUP|], [|Q_bind Q_arg Q_in Q_mnt Q_dig Q_flen Q_shift Q_dlen|])dnl

__sx_num_norm() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"

	shift

	for Q_arg in "${@}"; do
		Q_in="${Q_arg#[+-]}"

		case "${Q_in}" in
			0[Xx]* | 0[0-9]*) Q_in=$((Q_in));;
			*[Ee]*)
				# 指数表記の展開
				Q_mnt="${Q_in%%[Ee]*}"
				Q_dig="${Q_mnt%%.*}"

				case "${Q_mnt}" in
					*.*)
						Q_flen=$((${#Q_mnt} - ${#Q_dig} - 1))
						M_STR_APPEND([|Q_dig|], [|"${Q_mnt#*.}"|])
						;;
					*) Q_flen=0;;
				esac

				Q_shift=$((${Q_in#*[Ee]} - Q_flen))
					Q_dlen="${#Q_dig}"

				if M_NUM_LE([|0|], [|Q_shift|]); then
					__sx_str_pad Q_in "${Q_dig}" "-$((Q_dlen + Q_shift))" 0
				else
					: $((Q_shift *= -1))

					if M_NUM_LT([|Q_shift|], [|Q_dlen|]); then
						__sx_str_splice Q_in "${Q_dig}" "$((Q_dlen - Q_shift))" 0 .
					else
						__sx_str_pad Q_in "${Q_dig}" "${Q_shift}" 0
						M_STR_PREPEND([|Q_in|], [|.|])
					fi
				fi

				Q_in="M_STR_LTRIM([|Q_in|], [|[!0]|])"

				case "${Q_in}" in .*)
					M_STR_PREPEND([|Q_in|], [|0|])
				esac
				;;
		esac

		# 小数点以下のクリーンアップ
		case "${Q_in}" in *.*)
			Q_in="M_STR_RTRIM([|Q_in|], [|[!0]|])"
			Q_in="${Q_in%.}"
		esac

		case "${Q_in}" in '' | 0)
			Q_arg=
		esac

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_arg%%[!-]*}${Q_in:-0}" || break
	done

	unset CLEANUP
}
|], [|num_norm|])dnl
popdef([|CLEANUP|])dnl
