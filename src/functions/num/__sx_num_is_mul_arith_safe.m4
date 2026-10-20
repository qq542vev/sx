dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_NUM_MAX SX_SYS_NUM_MIN|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_mul_arith_safe - 引数順の乗算で桁溢れしないか確認する（内部用）
##
## 使い方:
##   __sx_num_is_mul_arith_safe [整数1 [整数2 ...]]
##
## 説明:
##   sx_num_is_mul_arith_safe の内部実装。引数チェックは行わない。
##   前提: 設定と派生値が有効で、各入力値が設定幅内の整数であること。
##   符号別に MAX または MIN を乗数で除した境界と比較し、積が安全な場合のみ乗算する。
##   ゼロ乗算は常に安全と判定する。
##
## 終了ステータス:
##    0  設定幅内で安全に乗算できる (SX_EX_OK)
##    1  乗算途中または最終結果が設定幅の範囲外

define([|CLEANUP|], [|Q_acc Q_arg|])dnl

__sx_num_is_mul_arith_safe() {
	Q_acc=1

	for Q_arg in "${@}"; do
		case "$((Q_acc == 0 || Q_arg == 0))" in
			1) Q_acc=0;;
			*)
				case "$((Q_acc > 0))$((Q_arg > 0))" in
					11)
						case "$((Q_acc > SX_SYS_NUM_MAX / Q_arg))" in 1)
							unset CLEANUP
							return 1
						esac
						;;
					10)
						case "$((Q_arg < SX_SYS_NUM_MIN / Q_acc))" in 1)
							unset CLEANUP
							return 1
						esac
						;;
					01)
						case "$((Q_acc < SX_SYS_NUM_MIN / Q_arg))" in 1)
							unset CLEANUP
							return 1
						esac
						;;
					00)
						case "$((Q_acc < SX_SYS_NUM_MAX / Q_arg))" in 1)
							unset CLEANUP
							return 1
						esac
						;;
				esac

				Q_acc=$((Q_acc * Q_arg))
				;;
		esac
	done

	unset CLEANUP
}
|], [|num_is_mul_arith_safe|])dnl
popdef([|CLEANUP|])dnl
