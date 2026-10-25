M_REQUIRE([|__sx_num_is_float_safe|])dnl
### sx_num_is_float_safe - すべての引数が安全な範囲の 10 進の実数表記であるか確認する
##
## 使い方:
##   sx_num_is_float_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_num_is_float_safe に委譲する。
##   sx_num_is_float による検証に加えて、セキュリティ上の理由（DoS 対策）から、
##   指数の絶対値を 4 桁（9999）までに制限する。
##
## 終了ステータス:
##    0  すべて安全な 10 進の実数表記である (SX_EX_OK)
##    1  安全ではない、または 10 進の実数表記ではない値が含まれる

sx_num_is_float_safe() {
	M_CFG_CHECK([|sx_num_is_float_safe|])

	__sx_num_is_float_safe "${@}" || return
}
