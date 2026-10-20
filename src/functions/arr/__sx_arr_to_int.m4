dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_sub_int|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_to_int - 符号付き整数を配列長基準で正確値に換算する（内部用）
##
## 使い方:
##   __sx_arr_to_int 結果変数名 整数文字列 長さ
##
## 説明:
##   sx_arr_get / sx_arr_has の内部実装。
##   引数チェックは行わない。
##   整数文字列は検証済み（符号付き10進、前ゼロなし）を前提とする。
##   -0 は 0 に、+m/m は m に、-m は len-m に換算する。
##   丸めは行わず、結果は負値・len 超過値を取り得る。
##   常に成功する。

define([|CLEANUP|], [||])dnl

__sx_arr_to_int() {
	case "${2}" in
		-[1-9]*) __sx_num_sub_int "${1}" "${3}" "${2#-}";;
		*) M_VAR_SET([|${1}|], [|${2#[+-]}|]);;
	esac
}
|], [|arr_to_int|])dnl
popdef([|CLEANUP|])dnl
