dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_cmp_arith - 整数を算術展開で比較する（内部用）
##
## 使い方:
##   __sx_num_cmp_arith 数値1 数値2
##
## 説明:
##   内部実装。引数チェックは行わない。
##   最小値の絶対値を整数定数として展開しないよう、算術は名前参照で行う。
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
define([|CLEANUP|], [|Q_lhs Q_rhs|])dnl

__sx_num_cmp_arith() {
	Q_lhs="${1}" Q_rhs="${2}"
	set -- "$((Q_lhs == Q_rhs ? 2 : (Q_lhs < Q_rhs ? 1 : 3)))"
	unset CLEANUP
	return "${1}"
}
|], [|num_cmp_arith|])dnl
popdef([|CLEANUP|])dnl
