dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_cmp_float sx_num_is_float|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_cmp_float - 2つの数値を比較する
##
## 使い方:
##   sx_num_cmp_float 左辺 右辺
##
## 説明:
##   指定された2つの数値を比較する。
##
## 終了ステータス:
##    1  左辺 < 右辺
##    2  左辺 = 右辺
##    3  左辺 > 右辺
##   64  引数が数値ではない (SX_EX_USAGE)
sx_num_cmp_float() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_float "${@}" || return; return 0;; esac

	sx_num_is_float "${1-}" "${2-}" || return M_EX_USAGE

	__sx_num_cmp_float "${@}"
}

popdef([|CLEANUP|])dnl
