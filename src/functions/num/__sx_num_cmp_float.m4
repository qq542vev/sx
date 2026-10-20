dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_cmp_fixed __sx_num_norm|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_cmp_float - 2つの数値を比較する（検証なし）
##
## 使い方:
##   __sx_num_cmp_float 左辺 右辺
##
## 説明:
##   指定された2つの数値を比較する。
##   引数が数値であることの検証は行わない。
##
## 終了ステータス:
##    1  左辺 < 右辺
##    2  左辺 = 右辺
##    3  左辺 > 右辺

define([|CLEANUP|], [|Q_a Q_b|])dnl

__sx_num_cmp_float() {
	__sx_num_norm Q_a:Q_b "${1}" "${2}"
	set -- "${Q_a}" "${Q_b}"
	unset CLEANUP

	__sx_num_cmp_fixed "${@}" || return
}
|], [|num_cmp_float|])dnl
popdef([|CLEANUP|])dnl
