M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arg_between __sx_num_is_nat0_base|])dnl
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
##   最小個数と最大個数の2つを指定する。境界引数が不足する場合は引数不正となる。
##   両方に空文字を指定した場合は成功する。
##   最小個数が最大個数を超える場合も、空の範囲として1を返す。
##   SX_CFG_NUM_RANGE は参照しない。
##
## 終了ステータス:
##    0  最小個数 <= 引数の個数 <= 最大個数 (SX_EX_OK)
##    1  範囲外
##   64  引数不正 (SX_EX_USAGE)
sx_arg_between() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_between "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arg_between|])

	case "${#}" in [01])
		return M_EX_USAGE
	esac

	__sx_num_is_nat0_base 10 ${1:+"${1}"} ${2:+"${2}"} || return M_EX_USAGE

	__sx_arg_between "${@}"
}
popdef([|CLEANUP|])dnl
