M_REQUIRE([|SX_CFG_ARR_UPDATE __sx_arr_push_raw __sx_var_touch|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_push - 配列の末尾に要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_push 配列名 [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   raw 処理で末尾へ追加し、ARR_UPDATE の設定に従ってリビジョンを一度だけ更新する。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [||])dnl

__sx_arr_push() {
	__sx_arr_push_raw "${@}"

	case "${SX_CFG_ARR_UPDATE-}" in 1)
		__sx_var_touch "${1}"
	esac
}
|], [|arr_push|])dnl
popdef([|CLEANUP|])dnl
