M_REQUIRE([|__sx_str_is_upper|])dnl
### sx_str_is_upper - すべての引数が大文字英字（A-Z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_upper [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_upper に委譲する。
##
## 終了ステータス:
##    0  すべて大文字英字のみで構成されている (SX_EX_OK)
##    1  大文字英字以外が含まれる、または空文字列が含まれる

sx_str_is_upper() {
	__sx_str_is_upper "${@}" || return
}
