dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_NUM_MAX SX_SYS_NUM_MIN|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_add_arith_safe - 引数順の加算で桁溢れしないか確認する（内部用）
##
## 使い方:
##   __sx_num_is_add_arith_safe [整数1 [整数2 ...]]
##
## 説明:
##   sx_num_is_add_arith_safe の内部実装。引数チェックは行わない。
##   前提: 設定および派生値が有効で、各入力値が設定幅内の整数であること。
##   累積値を0から開始し、正の入力では MAX - 入力値、負の入力では
##   MIN - 入力値との比較で桁溢れを判定する。安全な場合のみ加算する。
##   判定用の減算は設定幅内に収まり、最小値の符号反転も行わない。
##
## 終了ステータス:
##    0  設定幅内で安全に加算できる (SX_EX_OK)
##    1  加算途中または最終結果が設定幅の範囲外

define([|CLEANUP|], [|Q_acc Q_arg|])dnl

__sx_num_is_add_arith_safe() {
	Q_acc=0

	for Q_arg in "${@}"; do
		case "$((Q_arg > 0 ? Q_acc > SX_SYS_NUM_MAX - Q_arg :
			Q_arg < 0 ? Q_acc < SX_SYS_NUM_MIN - Q_arg : 0))" in 1)
			unset CLEANUP
			return 1
		esac

		Q_acc=$((Q_acc + Q_arg))
	done

	unset CLEANUP
}
|], [|num_is_add_arith_safe|])dnl
popdef([|CLEANUP|])dnl
