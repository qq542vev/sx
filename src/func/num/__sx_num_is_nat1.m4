M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nat1 - すべての引数が 1 以上の自然数（符号なし整数） であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_nat1 [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて 1 以上の自然数である (SX_EX_OK)
##    1  1 以上の自然数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_nat1() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_REJECT_NAT1)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_nat1|])dnl
popdef([|CLEANUP|])dnl
