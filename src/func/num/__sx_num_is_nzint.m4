M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nzint - すべての引数が 0 以外の整数であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_nzint [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   0（+0, -0 を含む）以外の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて 0 以外の整数である (SX_EX_OK)
##    1  0、または整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_nzint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_REJECT_NZINT)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_nzint|])dnl
popdef([|CLEANUP|])dnl
