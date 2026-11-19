M_REQUIRE([|__sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int_fit - 指定されたビット幅の符号付き整数の範囲内か確認する（内部ロジック）

define([|CLEANUP|], [|Q_arg Q_alen Q_bit Q_xlen Q_olenn Q_oleadn Q_olenp Q_oleadp|])dnl

__sx_num_is_int_fit() {
	Q_bit="${1}"
	shift

	for Q_arg in "${@}"; do
		# $1: 値（符号正規化）, $2: 数値部分の長さ
		Q_alen="${#Q_arg}"

		case "${Q_alen}" in ???*)
			unset CLEANUP
			return 1
		esac

		case "${Q_arg}" in
			+*) Q_arg="${Q_arg#+}";&
			-*) Q_alen=$((Q_alen - 1));;
		esac

		case "${Q_arg}" in
			0[Xx]* | -0[Xx]*)
				# 基数16のパラメータ計算
				case "${Q_xlen+X}" in '')
					Q_xlen=$((Q_bit / 4 + 2))
				esac

				M_NUM_LT([|Q_alen|], [|Q_xlen|]) || {
					M_STR_EQ([|"${Q_alen}"|], [|"${Q_xlen}"|]) &&
					! M_STR_MATCH([|"${Q_arg}"|], [|-0[Xx][9ABCDEFabcdef]*|], [|-0[Xx]8*[!0]*|], [|0[Xx][89ABCDEFabcdef]*|])
				}
				;;
			0?* | -0?*)
				# 基数8のパラメータ計算
				case "${Q_olenn+X}" in '')
					Q_olenn=$(((Q_bit - 1) / 3 + 2))
					Q_oleadn=$((1 << ((Q_bit - 1) % 3)))
					Q_olenp=$((Q_olenn - (Q_oleadn == 1)))
					Q_oleadp=$((Q_oleadn == 1 ? 7 : Q_oleadn - 1))
				esac

				# $3: 制限長さ, $4: 制限先頭文字
				case "${Q_arg}" in
					-*)
						M_NUM_LT([|Q_alen|], [|Q_olenn|]) || {
							M_STR_EQ([|"${Q_alen}"|], [|"${Q_olenn}"|]) &&
							! M_STR_MATCH([|"${Q_arg}"|], [|-0[!1-${Q_oleadn}]*|], [|-0${Q_oleadn}*[!0]*|])
						};;
					*)
						M_NUM_LT([|Q_alen|], [|Q_olenp|]) || {
							M_STR_EQ([|"${Q_alen}"|], [|"${Q_olenp}"|]) &&
							M_STR_MATCH([|"${Q_arg}"|], [|0[1-${Q_oleadp}]*|])
						};;
				esac
				;;
			*) __sx_num_is_int_fit_dec "${Q_bit}" "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_int_fit|])dnl
popdef([|CLEANUP|])dnl
