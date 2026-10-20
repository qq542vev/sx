M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_mul_arith - 複数の符号付き整数を算術展開で乗算する（内部用）
##
## 使い方:
##   __sx_num_mul_arith 結果変数名 [整数1 [整数2 ...]]
##
## 説明:
##   sx_num_mul_arith の内部実装。引数チェックは行わない。
##   有効な整数を引数順に乗算し、結果を10進表記で格納する。数値省略時は1。
##   計算途中および最終結果の桁溢れは検査しない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_res Q_acc Q_arg|])dnl

__sx_num_mul_arith() {
	Q_res="${1}"
	Q_acc=1
	shift

	for Q_arg in "${@}"; do
		Q_acc=$((Q_acc * Q_arg))
	done

	: "$((${Q_res} = Q_acc))"
	unset CLEANUP
}
|], [|num_mul_arith|])dnl
popdef([|CLEANUP|])dnl
