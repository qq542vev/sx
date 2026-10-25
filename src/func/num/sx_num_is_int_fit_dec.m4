M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_int_fit_dec - すべての引数が指定されたビット幅の符号付き10進整数の範囲内か確認する
##
## 使い方:
##   sx_num_is_int_fit_dec ビット幅 [整数1 [整数2 ...]]
##
## 説明:
##   第1引数で指定されたビット幅の符号付き整数として、
##   後続のすべての引数が、その範囲内の10進整数であるか確認する。
##   8進数 (0...) や 16進数 (0x...) 形式はサポートしない。
##
## 終了ステータス:
##    0  すべて範囲内である (SX_EX_OK)
##    1  範囲内に収まらない値が含まれる（ビット幅は正しい）
##   64  ビット幅指定が不正、または整数として不正な値が含まれる (SX_EX_USAGE)
sx_num_is_int_fit_dec() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_fit_dec "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_is_int_fit_dec|])

	case "${1-}" in
		8 | 16 | 32 | 64 | 128) ;;
		*) return M_EX_USAGE;;
	esac

	__sx_num_is_int_base 10 "${@}" || return M_EX_USAGE

	__sx_num_is_int_fit_dec "${@}" || return
}

popdef([|CLEANUP|])dnl
