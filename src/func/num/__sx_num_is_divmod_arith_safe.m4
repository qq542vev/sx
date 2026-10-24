M_REQUIRE([|SX_SYS_NUM_MIN|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_divmod_arith_safe - 算術展開で安全に商と余剰を計算できるか確認する（内部用）
##
## 使い方:
##   __sx_num_is_divmod_arith_safe [被除数 [除数]]
##
## 説明:
##   sx_num_is_divmod_arith_safe の内部実装。引数チェックは行わない。
##   前提: 設定と派生値が有効で、各入力値が設定幅内の整数であること。
##   省略・空文字列の被除数は0、除数は1とし、余分な引数は無視する。
##   数値比較のみで除数0と MIN / -1 の組み合わせを検出し、除算・剰余演算は行わない。
##
## 終了ステータス:
##    0  設定幅内で安全に商と余剰を計算できる (SX_EX_OK)
##    1  ゼロ除算、または被除数がMINで除数が-1

define([|CLEANUP|], [|Q_u Q_v|])dnl

__sx_num_is_divmod_arith_safe() {
	Q_u="${1:-0}"
	Q_v="${2:-1}"

	case "$((Q_v == 0 || (Q_u == SX_SYS_NUM_MIN && Q_v == -1)))" in 1)
		unset CLEANUP
		return 1
	esac

	unset CLEANUP
}
|], [|num_is_divmod_arith_safe|])dnl
popdef([|CLEANUP|])dnl
