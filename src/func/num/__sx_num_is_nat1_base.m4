M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nat1_base - 指定された基数で1以上の自然数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nat1_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat1_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_arg Q_pfix Q_char|])dnl

__sx_num_is_nat1_base() {
	case "${1}" in
		8) Q_pfix=M_SH_QUOTE(M_NUM_BASE8_PREFIX) Q_char=M_SH_QUOTE(M_NUM_BASE8_CHARS);;
		10) Q_pfix=M_SH_QUOTE(M_NUM_BASE10_PREFIX) Q_char=M_SH_QUOTE(M_NUM_BASE10_CHARS);;
		16) Q_pfix=M_SH_QUOTE(M_NUM_BASE16_PREFIX) Q_char=M_SH_QUOTE(M_NUM_BASE16_CHARS);;
	esac

	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			${Q_pfix}*) ! M_STR_MATCH([|"${Q_arg#${Q_pfix}}"|], [|''|], [|0*|], [|*[!"${Q_char}"]*|]);;
			*) ! :;;
		esac || {
			unset Q_pfix Q_char Q_arg
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nat1_base|])dnl
popdef([|CLEANUP|])dnl
