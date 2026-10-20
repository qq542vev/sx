dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|sx_num_is_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_int - すべての引数が整数であるか確認する
##
## 使い方:
##   sx_num_is_int [文字列1 [文字列2 ...]]
##
## 説明:
##   任意で符号（+ または -）を持つ整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて整数である (SX_EX_OK)
##    1  整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_int() {
	for Q_arg in "${@}"; do
		sx_num_is_nat0 "${Q_arg#[+-]}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_int|])dnl
popdef([|CLEANUP|])dnl
