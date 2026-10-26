M_REQUIRE([|__sx_str_is_nonempty|])dnl
### sx_str_is_nonempty - すべての引数が空文字列でないか確認する
##
## 使い方:
##   sx_str_is_nonempty [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_nonempty に委譲する。
##   空白や改行だけの文字列も空でないものとして扱う。
##   引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべて空でない、または引数がない (SX_EX_OK)
##    1  空文字列が含まれる

sx_str_is_nonempty() {
	M_CFG_CHECK([|sx_str_is_nonempty|])

	__sx_str_is_nonempty "${@}" || return
}
