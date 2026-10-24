M_REQUIRE([|__sx_arg_quote|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_split_ifs - 現在の IFS を使用して文字列を単語分割し、結果を変数に格納する（内部用）
##
## 使い方:
##   __sx_str_split_ifs 結果変数名（またはバインド形式） [文字列 ...]
##
## 説明:
##   sx_str_split_ifs の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_opts|])dnl

__sx_str_split_ifs() {
	Q_bind="${1}"
	Q_opts="${-}"
	shift

	set -f
	set -- ${*}

	case "${Q_opts}" in *f*) ;; *)
		set +f
	esac

	__sx_arg_quote "${Q_bind}" "${@}"

	unset CLEANUP
}
|], [|str_split_ifs|])dnl
popdef([|CLEANUP|])dnl
