M_REQUIRE([|__sx_sh_is_param|])dnl
### sx_sh_is_param - パラメータ名として有効か確認する
##
## 使い方:
##   sx_sh_is_param [パラメータ1 [パラメータ2 ...]]
##
## 説明:
##   実処理は内部関数 __sx_sh_is_param に委譲する。
##   同じ判定は SX_SH_REJECT_PARAM を評価してから SX_SH_ACCEPT_PARAM を
##   評価しても利用できる。定数は case のパターン列なので eval で埋め込む。
##   定数単独では判定できず、REJECT を通過したものだけを ACCEPT で判定する。
##
## 終了ステータス:
##    0  すべて有効なパラメータ (SX_EX_OK)
##    1  無効なパラメータが含まれる

sx_sh_is_param() {
	M_CFG_CHECK([|sx_sh_is_param|])

	__sx_sh_is_param "${@}" || return
}
