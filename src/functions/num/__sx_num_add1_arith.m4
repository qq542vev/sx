M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_add1_arith - 符号付き整数に算術展開で1を加算する（内部用）
##
## 使い方:
##   __sx_num_add1_arith 結果変数名 数値
##
## 説明:
##   内部実装。引数チェックは行わない。
##   入力値と加算結果が実行シェルの算術範囲内に収まることを前提とする。
##   最小値の絶対値を整数定数として展開しないよう、算術は名前参照で行う。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_num|])dnl

__sx_num_add1_arith() {
	Q_num="${2}"
	: "$((${1} = Q_num + 1))"
	unset CLEANUP
}
|], [|num_add1_arith|])dnl
popdef([|CLEANUP|])dnl
