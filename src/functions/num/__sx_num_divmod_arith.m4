dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_divmod_arith - 算術展開で符号付き整数の商と余剰を求める（内部用）
##
## 使い方:
##   __sx_num_divmod_arith バインド形式 [被除数 [除数]]
##
## 説明:
##   sx_num_divmod_arith の内部実装。引数チェックは行わない。
##   前提: 設定と入力が有効で、除数は非ゼロ、商は設定幅内に収まること。
##   省略・空文字列の被除数は0、除数は1とし、余分な引数は無視する。
##   バインド先の初期化後に、名前参照の / と % で商・余剰を計算する。
##   バインド先が枯渇した場合も成功とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_u Q_v|])dnl

__sx_num_divmod_arith() {
	Q_u="${2:-0}"
	Q_v="${3:-1}"

	__sx_var_bind_init "${1}"
	__sx_var_ubind '' "${1}" "$((Q_u / Q_v))" "$((Q_u % Q_v))" || :

	unset CLEANUP
}
|], [|num_divmod_arith|])dnl
popdef([|CLEANUP|])dnl
