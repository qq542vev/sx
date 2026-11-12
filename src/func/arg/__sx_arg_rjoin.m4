M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_rjoin - 引数を指定された区切り文字で右から結合する（内部用）
##
## 使い方:
##   __sx_arg_rjoin 結果変数名 区切り文字 [値 ...]
##
## 説明:
##   sx_arg_rjoin の内部実装。引数チェックは行わない。
##   各要素を区切り文字の前置きとして蓄積し、最後に先頭の
##   区切り文字を除去して結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_res Q_sep Q_out Q_arg|])dnl

__sx_arg_rjoin() {
	Q_res="${1}"
	Q_sep="${2-}"
	Q_out=
	shift ${2+'2'}

	for Q_arg in "${@}"; do
		M_STR_PREPEND([|Q_out|], [|"${Q_sep}${Q_arg}"|])
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out#"${Q_sep}"}|])

	unset CLEANUP
}
|], [|arg_rjoin|])dnl
popdef([|CLEANUP|])dnl
