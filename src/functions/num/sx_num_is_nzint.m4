M_REQUIRE([|sx_num_is_int|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_nzint - すべての引数が 0 以外の整数であるか確認する
##
## 使い方:
##   sx_num_is_nzint [文字列1 [文字列2 ...]]
##
## 説明:
##   0（+0, -0 を含む）以外の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて 0 以外の整数である (SX_EX_OK)
##    1  0、または整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nzint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0 | [+-]0 | 00 | [+-]00 | 0[Xx]0 | [+-]0[Xx]0) ! :;;
			*) sx_num_is_int "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nzint|])dnl
popdef([|CLEANUP|])dnl
