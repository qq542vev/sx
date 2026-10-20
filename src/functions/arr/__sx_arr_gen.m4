dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SIG_ARR __sx_arr_push_raw __sx_var_touch|])dnl
pushdef([|CLEANUP|])dnl
### __sx_arr_gen - 配列を初期化し、要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_gen 配列名 [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   指定された配列を初期化し、raw 処理で要素を追加した後に必ずリビジョンを更新する。
##   SX_CFG_ARR_UPDATE 自体は変更しない。
##
## 終了ステータス:
##    0  成功
__sx_arr_gen() {
	M_VAR_SET([|${1}|], [|${SX_CFG_SIG_ARR}:|], [|${1}_len|], [|0|])

	__sx_arr_push_raw "${@}"
	__sx_var_touch "${1}"
}

popdef([|CLEANUP|])dnl
