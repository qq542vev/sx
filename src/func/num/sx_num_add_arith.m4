M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_add_arith __sx_num_is_add_arith_safe __sx_num_is_int_safe __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_add_arith - 複数の符号付き整数を算術展開で加算する
##
## 使い方:
##   sx_num_add_arith 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   SX_CFG_NUM_RANGE の符号付き整数範囲に収まる8・10・16進整数を受け付ける。
##   基数は表記で判別する（8進: 0...、10進: プレフィックスなし、
##   16進: 0x... または 0X...）。任意で + または - の符号を指定できる。
##   入力の形式・範囲検証は sx_num_is_int_safe と同じ規則に従う。
##   引数順に算術展開で加算し、結果を10進表記で格納する。数値省略時は0。
##   加算前に全中間結果および最終結果が設定幅内に収まることを検証する。
##   最終結果が範囲内でも、途中で範囲外になる場合は引数不正とする。
##   検証に失敗した場合、結果変数は変更しない。
##   SX_CFG_SKIP_CHK=1 では桁溢れ検査を含むすべての引数検証を省略する。
##   この場合、入力値・全中間結果・最終結果を設定幅内に収めることは
##   呼び出し側の責任とし、範囲外の動作は保証しない。
##   SX_CFG_NUM_RANGE は実行シェルの算術域以下であることを前提とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正、整数の形式不正、入力値または加算結果が設定幅の範囲外 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_add_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_add_arith "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_add_arith|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	Q_res="${1}"
	shift

	__sx_num_is_int_safe "${@}" && __sx_num_is_add_arith_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_add_arith "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_add_arith|])dnl
popdef([|CLEANUP|])dnl
