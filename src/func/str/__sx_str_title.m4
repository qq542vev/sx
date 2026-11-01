M_REQUIRE([|__sx_glob_bracket __sx_str_sub __sx_str_title_cb __sx_str_tr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_title - 各単語の先頭を大文字、残りを小文字に変換する（内部用）
##
## 使い方:
##   __sx_str_title 結果変数名 [元文字列 [単語区切り文字セット]]
##
## 説明:
##   sx_str_title の内部実装。引数チェックは行わない。
##   sx_str_tr で一括小文字化した後、セパレータ+小文字のペアを
##   sx_str_sub のコールバックモードで検出して大文字化する。
##   区切り集合が英字を含む場合は、元文字列の各文字と直前の文字から変換を決める。
##   これにより小文字化による境界の消失と、隣接する境界の取りこぼしを避ける。
##   両処理とも固定の回数上限を設けず、委譲先の多倍長対応を利用する。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_tmp Q_gs Q_cb_sep|])dnl

__sx_str_title() {
	set -- "${1}" "${2-}" "${3:-M_STR_SPACE()}"

	case "${3}" in *["M_STR_ALPHA()"]*)
		Q_cb_sep="${3}" __sx_str_sub "${1}:" "${2}" '?' __sx_str_title_cb '' "$((M_STR_SUB_GLOB | M_STR_SUB_CB))"
		unset CLEANUP
		return
	esac

	__sx_glob_bracket Q_gs "${3}"
	__sx_str_tr Q_tmp: "${2-}" "M_STR_UPPER()" "M_STR_LOWER()"
	__sx_str_sub Q_tmp: "${3%"${3#?}"}${Q_tmp}" "${Q_gs}[M_STR_LOWER()]" __sx_str_title_cb '' "$((M_STR_SUB_GLOB | M_STR_SUB_CB))"

	M_VAR_SET([|${1}|], [|${Q_tmp#?}|])
	unset CLEANUP
}
|], [|str_title|])dnl
popdef([|CLEANUP|])dnl
