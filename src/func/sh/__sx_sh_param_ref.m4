M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_sh_param_ref - シェルパラメータの参照文字列を生成する（内部用）
##
## 使い方:
##   __sx_sh_param_ref 結果変数名 区切り文字 [パラメータ1 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   各パラメータを "${parameter}" 形式の参照に変換し、
##   区切り文字で結合した文字列を結果変数に格納する。
##   区切り文字のパターン文字は、先頭の除去時にリテラルとして扱う。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_res Q_sep Q_out Q_arg|])dnl

__sx_sh_param_ref() {
	Q_res="${1}"
	Q_sep="${2-}"
	Q_out=
	shift ${2+'2'}

	for Q_arg in "${@}"; do
		M_STR_APPEND([|Q_out|], [|"${Q_sep}\"\${${Q_arg}}\""|])
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out#"${Q_sep}"}|])

	unset CLEANUP
}
|], [|sh_param_ref|])dnl
popdef([|CLEANUP|])dnl
