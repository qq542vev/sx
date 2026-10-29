M_REQUIRE([|__sx_str_is_control|])dnl
### sx_str_is_control - すべての引数がC0・C1・DELのみで構成されているか確認する
##
## 使い方:
##   sx_str_is_control [文字列1 [文字列2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_str_is_control に委譲する。
##   0x01-0x1Fと0x7F-0x9Fを対象とし、C0・C1・DELの混在も受理する。
##   空文字列は不一致とし、引数がない場合は成功する。
##
## 終了ステータス:
##    0  すべてC0・C1・DELのみで構成されている、または引数がない (SX_EX_OK)
##    1  範囲外が含まれる、または空文字列が含まれる

sx_str_is_control() {
	M_CFG_CHECK([|sx_str_is_control|])

	__sx_str_is_control "${@}" || return
}
