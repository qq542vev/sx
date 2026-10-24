M_REQUIRE([|SX_SYS_NUM_MAX SX_SYS_NUM_MIN|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_sub_arith_safe - 引数順の減算で桁溢れしないか確認する（内部用）
##
## 使い方:
##   __sx_num_is_sub_arith_safe [整数1 [整数2 ...]]
##
## 説明:
##   sx_num_is_sub_arith_safe の内部実装。引数チェックは行わない。
##   前提: 設定と派生値が有効で、各入力値が設定幅内の整数であること。
##   正の値を引く前に MIN + 値、負の値を引く前に MAX + 値と累積値を比較する。
##   符号反転を使わず、範囲内と確認した後に減算する。
##
## 終了ステータス:
##    0  設定幅内で安全に減算できる (SX_EX_OK)
##    1  減算途中または最終結果が設定幅の範囲外

define([|CLEANUP|], [|Q_acc Q_arg|])dnl

__sx_num_is_sub_arith_safe() {
	case "${#}" in 0) return 0;; esac

	Q_arg="${1}"
	shift
	Q_acc=$((Q_arg))

	for Q_arg in "${@}"; do
		case "$((Q_arg > 0 ? Q_acc < SX_SYS_NUM_MIN + Q_arg :
			Q_arg < 0 ? Q_acc > SX_SYS_NUM_MAX + Q_arg : 0))" in 1)
			unset CLEANUP
			return 1
		esac

		Q_acc=$((Q_acc - Q_arg))
	done

	unset CLEANUP
}
|], [|num_is_sub_arith_safe|])dnl
popdef([|CLEANUP|])dnl
