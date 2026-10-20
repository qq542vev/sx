dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_nat0_safe __sx_str_capital __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_capital - 文頭または最初のアルファベットを大文字化し、他を小文字化する
##
## 使い方:
##   sx_str_capital 結果変数名 [元文字列 [フラグ]]
##
## 説明:
##   指定された文字列のアルファベットを大文字化・小文字化する。
##   デフォルトでは、文字列の先頭（インデックス0）がアルファベットの場合のみ
##   それを大文字にし、以降のアルファベットをすべて小文字にする。
##   元文字列の長さに SX_CFG_NUM_RANGE による上限は設けない。
##
## フラグ:
##   1 (SX_STR_CAPITAL_KEEP):
##     大文字化（または維持）のみを行い、他の文字のケースを維持する。
##   2 (SX_STR_CAPITAL_SENT):
##     文字列の先頭に限らず、最初に出現したアルファベットを大文字化の対象とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_capital() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_capital "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${3:+"${3}"} || return M_EX_USAGE

	__sx_str_capital "${@}"
}

popdef([|CLEANUP|])dnl
