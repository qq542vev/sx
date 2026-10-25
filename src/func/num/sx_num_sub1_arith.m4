M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_safe __sx_num_is_sub_arith_safe __sx_num_sub1_arith __sx_var_is_name __sx_var_is_rw sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_sub1_arith - 符号付き整数から算術展開で1を減算する
##
## 使い方:
##   sx_num_sub1_arith 結果変数名 数値
##
## 説明:
##   SX_CFG_NUM_RANGE の符号付き整数範囲に収まる8・10・16進整数を受け付ける。
##   任意の + または - の符号を許可し、結果を10進表記で格納する。
##   入力値と減算結果の範囲を検証し、最小値からの減算は拒否する。
##   検証に失敗した場合、結果変数は変更しない。
##   SX_CFG_SKIP_CHK=1 ではすべての引数検証を省略する。
##   この場合、入力値・減算結果を設定幅内に収めることは呼び出し側の責任とする。
##   SX_CFG_NUM_RANGE は実行シェルの算術域以下であることを前提とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正、整数の形式不正、入力値または減算結果が設定幅の範囲外 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_sub1_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_sub1_arith "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_safe "${2-}" && __sx_num_is_sub_arith_safe "${2}" 1 || return M_EX_USAGE

	__sx_num_sub1_arith "${@}" || return
}

popdef([|CLEANUP|])dnl
