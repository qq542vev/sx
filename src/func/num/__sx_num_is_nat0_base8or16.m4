M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nat0_base8or16 - すべての引数が 0 以上の自然数（符号なし整数） であるか確認する（基数 8or16 / 内部用）
##
## 使い方:
##   __sx_num_is_nat0_base8or16 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat0_base8or16 の内部実装。基数は 8or16 に固定し、基数チェックを行わない。
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_nat0_base8or16() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_REJECT_NAT0_BASE8OR16)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_nat0_base8or16|])dnl
popdef([|CLEANUP|])dnl
