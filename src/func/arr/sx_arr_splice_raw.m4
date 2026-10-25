M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_splice_raw __sx_num_is_int_base __sx_var_is_arr __sx_var_is_name __sx_var_is_rw_deep|])dnl
### sx_arr_splice_raw - リビジョンを更新せず配列の一部を削除し、同位置に値を挿入する
##
## 使い方:
##   sx_arr_splice_raw 配列名 n del [値 ...]
##
## 説明:
##   sx_arr_splice と同じ引数検証を行い、n（0 起点）から del 個を削除して
##   同位置に値を挿入する。del=0 は純挿入、値なしは純削除になる。
##   n が負の場合は len+n、del が負の場合は残り長との和に換算し、下限は 0。
##   n と del は配列範囲に丸める。-0 は 0 とみなし、先頭の + は除去する。
##   削除された要素は破棄し、上書き箇所と余剰尾部は入れ子配列も含めて掃除する。
##   ARR_UPDATE の設定にかかわらず、対象配列のリビジョンは更新しない。
##   参照・穴の解釈は sx_arr_splice と同じである。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arr_splice_raw() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_splice_raw "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arr_splice_raw|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_arr "${1}" || return M_EX_DATAERR
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM
	__sx_num_is_int_base 10 ${2:+"${2}"} ${3:+"${3}"} || return M_EX_USAGE

	__sx_arr_splice_raw "${@}"
}
