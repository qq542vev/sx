M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_cmp_fixed sx_num_is_fixed|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_cmp_fixed - 2つの固定小数点数を比較する
##
## 使い方:
##   sx_num_cmp_fixed 左辺 右辺
##
## 説明:
##   指定された2つの固定小数点数を比較する。
##   引数は sx_num_norm 等で正規化された10進固定小数点形式である必要がある。
##
## 終了ステータス:
##    1  左辺 < 右辺
##    2  左辺 = 右辺
##    3  左辺 > 右辺
##   64  引数が正規化済み数値ではない (SX_EX_USAGE)
sx_num_cmp_fixed() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_fixed "${@}" || return; return 0;; esac

	sx_num_is_fixed "${1-}" "${2-}" || return M_EX_USAGE

	__sx_num_cmp_fixed "${1}" "${2}" || return
}

popdef([|CLEANUP|])dnl
