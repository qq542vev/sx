M_REQUIRE([|__sx_str_rep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_zr - "0"×n を高速生成する（内部用）
##
## 使い方:
##   __sx_str_zr 結果変数名 [繰り返し回数]
##
## 説明:
##   "0" を指定された回数だけ繰り返して、結果変数に格納する。
##   case に埋め込んだ定数（1〜37 桁）を使い、37 桁を超える場合のみ
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
