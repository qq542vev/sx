dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_REV __sx_fn_set __sx_num_add1_nat0 __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_fn_anon - 匿名関数を実際に生成・定義する（内部用）
##
## 使い方:
##   __sx_fn_anon 結果変数名（またはバインド形式） 本体 [本体 ...]
##
##   一意な関数名 (sx_fn_anon_${SX_SYS_REV}) を生成して定義し、
##   結果変数に格納する。

define([|CLEANUP|], [|Q_bind Q_arg Q_name|])dnl

__sx_fn_anon() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		Q_name="sx_fn_anon_${SX_SYS_REV}"

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_name}" || break

		__sx_fn_set "${Q_name}=${Q_arg}"

		M_NUM_INCRM1([|SX_SYS_REV|])
	done

	unset CLEANUP
}
|], [|fn_anon|])dnl
popdef([|CLEANUP|])dnl
