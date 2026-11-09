M_REQUIRE([|__sx_num_cmp_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_between - 引数の個数が指定範囲内か確認する（内部用）
##
## 使い方:
##   __sx_arg_between 最小個数 最大個数 [引数 ...]
##
## 説明:
##   引数チェックを行わずに個数の範囲判定を行う。
##   最小個数または最大個数に空文字が渡された場合は、その境界の判定を省略する。
##
## 終了ステータス:
##   0  最小個数 <= 個数 <= 最大個数 (SX_EX_OK)
##   1  範囲外

define([|CLEANUP|], [|Q_min Q_max|])dnl

__sx_arg_between() {
	Q_min="${1}"
	Q_max="${2}"
	shift 2

	case "${Q_min}" in ?*)
		if M_NUM_LT([|${#}|], [|${Q_min}|]) 2>&-; then
			unset CLEANUP
			return 1
		fi
		case "${?}" in 0) ;; *)
			__sx_num_cmp_nat0 "${#}" "${Q_min}" || case "${?}" in 1)
				unset CLEANUP
				return 1
			esac
		;; esac
	;; esac

	case "${Q_max}" in ?*)
		if M_NUM_GT([|${#}|], [|${Q_max}|]) 2>&-; then
			unset CLEANUP
			return 1
		fi
		case "${?}" in 0) ;; *)
			__sx_num_cmp_nat0 "${#}" "${Q_max}" || case "${?}" in 3)
				unset CLEANUP
				return 1
			esac
		;; esac
	;; esac

	unset CLEANUP
}
|], [|arg_between|])dnl
popdef([|CLEANUP|])dnl
