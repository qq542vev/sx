M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_is_containing - すべての文字列が指定された部分文字列を含んでいるか確認する（内部用）
##
## 使い方:
##   __sx_str_is_containing 部分文字列 [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   第2引数以降のすべての文字列が、第1引数で指定された部分文字列を
##   含んでいるかを確認する。
##   部分文字列が空の場合、または文字列が 0 個の場合は成功する。
##
## 終了ステータス:
##    0  すべて部分文字列を含んでいる、または文字列が 0 個 (SX_EX_OK)
##    1  いずれかが部分文字列を含んでいない

define([|CLEANUP|], [|Q_base Q_arg|])dnl

__sx_str_is_containing() {
	Q_base="${1-}"
	${1+'shift'}

	for Q_arg in ${Q_base:+"${@}"}; do
		case "${Q_arg}" in *"${Q_base}"*) ;; *)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|str_is_containing|])dnl
popdef([|CLEANUP|])dnl
