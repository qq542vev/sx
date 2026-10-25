M_REQUIRE([|__sx_arr_splice_raw __sx_var_touch|])dnl
pushdef([|CLEANUP|])dnl
### __sx_arr_splice - 配列の一部を削除し、同位置に値を挿入する（内部用）
##
## 使い方:
##   __sx_arr_splice 配列名 n del [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   raw 処理で要素と長さを変更し、成功時に必ずリビジョンを一度だけ更新する。
##   要素と長さに変更がなくても更新する。
##
## 終了ステータス:
##    0  成功
__sx_arr_splice() {
	__sx_arr_splice_raw "${@}" || return

	__sx_var_touch "${1}"
}

popdef([|CLEANUP|])dnl
