dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_ro - 変数が読み取り専用か確認する（内部用）
##
## 使い方:
##   __sx_var_is_ro 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が読み取り専用か確認する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_is_ro() {
	for Q_arg in "${@}"; do
		if __sx_var_is_rw "${Q_arg}"; then
			unset CLEANUP
			return 1
		fi

		unset CLEANUP
	done
}
|], [|var_is_ro|])dnl
popdef([|CLEANUP|])dnl
