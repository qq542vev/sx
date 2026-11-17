M_REQUIRE([|__sx_num_is_ufixed|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_ufloat - すべての引数が符号なし 10 進の実数表記（浮動小数点形式）であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_ufloat [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   符号なし 10 進の実数表記（浮動小数点形式）であるかを確認する。
##   sx_num_is_ufixed に加えて、指数表記（e または E による表記）を許可する。
##   指数なしは __sx_num_is_ufixed に委譲し、指数ありは各引数を直接検査する。
##
## 終了ステータス:
##    0  すべて符号なし 10 進の実数表記である (SX_EX_OK)
##    1  符号なし 10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_ufloat() {
	case "${*}" in *[Ee]*) ;; *)
		__sx_num_is_ufixed "${@}" || return
		return
	esac

	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_PATTERN_NOT_UFLOAT)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_ufloat|])dnl
popdef([|CLEANUP|])dnl
