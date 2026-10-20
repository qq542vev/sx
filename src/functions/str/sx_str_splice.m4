dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_splice __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_splice - 文字列の一部を削除し、そこに新しい文字列を挿入する
##
## 使い方:
##   sx_str_splice 結果変数名 [文字列 [開始位置 [削除数 [挿入文字列]]]]
##
## 説明:
##   文字列の「開始位置」（0開始）から「削除数」分の文字を取り除き、
##   そこに「挿入文字列」を挿入した結果を結果変数に格納する。
##   削除対象は sx_str_substr 文字列 開始位置 削除数 と同じ範囲とする。
##   負の開始位置は末尾から数え、先頭より前の部分は削除数から差し引く。
##   負の削除数は末尾から除外する文字数とし、省略時または空文字列の場合は末尾まで削除する。
##   挿入位置は文字列の先頭から末尾の範囲に収める。削除対象が空でも挿入する。
##   開始位置は省略時または空文字列の場合に 0、文字列と挿入文字列は省略時に空文字列とする。
##   空文字列以外の数値引数は任意の符号付き10進整数（先行する 0 なし）に限る。
##   文字列長と数値引数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_splice() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_splice "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${3:+"${3}"} ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_splice "${@}"
}

popdef([|CLEANUP|])dnl
