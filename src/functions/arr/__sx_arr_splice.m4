dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_ARR_UPDATE __sx_arr_splice_raw __sx_var_touch|])dnl
pushdef([|CLEANUP|])dnl
### __sx_arr_splice - 配列の一部を削除し、同位置に値を挿入する（内部用）
##
## 使い方:
##   __sx_arr_splice 配列名 n del [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   raw 処理で要素と長さを変更し、ARR_UPDATE の設定に従ってリビジョンを一度だけ更新する。
##
## 終了ステータス:
##    0  成功
__sx_arr_splice() {
	__sx_arr_splice_raw "${@}"

	case "${SX_CFG_ARR_UPDATE-}" in 1)
		__sx_var_touch "${1}"
	esac
}

popdef([|CLEANUP|])dnl
