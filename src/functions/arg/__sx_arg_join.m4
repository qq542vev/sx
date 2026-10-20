M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_join - 引数を指定された区切り文字で結合する（内部用）
##
## 使い方:
##   __sx_arg_join 結果変数名 区切り文字 [値 ...]
##
## 説明:
##   引数チェックを行わずに結合処理を行う。

define([|CLEANUP|], [|Q_res Q_sep Q_out Q_arg|])dnl

__sx_arg_join() {
	Q_res="${1}"
	Q_sep="${2-}"
	Q_out=
	shift ${2+'2'}

	for Q_arg in "${@}"; do
		M_STR_APPEND([|Q_out|], [|"${Q_sep}${Q_arg}"|])
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out#"${Q_sep}"}|])

	unset CLEANUP
}
|], [|arg_join|])dnl
popdef([|CLEANUP|])dnl
