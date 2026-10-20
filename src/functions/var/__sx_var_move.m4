dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_var_copy_script __sx_var_unset|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_move - 変数を連鎖移動する（内部用）
##
## 使い方:
##   __sx_var_move [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_move の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_script|])dnl

__sx_var_move() {
	__sx_var_copy_script Q_script "${@}"

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) __sx_var_unset "${Q_arg##*=}";;
			*-*) __sx_var_unset "${Q_arg%%-*}";;
			*) __sx_var_unset "${Q_arg}";;
		esac
	done

	eval "${Q_script}"

	unset CLEANUP
}
|], [|var_move|])dnl
popdef([|CLEANUP|])dnl
