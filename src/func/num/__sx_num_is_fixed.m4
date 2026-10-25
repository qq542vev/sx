M_REQUIRE([|__sx_num_is_int_base __sx_str_is_digit|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_fixed - すべての引数が 10 進の実数表記（固定小数点形式）であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_fixed [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   任意で符号（+ または -）を持つ 10 進の実数表記（固定小数点形式）であるかを確認する。
##   整数部は 10 進整数として検査し、小数点を含む場合は小数部に 1 文字以上の数字を要求する。
##   したがって、"1.0" は許可されるが "1." や ".1" は許可されない。
##
## 終了ステータス:
##    0  すべて 10 進の実数表記である (SX_EX_OK)
##    1  10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_fixed() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *.*)
			__sx_str_is_digit "${Q_arg#*.}"
		esac && __sx_num_is_int_base 10 "${Q_arg%%.*}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_fixed|])dnl
popdef([|CLEANUP|])dnl
