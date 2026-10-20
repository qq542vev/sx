dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_LOWER SX_STR_SPACE SX_STR_SUB_CB SX_STR_SUB_GLOB SX_STR_UPPER __sx_glob_bracket __sx_str_sub __sx_str_title_cb __sx_str_tr|])dnl
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
##   両処理とも固定の回数上限を設けず、委譲先の多倍長対応を利用する。

define([|CLEANUP|], [|Q_tmp Q_gs|])dnl

__sx_str_title() {
	set -- "${1}" "${2-}" "${3:-${SX_STR_SPACE}}"

	__sx_glob_bracket Q_gs "${3}"
	__sx_str_tr Q_tmp: "${2-}" "${SX_STR_UPPER}" "${SX_STR_LOWER}"
	__sx_str_sub Q_tmp: "${3%"${3#?}"}${Q_tmp}" "${Q_gs}[${SX_STR_LOWER}]" __sx_str_title_cb '' "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"

	M_VAR_SET([|${1}|], [|${Q_tmp#?}|])
	unset CLEANUP
}
|], [|str_title|])dnl
popdef([|CLEANUP|])dnl
