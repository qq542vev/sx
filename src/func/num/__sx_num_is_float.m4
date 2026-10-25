M_REQUIRE([|__sx_num_is_fixed __sx_num_is_int_base|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_float - すべての引数が 10 進の実数表記（浮動小数点形式）であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_float [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   sx_num_is_fixed に加えて、指数表記（e または E による表記）を許可する。
##   指数部は 10 進整数として検査する。
##
## 終了ステータス:
##    0  すべて 10 進の実数表記である (SX_EX_OK)
##    1  10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_float() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *[Ee]*)
			__sx_num_is_int_base 10 "${Q_arg#*[Ee]}"
		esac && __sx_num_is_fixed "${Q_arg%%[Ee]*}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_float|])dnl
popdef([|CLEANUP|])dnl
