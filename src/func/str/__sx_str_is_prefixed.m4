M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_is_prefixed - すべての文字列が指定された接頭辞で始まっているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_prefixed 接頭辞 [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   第2引数以降のすべての文字列が、第1引数で指定された接頭辞で
##   始まっているかを確認する。
##   文字列が 0 個の場合は成功する。
##
## 終了ステータス:
##    0  すべて接頭辞で始まっている、または文字列が 0 個 (SX_EX_OK)
##    1  いずれかが接頭辞で始まっていない

define([|CLEANUP|], [|Q_prefix Q_arg|])dnl

__sx_str_is_prefixed() {
	Q_prefix="${1-}"
	${1+'shift'}

	for Q_arg in ${Q_prefix:+"${@}"}; do
		case "${Q_arg}" in "${Q_prefix}"*) ;; *)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|str_is_prefixed|])dnl
popdef([|CLEANUP|])dnl
