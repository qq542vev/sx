M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nint - すべての引数が負の整数であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_nint [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   負の符号（-）を必須で持ち、-1 以下の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて負の整数である (SX_EX_OK)
##    1  負の整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_nint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_PATTERN_NOT_NINT)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_nint|])dnl
popdef([|CLEANUP|])dnl
