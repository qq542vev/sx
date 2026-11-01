M_REQUIRE([|SX_CFG_ARR_HOLE __sx_num_sub1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_rquote - 配列要素を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_rquote バインド形式 配列名1 [配列名2 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   未設定要素は SX_CFG_ARR_HOLE で表し、設定済みの空文字列はそのまま保持する。
##
## 終了ステータス:
##    0  成功（バインド枯渇による早期終了を含む）

define([|CLEANUP|], [|Q_bind Q_argi Q_arr Q_arri|])dnl

__sx_arr_rquote() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_argi="${#}"

	while M_STR_NE([|"${Q_argi}"|], [|1|]); do
		eval "Q_arr=\"\${${Q_argi}}\""
		eval "Q_arri=\"\${${Q_arr}_len}\""

		while M_STR_NE([|"${Q_arri}"|], [|0|]); do
			M_NUM_DECRM1([|Q_arri|])
			eval __sx_var_bind Q_bind '"${Q_bind}"' "\"\${${Q_arr}_${Q_arri}-\${SX_CFG_ARR_HOLE}}\"" || break 2
		done

		M_NUM_DECRM1([|Q_argi|])
	done

	unset CLEANUP
}
|], [|arr_rquote|])dnl
popdef([|CLEANUP|])dnl
