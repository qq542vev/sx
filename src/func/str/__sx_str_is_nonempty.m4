M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_is_nonempty - すべての引数が空文字列でないか確認する（内部用）
##
## 使い方:
##   __sx_str_is_nonempty [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   空白や改行だけの文字列も空でないものとして扱う。
##   引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて空でない、または引数がない (SX_EX_OK)
##    1  空文字列が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_str_is_nonempty() {
	for Q_arg in "${@}"; do
		case "${Q_arg:+X}" in '')
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|str_is_nonempty|])dnl
popdef([|CLEANUP|])dnl
