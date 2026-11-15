M_REQUIRE([|__sx_num_is_float __sx_num_cmp_nat0 SX_CFG_FLOAT_EXP_MAX|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_float_safe - すべての引数が安全な範囲の 10 進の実数表記であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_float_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   sx_num_is_float による形式検証に加えて、設定項目 SX_CFG_FLOAT_EXP_MAX で
##   指数の絶対値を制限する（|指数| < SX_CFG_FLOAT_EXP_MAX を受理、それ以上を拒否）。
##
## 終了ステータス:
##    0  すべて安全な 10 進の実数表記である (SX_EX_OK)
##    1  安全ではない、または 10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg Q_exp|])dnl

__sx_num_is_float_safe() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*[Ee]*)
				Q_exp="${Q_arg#*[Ee]}"
				case "${Q_exp}" in
					-*) Q_exp="${Q_exp#-}";;
					+*) Q_exp="${Q_exp#+}";;
				esac
				__sx_num_cmp_nat0 "${Q_exp}" "${SX_CFG_FLOAT_EXP_MAX}" || case "${?}" in
					1) :;;
					*)
						unset CLEANUP
						return 1
						;;
				esac
				;;
		esac
		__sx_num_is_float "${Q_arg}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_float_safe|])dnl
popdef([|CLEANUP|])dnl
