M_REQUIRE([|__sx_arr_splice_raw|])dnl
pushdef([|CLEANUP|])dnl
### __sx_arr_push_raw - リビジョンを更新せず配列の末尾へ追加する（内部用）
##
## 使い方:
##   __sx_arr_push_raw 配列名 [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   splice_raw の末尾追加として要素と長さを変更する。参照・穴の解釈は従来どおり行う。
##
## 終了ステータス:
##    0  成功
__sx_arr_push_raw() {
	eval 'shift;' __sx_arr_splice_raw "${1}" "\"\${${1}_len}\"" 0 '"${@}"'
}

popdef([|CLEANUP|])dnl
