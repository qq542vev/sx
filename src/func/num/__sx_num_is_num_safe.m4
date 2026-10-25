M_REQUIRE([|__sx_num_is_float_safe __sx_num_is_int_safe|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_num_safe - すべての引数が有効な数値形式であるか検証する（内部用）
##
## 使い方:
##   __sx_num_is_num_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   引数が 16進数または 8進数の形式である場合は __sx_num_is_int_safe で、
##   それ以外の場合は sx_num_is_float_safe で検証を行う。
##
## 終了ステータス:
##    0  すべて有効な数値である (SX_EX_OK)
##    1  有効な数値ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_num_safe() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*[Xx]* | [+-]0[0-9]* | 0[0-9]*) __sx_num_is_int_safe "${Q_arg}";;
			*) __sx_num_is_float_safe "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_num_safe|])dnl
popdef([|CLEANUP|])dnl
