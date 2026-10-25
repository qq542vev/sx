M_REQUIRE([|SX_STR_WORD|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_name - 変数名として有効か確認する（内部用）
##
## 使い方:
##   __sx_var_is_name [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  すべて有効な変数名 (SX_EX_OK)
##    1  無効な変数名が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_is_name() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in '' | [0-9]* | *[!"${SX_STR_WORD}"]*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|var_is_name|])dnl
popdef([|CLEANUP|])dnl
