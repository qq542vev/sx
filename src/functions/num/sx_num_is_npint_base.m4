dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_npint_base|])dnl
pushdef([|CLEANUP|])dnl
### sx_num_is_npint_base - 指定された基数で非正整数（0以下）か確認する
##
## 使い方:
##   sx_num_is_npint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 0 以下の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて非正整数である (SX_EX_OK)
##    1  非正整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_npint_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_npint_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_npint_base "${@}"
}

popdef([|CLEANUP|])dnl
