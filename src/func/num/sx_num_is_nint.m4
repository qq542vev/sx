M_REQUIRE([|sx_num_is_nat1|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_nint - すべての引数が負の整数であるか確認する
##
## 使い方:
##   sx_num_is_nint [文字列1 [文字列2 ...]]
##
## 説明:
##   負の符号（-）を必須で持ち、-1 以下の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて負の整数である (SX_EX_OK)
##    1  負の整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			-*) sx_num_is_nat1 "${Q_arg#-}";;
			*) ! :;;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nint|])dnl
popdef([|CLEANUP|])dnl
