M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_is_suffixed - すべての文字列が指定された接尾辞で終わっているか確認する（内部用）
##
## 使い方:
##   __sx_str_is_suffixed 接尾辞 [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   第2引数以降のすべての文字列が、第1引数で指定された接尾辞で
##   終わっているかを確認する。
##   文字列が 0 個の場合は成功する。
##
## 終了ステータス:
##    0  すべて接尾辞で終わっている、または文字列が 0 個 (SX_EX_OK)
##    1  いずれかが接尾辞で終わっていない

define([|CLEANUP|], [|Q_suffix Q_arg|])dnl

__sx_str_is_suffixed() {
	Q_suffix="${1-}"
	${1+'shift'}

	for Q_arg in ${Q_suffix:+"${@}"}; do
		case "${Q_arg}" in *"${Q_suffix}") ;; *)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|str_is_suffixed|])dnl
popdef([|CLEANUP|])dnl
