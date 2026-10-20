dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_NUM_QM __sx_num_sub_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_sub1_nat0 - 正の整数から1を減算する（内部用）
##
## 使い方:
##   __sx_num_sub1_nat0 結果変数名 数値
##
## 説明:
##   sx_num_sub1_nat0 の内部実装。引数の検証を行わない。
##   SX_SYS_NUM_QM に応じて、ネイティブ算術または __sx_num_sub_nat0 に委譲する。

__sx_num_sub1_nat0() {
	case "${2}" in
		${SX_SYS_NUM_QM}*) __sx_num_sub_nat0 "${1}" "${2}" 1;;
		*) : "$((${1} = ${2} - 1))";;
	esac
}
|], [|num_sub1_nat0|])dnl
popdef([|CLEANUP|])dnl
