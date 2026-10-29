M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_is_nonascii - すべての引数が非ASCII文字のみで構成されているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_nonascii [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   ASCII文字の混入を調べ、空文字列も不一致として扱う。
##   引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて非ASCII文字のみで構成されている、または引数がない (SX_EX_OK)
##    1  ASCII文字が含まれる、または空文字列が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_str_is_nonascii() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in '' | *[M_SH_QUOTE(M_STR_ASCII)]*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|str_is_nonascii|])dnl
popdef([|CLEANUP|])dnl
