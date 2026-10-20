M_REQUIRE([|SX_STR_SPACE __sx_str_squish __sx_str_title __sx_str_words|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_pascal - さまざまな命名規則を PascalCase に変換する（内部用）
##
## 使い方:
##   __sx_str_pascal 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   sx_str_pascal の内部実装。引数チェックは行わない。
##   sx_str_words で単語分割し、sx_str_title でタイトルケース化し、
##   sx_str_squish で空白を除去して結合する。

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_pascal() {
	set -- "${1}" "${2-}" "${3:-"_-/.:${SX_STR_SPACE}"}"

	__sx_str_words Q_tmp "${2}" ' ' "${3}"
	__sx_str_title Q_tmp "${Q_tmp}" ' '
	__sx_str_squish "${1}" "${Q_tmp}" ' ' ''

	unset CLEANUP
}
|], [|str_pascal|])dnl
popdef([|CLEANUP|])dnl
