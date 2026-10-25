M_REQUIRE([|__sx_num_is_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int - すべての引数が整数であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_int [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   任意で符号（+ または -）を持つ整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて整数である (SX_EX_OK)
##    1  整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_int() {
	for Q_arg in "${@}"; do
		__sx_num_is_nat0 "${Q_arg#[+-]}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_int|])dnl
popdef([|CLEANUP|])dnl
