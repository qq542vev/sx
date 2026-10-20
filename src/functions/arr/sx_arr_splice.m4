dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arr_splice __sx_num_is_int_base __sx_var_is_arr __sx_var_is_rw_deep sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_splice - 配列の一部を削除し、同位置に値を挿入する
##
## 使い方:
##   sx_arr_splice 配列名 n del [値 ...]
##
## 説明:
##   n（0起点）から del 個の要素を削除し、同位置に値を挿入する。
##   n が長さを超える場合は末尾扱い、del が残りを超える場合は残り全部に
##   丸める（clamp）。del=0 で純挿入、値なしで純削除になる。
##   n が負の場合は len+n に換算し、下限を 0 とする。
##   del が負の場合は残り長との和に換算し、下限を 0 とする。
##   -0 は 0 とみなし、先頭の + は除去する。
##   削除された要素は破棄する。中央の上書き前と余剰尾部は深く掃除するため、
##   要素に配列が含まれていても残骸を残さない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [||])dnl

sx_arr_splice() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_splice "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_arr "${1}" || return M_EX_DATAERR
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM
	__sx_num_is_int_base 10 ${2:+"${2}"} ${3:+"${3}"} || return M_EX_USAGE

	__sx_arr_splice "${@}"
}
|], [|arr_splice|])dnl
popdef([|CLEANUP|])dnl
