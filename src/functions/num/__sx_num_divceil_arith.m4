dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_divmod_arith|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_divceil_arith - 算術展開で符号付き整数の切り上げ商を求める（内部用）
##
## 使い方:
##   __sx_num_divceil_arith 結果変数名 [被除数 [除数]]
##
## 説明:
##   sx_num_divceil_arith の内部実装。引数チェックは行わない。
##   前提: 結果変数は書き込み可能で、設定・入力が有効かつ除算が安全であること。
##   省略・空文字列の被除数は0、除数は1とし、余分な引数は無視する。
##   __sx_num_divmod_arith の商に、余りが非ゼロで余りと除数が同符号の場合のみ1を加算する。
##   補正時の商は設定幅の端に達しないため、補正による桁溢れは起きない。
##   符号は数値比較で判定し、入力の絶対値・符号反転・積は求めない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_q Q_r Q_v|])dnl

__sx_num_divceil_arith() {
	Q_v="${3:-1}"
	__sx_num_divmod_arith 'Q_q:Q_r:' "${2:-0}" "${Q_v}"

	: "$((${1} = Q_q + (Q_r != 0 && ((Q_r < 0) == (Q_v < 0)))))"
	unset CLEANUP
}
|], [|num_divceil_arith|])dnl
popdef([|CLEANUP|])dnl
