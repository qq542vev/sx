M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nnint_base10or16 - すべての引数が 0 以上の整数 であるか確認する（基数 10or16 / 内部用）
##
## 使い方:
##   __sx_num_is_nnint_base10or16 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nnint_base10or16 の内部実装。基数は 10or16 に固定し、基数チェックを行わない。
##
## 終了ステータス:
##    0  すべて 0 以上の整数である (SX_EX_OK)
##    1  0 以上の整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_nnint_base10or16() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_REJECT_NNINT_BASE10OR16)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_nnint_base10or16|])dnl
popdef([|CLEANUP|])dnl
