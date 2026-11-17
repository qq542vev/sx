M_REQUIRE([|__sx_num_is_ufloat|])dnl
### sx_num_is_ufloat - すべての引数が符号なし 10 進の実数表記（浮動小数点形式）であるか確認する
##
## 使い方:
##   sx_num_is_ufloat [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_ufloat に委譲する。
##   符号なし 10 進の実数表記（浮動小数点形式）であるかを確認する。
##   sx_num_is_ufixed に加えて、指数表記（e または E による表記）を許可する。
##
## 終了ステータス:
##    0  すべて符号なし 10 進の実数表記である (SX_EX_OK)
##    1  符号なし 10 進の実数表記ではない値が含まれる

sx_num_is_ufloat() {
	M_CFG_CHECK([|sx_num_is_ufloat|])

	__sx_num_is_ufloat "${@}" || return
}
