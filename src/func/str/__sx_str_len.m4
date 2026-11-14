M_REQUIRE([|__sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_len - 各文字列の長さをバインド形式に従って順に代入する（内部用）
##
## 使い方:
##   __sx_str_len バインド形式 文字列 ...
##
## 説明:
##   sx_str_len の内部実装。引数チェックは行わない。
##   バインド先が枯渇しても __sx_var_ubind の戻り値 1 を握りつぶし、
##   超過する文字列は無視する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_arg|])dnl

__sx_str_len() {
	__sx_var_bind_init "${1}"

	Q_bind="${1}"
	shift 1

	for Q_arg in ${Q_bind:+"${@}"}; do
	__sx_var_ubind Q_bind "${Q_bind}" "${#Q_arg}" || break
	done

	unset CLEANUP
}
|], [|str_len|])dnl
popdef([|CLEANUP|])dnl
