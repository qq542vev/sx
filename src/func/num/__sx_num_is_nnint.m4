M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nnint - すべての引数が非負整数（0以上の整数）であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_nnint [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   0（+0, -0 を含む）または正の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて非負整数である (SX_EX_OK)
##    1  非負整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_nnint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_PATTERN_NOT_NNINT)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_nnint|])dnl
popdef([|CLEANUP|])dnl
