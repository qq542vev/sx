M_REQUIRE([|__sx_var_is_chain|])dnl
### sx_var_is_chain - 文字列が有効な連鎖式であるか確認する
##
## 使い方:
##   sx_var_is_chain [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_var_is_chain に委譲する。
##   引数で指定されたすべての文字列が、sx_var_copy 等で使用可能な
##   有効な連鎖式（A-B-C または A=B=C）であるか、あるいは単一の有効な変数名
##   であるかを確認する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる

sx_var_is_chain() {
	M_CFG_CHECK([|sx_var_is_chain|])

	__sx_var_is_chain "${@}" || return
}
