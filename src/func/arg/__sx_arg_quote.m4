M_REQUIRE([|__sx_var_bind __sx_var_bind_init|])dnl
### __sx_arg_quote - 引数をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_quote スキーマ [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   分配代入およびクォート結合処理を行う。
##
## 終了ステータス:
##    0  成功（バインド枯渇による早期終了を含む）

__sx_arg_quote() {
	__sx_var_bind_init "${1}"
	__sx_var_bind '' "${@}" || :
}
