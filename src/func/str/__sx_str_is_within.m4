M_REQUIRE([|__sx_num_cmp_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_is_within - すべての引数が指定された文字数の範囲内か確認する（内部用）
##
## 使い方:
##   __sx_str_is_within 最小文字数 最大文字数 [文字列1 [文字列2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   最小文字数または最大文字数に空文字が渡された場合は、その境界の判定を省略する。
##   最小文字数が 0 の場合も下限の判定を省略する。
##   最小文字数が最大文字数を超える場合は、空の範囲として1を返す。
##   文字列が1つも指定されない場合は成功する。
##
## 終了ステータス:
##    0  すべて範囲内 (SX_EX_OK)
##    1  範囲外の文字列がある、または最小文字数が最大文字数を超える

define([|CLEANUP|], [|Q_min Q_max Q_len Q_arg|])dnl

__sx_str_is_within() {
	Q_min="${1-}"
	Q_max="${2-}"
	shift 2

	case "${Q_min}" in '' | 0)
		Q_min=
	esac

	# 下限も上限もない場合は、すべての文字列が条件を満たす。
	case "${Q_min:+${Q_max:+X}}" in '')
		unset CLEANUP
		return
	esac

	# 最小文字数が最大文字数を超える場合は空の範囲。
	case "${Q_min:+X}${Q_max:+Y}" in XY)
		__sx_num_cmp_nat0 "${Q_min}" "${Q_max}" || case "${?}" in 3)
			unset CLEANUP
			return 1
		esac
	esac

	for Q_arg in "${@}"; do
		Q_len="${#Q_arg}"

		case "${Q_min:+X}" in X)
			__sx_num_cmp_nat0 "${Q_len}" "${Q_min}" || case "${?}" in 1)
				unset CLEANUP
				return 1
			esac
		esac

		case "${Q_max:+X}" in X)
			__sx_num_cmp_nat0 "${Q_len}" "${Q_max}" || case "${?}" in 3)
				unset CLEANUP
				return 1
			esac
		esac
	done

	unset CLEANUP
}
|], [|str_is_within|])dnl
popdef([|CLEANUP|])dnl
