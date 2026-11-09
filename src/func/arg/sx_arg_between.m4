M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arg_between __sx_num_cmp_nat0 __sx_num_is_nat0_base|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_between - 引数の個数が指定範囲内か確認する
##
## 使い方:
##   sx_arg_between 最小個数 最大個数 [引数 ...]
##
## 説明:
##   指定された引数の個数が、最小個数以上かつ最大個数以下であるか確認する。
##   最小個数または最大個数に空文字を指定した場合は、その境界の判定を省略する
##   （最小個数が空文字なら下限なし、最大個数が空文字なら上限なし）。
##   両方に空文字を指定した場合は常に成功する。
##
## 終了ステータス:
##    0  最小個数 <= 引数の個数 <= 最大個数 (SX_EX_OK)
##    1  範囲外
##   64  引数不正 (SX_EX_USAGE)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arg_between() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_between "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arg_between|])

	case "${#}" in [01]) return M_EX_USAGE;; esac

	case "${1}" in ?*) __sx_num_is_nat0_base 10 "${1}" || return M_EX_USAGE;; esac
	case "${2}" in ?*) __sx_num_is_nat0_base 10 "${2}" || return M_EX_USAGE;; esac

	case "${1:+1}${2:+2}" in 12)
		__sx_num_cmp_nat0 "${1}" "${2}" || case "${?}" in 3) return M_EX_USAGE;; esac
	;; esac

	__sx_arg_between "${@}"
}

popdef([|CLEANUP|])dnl
