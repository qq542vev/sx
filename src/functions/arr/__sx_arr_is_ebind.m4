dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_var_is_ebind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_is_ebind - 文字列が配列分配用拡張バインド形式として有効か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_ebind [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_arr_is_ebind の内部実装。引数チェックは行わない。
##   sx_var_is_ebind の検査に加え、`@` を含む形式を拒否する。
##
## 終了ステータス:
##    0  すべて有効な形式である
##    1  無効な形式が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_arr_is_ebind() {
	__sx_var_is_ebind "${@}" || return 1

	for Q_arg in "${@}"; do
		case "${Q_arg}" in *@*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|arr_is_ebind|])dnl
popdef([|CLEANUP|])dnl
