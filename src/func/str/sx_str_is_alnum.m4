M_REQUIRE([|__sx_str_is_alnum|])dnl
### sx_str_is_alnum - すべての引数が英数字（A-Z, a-z, 0-9）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_alnum [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_alnum に委譲する。
##
## 終了ステータス:
##    0  すべて英数字のみで構成されている (SX_EX_OK)
##    1  英数字以外が含まれる、または空文字列が含まれる

sx_str_is_alnum() {
	__sx_str_is_alnum "${@}" || return
}
