dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SWORD __sx_arr_push_raw __sx_num_cmp_nat0 __sx_num_sub1_nat0 __sx_num_sub_nat0 __sx_str_quote|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_bind0 - 複数の値をバインド状態に従って順次割り当てる
##
## 使い方:
##   __sx_var_bind0 エスケープフラグ(1/0) 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_var_bind / sx_var_ubind の共通コア実装。
##   データ列を for で巡回し、1 データにつきバインド状態を 1 セグメント分
##   進める。蓄積スロット（数値プレフィックス付き・最後の変数）は
##   Q_esc に応じて値をクォートして累積する。
##   @name / N@name 形式の要素は sx 配列へ値を追加し、クォートは行わない。
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
				Q_lim="${Q_bind%%[!0-9]*}"
				Q_vn="${Q_seg#"${Q_lim}"}"

				case "${Q_vn}" in
					'')
						__sx_num_cmp_nat0 "${Q_lim}" "${#}" || case "${?}" in [12])
							shift "${Q_lim}"
							Q_bind="${Q_bind#*:}"
							continue
						esac

						__sx_num_sub_nat0 Q_lim "${Q_lim}" "${#}"
						shift "${#}"
						;;
					@*)
						Q_tmp="${Q_vn#@}"

						for Q_val in "${@}"; do
							shift

							__sx_arr_push_raw "${Q_tmp}" "${Q_val}"

							case "${Q_lim}" in 1)
								Q_bind="${Q_bind#*:}"
								continue 2
							esac

							M_NUM_DECRM1([|Q_lim|])
						done
						;;
					*)
						Q_tmp=

						for Q_val in "${@}"; do
							shift

							case "${Q_esc}" in 1)
								__sx_str_quote Q_val "${Q_val}"
							esac

							Q_tmp="${Q_tmp} ${Q_val}"

							case "${Q_lim}" in 1)
								eval "${Q_vn}=\"\${${Q_vn}-}\${${Q_vn}:+ }\${Q_tmp# }\""
								Q_bind="${Q_bind#*:}"
								continue 2
							esac

							M_NUM_DECRM1([|Q_lim|])
						done

						eval "${Q_vn}=\"\${${Q_vn}-}\${${Q_vn}:+ }\${Q_tmp# }\""
						;;
					'')
				esac

				Q_bind="${Q_lim}${Q_vn}:${Q_bind#*:}"
				break
				;;
			["${SX_STR_SWORD}"]*:*) M_VAR_SET([|${Q_bind%%:*}|], [|${1}|]);&
			:*)
				Q_bind="${Q_bind#*:}"
				shift
				;;
			@*)
				__sx_arr_push_raw "${Q_bind#@}" "${@}"
				break
				;;
			?*)
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
