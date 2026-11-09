M_REQUIRE([|__sx_arg_between __sx_arr_push_raw __sx_num_sub1_nat0 __sx_num_sub_nat0 __sx_str_quote|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_bind0 - 複数の値をバインド状態に従って順次割り当てる
##
## 使い方:
##   __sx_var_bind0 エスケープフラグ(1/0) 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   sx_var_bind / sx_var_ubind の共通コア実装。
##   データ列を for で巡回し、1 データにつきバインド状態を 1 セグメント分
##   進める。蓄積スロット（数値プレフィックス付き・最後の変数）は
##   Q_esc に応じて値をクォートして累積する。
##   @name / N@name 形式の要素は sx 配列へ値を追加し、クォートは行わない。
##   個数指定の読み飛ばしは command shift の成否で判定し、事前の多倍長比較を省く。
##   結果変数名が空文字列の場合は残りのバインド形式を破棄する。
##   バインド先が枯渇した場合は Q_res が空でない場合に限り空の残りバインドを書き込んで 1 を返す。
##
## 終了ステータス:
##    0  データを全て割り当て、結果変数が空でない場合に限り残りのバインド形式を格納した
##    1  バインド先が枯渇したままデータが残っている。結果変数が空でない場合に限り空文字列を書き込む

define([|CLEANUP|], [|Q_esc Q_res Q_bind Q_seg Q_lim Q_vn Q_tmp Q_val|])dnl
__sx_var_bind0() {
	Q_esc="${1}"
	Q_res="${2}"
	Q_bind="${3}"
	shift 3

	while M_STR_NE([|"${#}"|], [|0|]); do
		case "${Q_bind}" in
			[1-9]*:*)
				Q_seg="${Q_bind%%:*}"
				Q_lim="${Q_seg%%[!0-9]*}"
				Q_vn="${Q_seg#"${Q_lim}"}"

				case "${Q_vn}" in
					'')
						if command shift "${Q_lim}" 2>&-; then
							Q_lim=0
						else
							__sx_num_sub_nat0 Q_lim "${Q_lim}" "${#}"
							set --
						fi
						;;
					@*)
						Q_tmp="${Q_vn#@}"

						if __sx_arg_between '' "${Q_lim}" "${@}"; then
							__sx_arr_push_raw "${Q_tmp}" "${@}"
							__sx_num_sub_nat0 Q_lim "${Q_lim}" "${#}"
							set --
						else
							for Q_val in "${@}"; do
								shift

								__sx_arr_push_raw "${Q_tmp}" "${Q_val}"

								case "${Q_lim}" in 1)
									Q_lim=0
									break
								esac

								M_NUM_DECRM1([|Q_lim|])
							done
						fi
						;;
					*)
						if M_STR_MATCH([|"${Q_esc}${IFS- }"|], [|'0 '*|]) && __sx_arg_between '' "${Q_lim}" "${@}"; then
							eval "${Q_vn}=\"\${${Q_vn}-}\${${Q_vn}:+ }\${*}\""
							__sx_num_sub_nat0 Q_lim "${Q_lim}" "${#}"
							set --
						else
							Q_tmp=

							for Q_val in "${@}"; do
								shift

								case "${Q_esc}" in 1)
									__sx_str_quote Q_val "${Q_val}"
								esac

								Q_tmp="${Q_tmp} ${Q_val}"

								case "${Q_lim}" in 1)
									Q_lim=0
									break
								esac

								M_NUM_DECRM1([|Q_lim|])
							done

							eval "${Q_vn}=\"\${${Q_vn}-}\${${Q_vn}:+ }\${Q_tmp# }\""
						fi
						;;
				esac

				case "${Q_lim}" in
					0) Q_bind="${Q_bind#*:}";;
					*) Q_bind="${Q_lim}${Q_vn}:${Q_bind#*:}";;
				esac
				;;
			["M_STR_ALUND()"]*:*) M_VAR_SET([|${Q_bind%%:*}|], [|${1}|]);&
			:*)
				Q_bind="${Q_bind#*:}"
				shift
				;;
			@*)
				__sx_arr_push_raw "${Q_bind#@}" "${@}"
				break
				;;
			?*)
				case "${Q_esc}${IFS- }" in '0 '*)
					eval "${Q_bind}=\"\${${Q_bind}-}\${${Q_bind}:+ }\${*}\""
					break
				esac

				Q_tmp=

				for Q_val in "${@}";do
					case "${Q_esc}" in 1)
						__sx_str_quote Q_val "${Q_val}"
					esac

					Q_tmp="${Q_tmp} ${Q_val}"
				done

				eval "${Q_bind}=\"\${${Q_bind}-}\${${Q_bind}:+ }\${Q_tmp# }\""
				break
				;;
			*)
				case "${Q_res:+X}" in X)
					M_VAR_SET([|${Q_res}|], [|${Q_bind}|])
				esac

				unset CLEANUP
				return 1
				;;
		esac
	done

	case "${Q_res:+X}" in X)
		M_VAR_SET([|${Q_res}|], [|${Q_bind}|])
	esac

	unset CLEANUP
}
|], [|var_bind0|])dnl
popdef([|CLEANUP|])dnl
