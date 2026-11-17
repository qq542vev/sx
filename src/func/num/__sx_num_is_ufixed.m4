M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_ufixed - すべての引数が符号なし 10 進の実数表記（固定小数点形式）であるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_ufixed [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   符号なし 10 進の実数表記（固定小数点形式）であるかを確認する。
##   整数部は先頭ゼロを許容せず、小数点を含む場合は小数部に 1 文字以上の数字を要求する。
##   したがって、"1.0" は許可されるが "1." や ".1" は許可されない。符号（+ または -）や指数表記は許可しない。
##
## 終了ステータス:
##    0  すべて符号なし 10 進の実数表記である (SX_EX_OK)
##    1  符号なし 10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_ufixed() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in M_NUM_PATTERN_NOT_UFIXED)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_ufixed|])dnl
popdef([|CLEANUP|])dnl
