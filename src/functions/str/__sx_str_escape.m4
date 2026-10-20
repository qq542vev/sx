dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SUB_CB SX_STR_SUB_GLOB __sx_glob_bracket __sx_str_escape_cb __sx_str_sub|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_escape - 文字列内の指定された文字をエスケープする（内部用）
##
## 使い方:
##   __sx_str_escape 結果変数名 [元文字列 [エスケープ対象文字集合 [開始エスケープ文字列 [終了エスケープ文字列]]]]
##
## 説明:
##   sx_str_escape の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_gs Q_cb_se Q_cb_ee|])dnl

__sx_str_escape() {
	set -- "${1}" "${2-}" "${3-}" "${4:-\\}" "${5:-}"

	case "${2:+${3:+X}}" in '')
		M_VAR_SET([|${1}|], [|${2}|])
		return
	esac

	__sx_glob_bracket Q_gs "${3}"

	Q_cb_se="${4}" Q_cb_ee="${5}" __sx_str_sub "${1}:" "${2}" "${Q_gs}" __sx_str_escape_cb '' "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"

	unset CLEANUP
}

|], [|str_escape|])dnl
popdef([|CLEANUP|])dnl
