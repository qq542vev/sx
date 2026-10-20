dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_add1_nat0 __sx_num_divmod_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_divceil_nat0 - 絶対値の除算で切り上げ商を求める（内部用）
##
## 使い方:
##   __sx_num_divceil_nat0 結果変数名 被除数 [除数]
##
## 説明:
##   sx_num_divceil_nat0 の内部実装。引数チェックは行わない。
##   前提: 結果変数名は有効で書き込み可能、被除数は 0 以上の自然数、
##   除数は 1 以上の自然数であること。被除数・除数は省略時、
##   それぞれ 0、1 として扱われる。

define([|CLEANUP|], [|Q_res Q_q Q_r|])dnl

__sx_num_divceil_nat0() {
	Q_res="${1}"

	__sx_num_divmod_nat0 'Q_q:Q_r:' "${2:-0}" "${3:-1}"

	case "${Q_r}" in [!0]*)
		M_NUM_INCRM1([|Q_q|])
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_q}|])
	unset CLEANUP
}
|], [|num_divceil_nat0|])dnl
popdef([|CLEANUP|])dnl
