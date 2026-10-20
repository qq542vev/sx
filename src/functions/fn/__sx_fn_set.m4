dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_LF|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_fn_set - 関数を実際に定義する（内部用）
##
## 使い方:
##   __sx_fn_set 名前=本体 [名前=本体 ...]

define([|CLEANUP|], [|Q_arg Q_body|])dnl

__sx_fn_set() {
	for Q_arg in "${@}"; do
		Q_body="${Q_arg#*=}"
		eval "${Q_arg%%=*}() { ${Q_body:-:}${SX_STR_LF}}"
	done

	unset CLEANUP
}
|], [|fn_set|])dnl
popdef([|CLEANUP|])dnl
