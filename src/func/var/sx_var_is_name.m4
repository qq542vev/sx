M_REQUIRE([|__sx_var_is_name|])dnl
### sx_var_is_name - 変数名として有効か確認する
##
## 使い方:
##   sx_var_is_name [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_var_is_name に委譲する。
##
## 終了ステータス:
##    0  すべて有効な変数名 (SX_EX_OK)
##    1  無効な変数名が含まれる

sx_var_is_name() {
	__sx_var_is_name "${@}" || return
}
