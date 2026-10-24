M_REQUIRE([|__sx_num_add1_nat0 __sx_var_bind_init __sx_var_is_arr __sx_var_is_set __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_list_dep - 指定された変数に関連するすべての変数名を取得する（内部用）
##
## 使い方:
##   __sx_var_list_dep 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   位置パラメータをキューとして利用し、非再帰的に関連変数を収集する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_mark Q_len Q_i|])dnl

__sx_var_list_dep() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_mark="${3+ }"
	shift

	while M_STR_NE([|"${#}"|], [|0|]); do
		if M_STR_MATCH([|"${Q_mark}"|], [|?*|]) && __sx_var_is_set "Q_v${1}_"; then
			shift
			continue
		fi

		__sx_var_ubind Q_bind "${Q_bind}" "${1}" || break

		case "${Q_mark:+X}" in X)
			eval "Q_v${1}_="
			M_STR_APPEND([|Q_mark|], [|"Q_v${1}_ "|])
		esac

		if __sx_var_is_arr "${1}"; then
			set -- "${@}" "${1}_len"

			eval "Q_len=\"\${${1}_len}\""
			Q_i=0

			while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
				set -- "${@}" "${1}_${Q_i}"

				M_NUM_INCRM1([|Q_i|])
			done
		fi

		shift
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_list_dep|])dnl
popdef([|CLEANUP|])dnl
