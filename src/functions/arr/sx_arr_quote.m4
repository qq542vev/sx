dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arr_quote __sx_var_is_arr __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_quote - 配列要素をシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arr_quote bind 配列名1 [配列名2 ...]
##
## 説明:
##   指定されたすべての配列の要素をそれぞれシングルクォートで囲み（内部のシングルクォートはエスケープ）、
##   スペース区切りで順方向に結合した文字列を作成して結果変数に格納する。
##   作成された文字列は eval 等で安全に位置パラメータに戻すことができる。
##   未設定の要素（疎配列の穴）は SX_CFG_ARR_HOLE の値で表す。
##   結果はバインド形式（sx_var_is_bind 参照）で指定できる。
##   単一の変数名なら全要素をクォートして結合した文字列になる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_arr_quote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_quote "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1-}"
	shift

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_var_is_arr "${@}" || {
		unset CLEANUP
		return M_EX_DATAERR
	}

	__sx_arr_quote "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|arr_quote|])dnl
popdef([|CLEANUP|])dnl
