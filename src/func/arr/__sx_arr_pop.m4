M_REQUIRE([|__sx_arr_pop_raw __sx_var_touch|])dnl
pushdef([|CLEANUP|])dnl
### __sx_arr_pop - 配列から要素を取り出して割り当てる（内部用）
##
## 使い方:
##   __sx_arr_pop bind 配列名
##
## 説明:
##   内部実装。引数チェックは行わない。
##   raw 処理が成功した場合だけ、元配列のリビジョンを必ず一度更新する。
##
## 終了ステータス:
##    0  成功
##    1  要素不足（無変更）
__sx_arr_pop() {
	__sx_arr_pop_raw "${@}" || return

	__sx_var_touch "${2}"
}

popdef([|CLEANUP|])dnl
