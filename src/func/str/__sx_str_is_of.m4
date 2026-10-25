M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_is_of - すべての引数が指定された文字集合のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_of 文字集合 [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   第2引数以降のすべての文字列が、第1引数で指定された文字集合の文字のみで
##   構成されているかを確認する。
##   空文字列は条件を満たさないものとして扱われる。
##
## 終了ステータス:
##    0  すべて指定された文字集合のみで構成されている (SX_EX_OK)
##    1  指定された文字集合以外が含まれる、または空文字列が含まれる

define([|CLEANUP|], [|Q_charset Q_arg|])dnl

__sx_str_is_of() {
	Q_charset="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in '' | *[!"${Q_charset}"]*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|str_is_of|])dnl
popdef([|CLEANUP|])dnl
