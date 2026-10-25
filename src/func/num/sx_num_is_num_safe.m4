M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_num_safe|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_num_safe - すべての引数が有効な数値（整数または実数）であるか確認する
##
## 使い方:
##   sx_num_is_num_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   引数が 16進数または 8進数の形式（0x または 0[0-9] で始まる）である場合は
##   sx_num_is_int_safe で、それ以外の場合は sx_num_is_float_safe で検証を行う。
##
## 終了ステータス:
##    0  すべて有効な数値である (SX_EX_OK)
##    1  有効な数値ではない値が含まれる
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_num_is_num_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_num_safe "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_is_num_safe|])

	__sx_num_is_num_safe "${@}" || return
}

popdef([|CLEANUP|])dnl
