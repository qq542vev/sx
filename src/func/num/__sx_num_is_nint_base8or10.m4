M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nint_base8or10 - すべての引数が -1 以下の整数 であるか確認する（基数 8or10 / 内部用）
##
## 使い方:
##   __sx_num_is_nint_base8or10 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nint_base8or10 の内部実装。基数は 8or10 に固定し、基数チェックを行わない。
##
## 終了ステータス:
##    0  すべて -1 以下の整数である (SX_EX_OK)
##    1  -1 以下の整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_nint_base8or10() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_REJECT_NINT_BASE8OR10)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_nint_base8or10|])dnl
popdef([|CLEANUP|])dnl
