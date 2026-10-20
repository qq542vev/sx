dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_NUM_QM_1 SX_NUM_QM_10 SX_NUM_QM_11 SX_NUM_QM_12 SX_NUM_QM_13 SX_NUM_QM_14 SX_NUM_QM_15 SX_NUM_QM_16 SX_NUM_QM_17 SX_NUM_QM_18 SX_NUM_QM_19 SX_NUM_QM_2 SX_NUM_QM_20 SX_NUM_QM_21 SX_NUM_QM_22 SX_NUM_QM_23 SX_NUM_QM_24 SX_NUM_QM_25 SX_NUM_QM_26 SX_NUM_QM_27 SX_NUM_QM_28 SX_NUM_QM_29 SX_NUM_QM_3 SX_NUM_QM_30 SX_NUM_QM_31 SX_NUM_QM_32 SX_NUM_QM_33 SX_NUM_QM_34 SX_NUM_QM_35 SX_NUM_QM_36 SX_NUM_QM_37 SX_NUM_QM_4 SX_NUM_QM_5 SX_NUM_QM_6 SX_NUM_QM_7 SX_NUM_QM_8 SX_NUM_QM_9 __sx_str_rep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_qm - '?'×n を高速生成する（内部用）
##
## 使い方:
##   __sx_str_qm 結果変数名 [繰り返し回数]
##
## 説明:
##   '?' を指定された回数だけ繰り返して、結果変数に格納する。
##   SX_NUM_QM 定数（1〜37 桁）から case で直接参照し、37 桁を超える場合のみ
##   __sx_str_rep で生成する。引数チェックは行わない。

define([|CLEANUP|], [|Q_out|])dnl

__sx_str_qm() {
	case "${2:-1}" in
__sx_m4_gen_qm_case(1)
		*)
			__sx_str_rep "${1}" '?' "${2:-1}"
			return
			;;
	esac

	eval "${1}=\"\${Q_out}\""
	unset CLEANUP
}
|], [|str_qm|])dnl
popdef([|CLEANUP|])dnl
