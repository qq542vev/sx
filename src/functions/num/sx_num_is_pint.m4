dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|sx_num_is_nat1|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_pint - すべての引数が正の整数であるか確認する
##
## 使い方:
##   sx_num_is_pint [文字列1 [文字列2 ...]]
##
## 説明:
##   任意で正の符号（+）を持つ、1 以上の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて正の整数である (SX_EX_OK)
##    1  正の整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_pint() {
	for Q_arg in "${@}"; do
		sx_num_is_nat1 "${Q_arg#+}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_pint|])dnl
popdef([|CLEANUP|])dnl
