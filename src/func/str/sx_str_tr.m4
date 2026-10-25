M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_tr __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_tr - 文字列内の文字を対応する文字で変換する
##
## 使い方:
##   sx_str_tr 結果変数名 [文字列 [from文字列 [to文字列 [limit]]]]
##
## 説明:
##   文字列中の from に含まれる各文字を、to の対応する位置の文字で置換する。
##   from が空の場合は何もせずそのまま返す。
##   to に含まれない位置の文字（from が to より長い場合の超過分）は削除する。
##   to が from より長い場合、余剰の to の文字は無視される。
##   from に同一文字が複数ある場合、最初の出現位置が使用される。
##   limit で最大置換回数を指定できる。省略時は元文字列長（全置換）。
##   0 を指定すると置換を行わない。
##   負の値を指定すると末尾から置換する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_str_tr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_tr "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_str_tr|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${5:+"${5}"} || return M_EX_USAGE

	__sx_str_tr "${@}"
}

popdef([|CLEANUP|])dnl
