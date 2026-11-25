M_REQUIRE([|__sx_sh_is_pos|])dnl
### sx_sh_is_pos - すべての引数が位置パラメータとして有効か確認する
##
## 使い方:
##   sx_sh_is_pos [位置パラメータ1 [位置パラメータ2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_sh_is_pos に委譲する。
##   同じ判定は SX_SH_REJECT_POS を評価してから SX_SH_ACCEPT_POS を
##   評価しても利用できる。定数は case のパターン列なので eval で埋め込む。
##   定数単独では判定できず、REJECT を通過したものだけを ACCEPT で判定する。
##
## 終了ステータス:
##    0  すべて有効な位置パラメータ (SX_EX_OK)
##    1  無効な位置パラメータが含まれる

sx_sh_is_pos() {
	M_CFG_CHECK([|sx_sh_is_pos|])

	__sx_sh_is_pos "${@}" || return
}
