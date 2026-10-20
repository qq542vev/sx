dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_ARR_HOLE __sx_num_add1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_quote - 配列要素をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_quote バインド形式 配列名1 [配列名2 ...]
##
## 説明:
##   sx_arr_quote の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_arr Q_len Q_i Q_set Q_val|])dnl

__sx_arr_quote() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	for Q_arr in "${@}"; do
		eval "Q_len=\"\${${Q_arr}_len}\""
		Q_i=0

		while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
			eval "Q_set=\"\${${Q_arr}_${Q_i}+X}\" Q_val=\"\${${Q_arr}_${Q_i}-}\""

			case "${Q_set}" in
				X) __sx_var_bind Q_bind "${Q_bind}" "${Q_val}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${SX_CFG_ARR_HOLE-}";;
			esac || break 2

			M_NUM_INCRM1([|Q_i|])
		done
	done

	unset CLEANUP
}
|], [|arr_quote|])dnl
popdef([|CLEANUP|])dnl
