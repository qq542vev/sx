dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_LF __sx_str_quote __sx_var_list_dep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_dump - 変数や配列の状態を文字列として取得する（内部用）
##
## 使い方:
##   __sx_var_dump 結果変数名 [名前1 ...]
##
## 説明:
##   sx_var_dump の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_out Q_dep Q_vn Q_set Q_val|])dnl

__sx_var_dump() {
	Q_res="${1}"
	Q_out=
	shift

	__sx_var_list_dep Q_dep "${@}"
	eval set -- "${Q_dep}"

	for Q_vn in "${@}"; do
		eval "Q_set=\"\${${Q_vn}+X}\" Q_val=\"\${${Q_vn}-}\""

		case "${Q_set}" in
			X)
			__sx_str_quote Q_val "${Q_val}"

				M_STR_APPEND([|Q_out|], [|"${Q_vn}=${Q_val}${SX_STR_LF}"|])
				;;
			*) M_STR_APPEND([|Q_out|], [|"unset -v ${Q_vn}${SX_STR_LF}"|]);;
		esac
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out}|])

	unset CLEANUP
}
|], [|var_dump|])dnl
popdef([|CLEANUP|])dnl
