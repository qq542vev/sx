dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_NUM_ZR_1 SX_NUM_ZR_10 SX_NUM_ZR_11 SX_NUM_ZR_12 SX_NUM_ZR_13 SX_NUM_ZR_14 SX_NUM_ZR_15 SX_NUM_ZR_16 SX_NUM_ZR_17 SX_NUM_ZR_18 SX_NUM_ZR_19 SX_NUM_ZR_2 SX_NUM_ZR_20 SX_NUM_ZR_21 SX_NUM_ZR_22 SX_NUM_ZR_23 SX_NUM_ZR_24 SX_NUM_ZR_25 SX_NUM_ZR_26 SX_NUM_ZR_27 SX_NUM_ZR_28 SX_NUM_ZR_29 SX_NUM_ZR_3 SX_NUM_ZR_30 SX_NUM_ZR_31 SX_NUM_ZR_32 SX_NUM_ZR_33 SX_NUM_ZR_34 SX_NUM_ZR_35 SX_NUM_ZR_36 SX_NUM_ZR_37 SX_NUM_ZR_4 SX_NUM_ZR_5 SX_NUM_ZR_6 SX_NUM_ZR_7 SX_NUM_ZR_8 SX_NUM_ZR_9 __sx_str_rep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_zr - "0"×n を高速生成する（内部用）
##
## 使い方:
##   __sx_str_zr 結果変数名 [繰り返し回数]
##
## 説明:
##   "0" を指定された回数だけ繰り返して、結果変数に格納する。
##   SX_NUM_ZR 定数（1〜37 桁）から case で直接参照し、37 桁を超える場合のみ
##   __sx_str_rep で生成する。引数チェックは行わない。

define([|CLEANUP|], [|Q_out|])dnl

__sx_str_zr() {
	case "${2:-1}" in
__sx_m4_gen_zr_case(1)
		*)
			__sx_str_rep "${1}" 0 "${2:-1}"
			return
			;;
	esac

	eval "${1}=\"\${Q_out}\""
	unset CLEANUP
}
|], [|str_zr|])dnl
popdef([|CLEANUP|])dnl
