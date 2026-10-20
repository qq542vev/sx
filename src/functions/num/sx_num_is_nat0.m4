dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_is_nat0_base|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_nat0 - すべての引数が 0 以上の自然数（符号なし整数） であるか確認する
##
## 使い方:
##   sx_num_is_nat0 [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nat0() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0[Xx]*) __sx_num_is_nat0_base 16 "${Q_arg}";;
			0?*) __sx_num_is_nat0_base 8 "${Q_arg}";;
			*) __sx_num_is_nat0_base 10 "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nat0|])dnl
popdef([|CLEANUP|])dnl
