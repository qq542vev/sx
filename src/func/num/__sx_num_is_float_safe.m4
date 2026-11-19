M_REQUIRE([|SX_CFG_NUM_FLOAT_EXP_MAX __sx_num_cmp_nat0 __sx_num_is_fixed __sx_num_is_float|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_float_safe - すべての引数が安全な範囲の 10 進の実数表記であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_float_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   sx_num_is_float による形式検証に加えて、設定項目 SX_CFG_NUM_FLOAT_EXP_MAX で
##   指数の絶対値を制限する（|指数| <= SX_CFG_NUM_FLOAT_EXP_MAX を受理、それより大きいものを拒否）。
##
## 終了ステータス:
##    0  すべて安全な 10 進の実数表記である (SX_EX_OK)
##    1  安全ではない、または 10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_float_safe() {
	case "${*}" in *[Ee]*) ;; *)
		__sx_num_is_fixed "${@}" || return
		return
	esac

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*[Ee]*)
				__sx_num_is_float "${Q_arg}" && {
					Q_arg="${Q_arg#*[Ee]}"
					__sx_num_cmp_nat0 "${Q_arg#[+-]}" "${SX_CFG_NUM_FLOAT_EXP_MAX}" || case "${?}" in 3) ! :;; esac
				}
				;;
			*) __sx_num_is_fixed "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_float_safe|])dnl
popdef([|CLEANUP|])dnl
