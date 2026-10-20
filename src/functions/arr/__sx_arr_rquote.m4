M_REQUIRE([|SX_CFG_ARR_HOLE __sx_num_sub1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_rquote - 配列要素を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_rquote バインド形式 配列名1 [配列名2 ...]
##
## 説明:
##   sx_arr_rquote の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_argi Q_arr Q_arri Q_set Q_val|])dnl

__sx_arr_rquote() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift
	Q_argi="${#}"

	while M_STR_NE([|"${Q_argi}"|], [|0|]); do
		eval "Q_arr=\"\${${Q_argi}}\""
		eval "Q_arri=\"\${${Q_arr}_len}\""

		while M_STR_NE([|"${Q_arri}"|], [|0|]); do
			M_NUM_DECRM1([|Q_arri|])
			eval "Q_set=\"\${${Q_arr}_${Q_arri}+X}\" Q_val=\"\${${Q_arr}_${Q_arri}-}\""

			case "${Q_set}" in
				X) __sx_var_bind Q_bind "${Q_bind}" "${Q_val}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${SX_CFG_ARR_HOLE-}";;
			esac || break 2
		done

		M_NUM_DECRM1([|Q_argi|])
	done

	unset CLEANUP
}
|], [|arr_rquote|])dnl
popdef([|CLEANUP|])dnl
