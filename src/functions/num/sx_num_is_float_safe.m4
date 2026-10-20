dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|sx_num_is_float|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_float_safe - すべての引数が安全な範囲の 10 進の実数表記であるか確認する
##
## 使い方:
##   sx_num_is_float_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_float による検証に加えて、セキュリティ上の理由（DoS 対策）から、
##   指数の絶対値を 4 桁（9999）までに制限する。
##
## 終了ステータス:
##    0  すべて安全な 10 進の実数表記である (SX_EX_OK)
##    1  安全ではない、または 10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_float_safe() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			# DoS 対策: 指数の絶対値は 4 桁まで
			*[Ee][+-]?????* | *[Ee][!+-]????*) ! :;;
			*) sx_num_is_float "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_float_safe|])dnl
popdef([|CLEANUP|])dnl
