dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SPACE SX_STR_SUB_CB SX_STR_SUB_GLOB SX_STR_UPPER __sx_str_lower __sx_str_squish __sx_str_sub __sx_str_words_cb|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_words - 命名規則を自動検出して単語に分割する（内部用）
##
## 使い方:
##   __sx_str_words 結果変数名 [文字列 [区切り文字 [区切り文字セット]]]
##
## 説明:
##   sx_str_words の内部実装。引数チェックは行わない。
##   sx_str_sub のコールバックモードで大文字位置を検出し、
##   区切り文字セットの先頭文字を挿入した後、小文字化、
##   区切り文字セット内の文字を区切り文字に置換する。

define([|CLEANUP|], [|Q_tmp Q_cb_c|])dnl

__sx_str_words() {
	set -- "${1}" "${2-}" "${3:- }" "${4:-"_-/.:${SX_STR_SPACE}"}"

	Q_cb_c="${4%"${4#?}"}" __sx_str_sub Q_tmp: "${2}" "[${SX_STR_UPPER}]" __sx_str_words_cb '' "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"
	__sx_str_squish Q_tmp "${Q_tmp}" "${4}" "${3}"
	__sx_str_lower "${1}" "${Q_tmp}"

	unset CLEANUP
}
|], [|str_words|])dnl
popdef([|CLEANUP|])dnl
