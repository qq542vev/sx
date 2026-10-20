dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SPACE __sx_str_etrim __sx_str_strim|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_trim - 文字列の前後から指定された文字セットを削除する（内部用）
##
## 使い方:
##   __sx_str_trim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   sx_str_trim の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_trim() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}"

	__sx_str_strim Q_tmp "${2}" "${3}"
	__sx_str_etrim "${1}" "${Q_tmp}" "${3}"

	unset CLEANUP
}
|], [|str_trim|])dnl
popdef([|CLEANUP|])dnl
