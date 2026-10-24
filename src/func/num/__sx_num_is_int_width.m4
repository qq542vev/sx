M_REQUIRE([|__sx_num_is_int_fit sx_num_is_int|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int_width - すべての引数が指定されたビット幅の符号付き整数の範囲内か確認する（内部用）

define([|CLEANUP|], [|Q_bits|])dnl

__sx_num_is_int_width() {
	Q_bits="${1}"
	shift

	sx_num_is_int "${@}" || {
		unset CLEANUP
		return 1
	}

	set -- "${Q_bits}" "${@}"
	unset CLEANUP

	__sx_num_is_int_fit "${@}" || return
}
|], [|num_is_int_width|])dnl
popdef([|CLEANUP|])dnl
