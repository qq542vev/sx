dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SWORD __sx_num_add1_nat0 __sx_num_add_nat0 __sx_num_cmp_nat0 __sx_num_sub_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_bind - 配列対応バインドで変数を順次割り当てる（内部用）
##
## 使い方:
##   __sx_arr_bind bind_res chain_res bind varname1 [varname2 ...]
##
## 説明:
##   bind文字列を逐次解析し、chain (src-dst) と残りbindを生成する。
##   バインド先が枯渇し、未処理の変数名が残る場合は終了ステータス 1 を返し、
##   bind_res に残りのバインド形式（枯渇時は空文字列）、chain_res に途中までの
##   chain を書き込む。
##
## 終了ステータス:
##    0  全て割り当て、残りのバインド形式と chain を各結果変数に格納した
##    1  バインド先が枯渇したまま変数名が残っている。bind_res へ空文字列を書き込む

define([|CLEANUP|], [|Q_bres Q_cres Q_bind Q_chain Q_seg Q_frac Q_cnt Q_lim Q_vn Q_arg Q_tmp|])dnl

__sx_arr_bind() {
	Q_bres="${1}"
	Q_cres="${2}"
	Q_bind="${3}${3:+:}"
	Q_chain=
	shift 3

	while M_STR_NE([|"${#}"|], [|0|]); do
		case "${Q_bind}" in
			[0-9]*)
				Q_seg="${Q_bind%%:*}"
				Q_frac="${Q_bind%%[!/0-9]*}"
				Q_cnt="${Q_frac%/*}"
				Q_lim="${Q_frac#*/}"
				Q_vn="${Q_seg#"${Q_frac}"}"

				case "${Q_lim}:${Q_vn}" in
					# seg: M/
					:)
						__sx_num_add_nat0 Q_cnt "${Q_cnt}" "${#}"
						shift "${#}"
						;;
					# seg: M/vn
					:*)
						for Q_arg in "${@}"; do
							M_STR_APPEND([|Q_chain|], [|" ${Q_arg}-${Q_vn}_${Q_cnt}"|])
							M_NUM_INCRM1([|Q_cnt|])
						done

						shift "${#}"
						;;
					# seg: M/N
					*:)
						__sx_num_sub_nat0 Q_tmp "${Q_lim}" "${Q_cnt}"
						__sx_num_cmp_nat0 "${Q_tmp}" "${#}" || case "${?}" in [12])
							shift "${Q_tmp}"
							Q_bind="${Q_bind#*:}"
							continue
						esac

						__sx_num_add_nat0 Q_cnt "${Q_cnt}" "${#}"
						shift "${#}"
						;;
					*)
						for Q_arg in "${@}"; do
							shift
							M_STR_APPEND([|Q_chain|], [|" ${Q_arg}-${Q_vn}_${Q_cnt}"|])
							M_NUM_INCRM1([|Q_cnt|])

							case "${Q_cnt}" in "${Q_lim}")
								Q_bind="${Q_bind#*:}"
								continue 2
							esac
						done
						;;
				esac

				Q_bind="${Q_cnt}/${Q_lim}${Q_vn}:${Q_bind#*:}"
				;;
			["${SX_STR_SWORD}"]*) M_STR_APPEND([|Q_chain|], [|" ${1}-${Q_bind%%:*}"|]);&
			:*)
				Q_bind="${Q_bind#*:}"
				shift
				;;
			'')
				case "${Q_bres:+X}" in X)
					M_VAR_SET([|${Q_bres}|], [|${Q_bind}|])
				esac

				eval "${Q_cres}=\"\${${Q_cres}-}\${Q_chain}\" ${Q_cres}=\"\${${Q_cres}# }\""

				unset CLEANUP
				return 1
				;;
		esac
	done

	case "${Q_bres:+X}" in X)
		M_VAR_SET([|${Q_bres}|], [|${Q_bind%:}|])
	esac

	eval "${Q_cres}=\"\${${Q_cres}-}\${Q_chain}\" ${Q_cres}=\"\${${Q_cres}# }\""

	unset CLEANUP
}
|], [|arr_bind|])dnl
popdef([|CLEANUP|])dnl
