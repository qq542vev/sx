M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_splice_raw __sx_num_is_int_base __sx_var_is_arr __sx_var_is_name __sx_var_is_rw_deep|])dnl
### sx_arr_splice_raw - リビジョンを更新せず配列の一部を削除し、同位置に値を挿入する
##
## 使い方:
##   sx_arr_splice_raw 配列名 [n [del [値 ...]]]
##
## 説明:
##   sx_arr_splice と同じ引数検証を行い、n（0 起点）から del 個を削除して
##   同位置に値を挿入する。del=0 は純挿入、値なしは純削除になる。
##   n が負の場合は元の len+n に換算する。範囲外の開始位置までの距離は穴として保持し、
##   負の添字が残る場合は全体を非負の添字へ平行移動する。
##   削除数には先頭より前の穴も数える。del が負の場合は元の末尾から除外する要素数とする。
##   n の省略・空文字列は 0、del の省略・空文字列は末尾までの削除とする。
##   挿入値がなければ範囲外に穴を作らない。空配列への負位置の挿入でも末尾に穴を作らない。
##   数値引数は任意の符号付き10進整数（先行する 0 なし）。-0 は 0 とみなす。
##   削除された要素は破棄し、上書き箇所と余剰尾部は入れ子配列も含めて掃除する。
##   対象配列のリビジョンは更新しない。
##   穴の解釈は sx_arr_splice と同じである。
##   操作前の長さ以上の添字とその配下に要素変数が存在しないことを前提とする。
##   新しい穴と旧配列範囲が重なる箇所は深く掃除するが、操作前の範囲外変数は掃除しない。
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
