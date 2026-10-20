dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_is_int_base sx_num_is_fixed|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_float - すべての引数が 10 進の実数表記（浮動小数点形式）であるか確認する
##
## 使い方:
##   sx_num_is_float [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_fixed に加えて、指数表記（e または E による表記）を許可する。
##   指数部は 10 進整数として検査する。
##
## 終了ステータス:
##    0  すべて 10 進の実数表記である (SX_EX_OK)
##    1  10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_float() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *[Ee]*)
			__sx_num_is_int_base 10 "${Q_arg#*[Ee]}"
		esac && sx_num_is_fixed "${Q_arg%%[Ee]*}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_float|])dnl
popdef([|CLEANUP|])dnl
