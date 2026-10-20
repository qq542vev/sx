dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int_fit - 指定されたビット幅の符号付き整数の範囲内か確認する（内部ロジック）

define([|CLEANUP|], [|Q_arg Q_bit Q_xlen Q_olenn Q_oleadn Q_olenp Q_oleadp|])dnl

__sx_num_is_int_fit() {
	Q_bit="${1}"
	shift

	for Q_arg in "${@}"; do
		# $1: 値（符号正規化）, $2: 数値部分の長さ
		set -- "${Q_arg#+}" "${#Q_arg}"
		case "${Q_arg}" in +* | -*)
			set -- "${1}" "$((${2} - 1))"
		esac

		case "${1}" in
			0[Xx]* | -0[Xx]*)
			# 基数16のパラメータ計算
			: ${Q_xlen=$((Q_bit / 4 + 2))}

				if
					M_NUM_LT([|Q_xlen|], [|${2}|]) || {
						M_STR_EQ([|"${Q_xlen}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[Xx][9ABCDEFabcdef]*|], [|-0[Xx]8*[!0]*|], [|0[Xx][89ABCDEFabcdef]*|])
					}
				then
					unset CLEANUP
					return 1
				fi
				;;
			0?* | -0?*)
				# 基数8のパラメータ計算
				: ${Q_olenn=$(((Q_bit - 1) / 3 + 2))}
				: ${Q_oleadn=$((1 << ((Q_bit - 1) % 3)))}
				: ${Q_olenp=$((Q_olenn - (Q_oleadn == 1)))}
				: ${Q_oleadp=$((Q_oleadn == 1 ? 7 : Q_oleadn - 1))}

				# $3: 制限長さ, $4: 制限先頭文字
				case "${1}" in
					-*) set -- "${1}" "${2}" "${Q_olenn}" "${Q_oleadn}";;
					*)  set -- "${1}" "${2}" "${Q_olenp}" "${Q_oleadp}";;
				esac

				if
					M_NUM_LT([|${3}|], [|${2}|]) || {
						M_STR_EQ([|"${3}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[!1-${4}]*|], [|-0${4}*[!0]*|], [|0[!1-${4}-]*|])
					}
				then
					unset CLEANUP
					return 1
				fi
				;;
			*)
				__sx_num_is_int_fit_dec "${Q_bit}" "${Q_arg}" || {
					unset CLEANUP
					return 1
				}
				;;
			esac
	done

	unset CLEANUP
}
|], [|num_is_int_fit|])dnl
popdef([|CLEANUP|])dnl
