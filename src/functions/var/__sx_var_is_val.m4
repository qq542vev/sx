dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_val - 変数が値を持ち、かつ空でないか確認する（内部用）
##
## 使い方:
##   __sx_var_is_val 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が値を持ち、空でないか確認する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_e|])dnl

__sx_var_is_val() {
	for Q_arg in "${@}"; do
		eval "Q_e=\"\${${Q_arg}:+X}\""

		case "${Q_e}" in '')
			unset CLEANUP
			return 1
		esac

		unset CLEANUP
	done
}
|], [|var_is_val|])dnl
popdef([|CLEANUP|])dnl
