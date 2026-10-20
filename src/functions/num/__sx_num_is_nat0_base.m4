dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_NUM_BASE10_CHARS SX_NUM_BASE10_PREFIX SX_NUM_BASE16_CHARS SX_NUM_BASE16_PREFIX SX_NUM_BASE8_CHARS SX_NUM_BASE8_PREFIX|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_nat0_base - 指定された基数で0以上の自然数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nat0_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat0_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_arg Q_pfix Q_char|])dnl

__sx_num_is_nat0_base() {
	eval "
		Q_pfix=\"\${SX_NUM_BASE${1}_PREFIX}\"
		Q_char=\"\${SX_NUM_BASE${1}_CHARS}\"
	"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			${Q_pfix}*) ! M_STR_MATCH([|"${Q_arg#${Q_pfix}}"|] , [|''|], [|0?*|], [|*[!"${Q_char}"]*|]);;
			*) ! :;;
		esac || {
			unset Q_pfix Q_char Q_arg
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nat0_base|])dnl
popdef([|CLEANUP|])dnl
