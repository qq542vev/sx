M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_sub1_arith - 符号付き整数から算術展開で1を減算する（内部用）
##
## 使い方:
##   __sx_num_sub1_arith 結果変数名 数値
##
## 説明:
##   内部実装。引数チェックは行わない。
##   入力値と減算結果が実行シェルの算術範囲内に収まることを前提とする。
##   最小値からの減算は呼び出し側で除外する。
##   入力値の絶対値も算術範囲内に収まるため、入力値を算術式へ直接展開する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

__sx_num_sub1_arith() {
	: "$((${1} = ${2} - 1))"
}
|], [|num_sub1_arith|])dnl
popdef([|CLEANUP|])dnl
