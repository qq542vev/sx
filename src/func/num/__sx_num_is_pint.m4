M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_pint - すべての引数が正の整数であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_pint [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   任意で正の符号（+）を持つ、1 以上の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて正の整数である (SX_EX_OK)
##    1  正の整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_pint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_PATTERN_NOT_PINT)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_pint|])dnl
popdef([|CLEANUP|])dnl
