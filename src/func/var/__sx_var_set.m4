M_REQUIRE([|__sx_var_unset|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_set - 変数に値を設定、または削除する（内部用）
##
## 使い方:
##   __sx_var_set [名前=値 | 名前 ...]
##
## 説明:
##   sx_var_set の内部実装。
##   引数チェックは行わない。
##
## 注意:
##   内部関数は結果変数への代入にこの関数を使わず、M_VAR_SET マクロ
##   （事前 unset を行わない eval による直接代入）を使用する。
##   そのため、sx 配列が格納された変数を結果変数として使う場合は、
##   事前に sx_var_unset を明示的に呼び出すこと。

define([|CLEANUP|], [|Q_arg Q_vn|])dnl

__sx_var_set() {
	for Q_arg in "${@}"; do
		Q_vn="${Q_arg%%=*}"
		__sx_var_unset "${Q_vn%%=*}"

		case "${Q_arg}" in *=*)
			eval "${Q_vn}="'"${Q_arg#*=}"'
		esac
	done

	unset CLEANUP
}
|], [|var_set|])dnl
popdef([|CLEANUP|])dnl
