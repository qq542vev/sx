dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_cycle __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_cycle - 文字列を指定された位置だけ循環させる
##
## 使い方:
##   sx_str_cycle 結果変数名 [元文字列 [シフト量]]
##
## 説明:
##   元文字列を指定されたシフト量だけ左方向に循環シフトする。
##   シフト量が負の場合は右方向に循環シフトする。
##   例えば "ABCDE" を 2 シフトすると "CDEAB"、-1 シフトすると "EABCD" となる。
##   シフト量は先行ゼロなしの符号付き10進整数で、算術域を超える値も扱う。
##   シフト量が文字列長を超える場合は、文字列長で割った余りを使用する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_cycle() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_cycle "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_str_cycle "${@}"
}

popdef([|CLEANUP|])dnl
