M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_int_safe __sx_num_is_sub_arith_safe __sx_num_sub_arith __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_sub_arith - 複数の符号付き整数を算術展開で減算する
##
## 使い方:
##   sx_num_sub_arith 結果変数名 [整数1 [整数2 ...]]
##
## 説明:
##   SX_CFG_NUM_RANGE の符号付き整数範囲に収まる8・10・16進整数を受け付ける。
##   基数の判定、入力検証、桁溢れの扱いは sx_num_add_arith と同じ。
##   先頭の数値から後続の数値を引数順に減算し、結果を10進表記で格納する。
##   数値省略時は0、数値が1個の場合はその値を返す。
##   減算前に全中間結果および最終結果が設定幅内に収まることを検証する。
##   検証に失敗した場合、結果変数は変更しない。SX_CFG_SKIP_CHK=1 では
##   すべての引数検証を省略し、範囲内に収める責任は呼び出し側にある。
##   SX_CFG_NUM_RANGE は実行シェルの算術域以下であることを前提とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正、整数の形式不正、入力値または差が設定幅の範囲外 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_sub_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_sub_arith "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_sub_arith|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	Q_res="${1}"
	shift

	__sx_num_is_int_safe "${@}" && __sx_num_is_sub_arith_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_sub_arith "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_sub_arith|])dnl
popdef([|CLEANUP|])dnl
