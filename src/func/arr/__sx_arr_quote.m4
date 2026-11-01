M_REQUIRE([|SX_CFG_ARR_HOLE __sx_num_add1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_quote - 配列要素をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_quote バインド形式 配列名1 [配列名2 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   未設定要素は SX_CFG_ARR_HOLE で表し、設定済みの空文字列はそのまま保持する。
##
## 終了ステータス:
##    0  成功（バインド枯渇による早期終了を含む）

define([|CLEANUP|], [|Q_bind Q_arr Q_len Q_i|])dnl

__sx_arr_quote() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	for Q_arr in ${Q_bind:+"${@}"}; do
		eval "Q_len=\"\${${Q_arr}_len}\""
		Q_i=0

		while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
			eval __sx_var_bind Q_bind '"${Q_bind}"' "\"\${${Q_arr}_${Q_i}-\${SX_CFG_ARR_HOLE}}\"" || break 2

			M_NUM_INCRM1([|Q_i|])
		done
	done

	unset CLEANUP
}
|], [|arr_quote|])dnl
popdef([|CLEANUP|])dnl
