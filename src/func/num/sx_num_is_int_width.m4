M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_int_width|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_int_width - すべての引数が指定されたビット幅の符号付き整数の範囲内か確認する
##
## 使い方:
##   sx_num_is_int_width ビット幅 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定されたビット幅 (8, 16, 32, 64, 128) において、
##   後続のすべての引数が、その範囲内の符号付き整数であるか確認する。
##   8進数 (0...)、16進数 (0x...) 形式もサポートする。
##
## 終了ステータス:
##    0  すべて範囲内である (SX_EX_OK)
##    1  範囲外、または整数ではない値が含まれる
##   64  ビット幅指定が不正 (SX_EX_USAGE)
sx_num_is_int_width() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_width "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_is_int_width|])

	case "${1-}" in
		8 | 16 | 32 | 64 | 128) ;;
		*) return M_EX_USAGE;;
	esac

	__sx_num_is_int_width "${@}" || return
}

popdef([|CLEANUP|])dnl
