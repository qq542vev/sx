M_REQUIRE([|__sx_num_is_nint|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_npint - すべての引数が非正整数（0以下の整数）であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_npint [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   0（+0, -0 を含む）または負の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて非正整数である (SX_EX_OK)
##    1  非正整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_npint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			00 | [+-]00 | 0 | [+-]0 | 0[Xx]0 | [+-]0[Xx]0) continue;;
		esac

		__sx_num_is_nint "${Q_arg}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_npint|])dnl
popdef([|CLEANUP|])dnl
