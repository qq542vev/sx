dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_var_copy|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_swap - 変数を連鎖的にローテーションする（内部用）
##
## 使い方:
##   __sx_var_swap [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_swap の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_chain|])dnl

__sx_var_swap() {
	Q_chain=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) M_STR_APPEND([|Q_chain|], [|"${Q_arg##*=}=${Q_arg} "|]);;
			*-*) M_STR_APPEND([|Q_chain|], [|"${Q_arg}-${Q_arg%%-*} "|]);;
		esac
	done

	eval __sx_var_copy "${Q_chain}"

	unset CLEANUP
}
|], [|var_swap|])dnl
popdef([|CLEANUP|])dnl
