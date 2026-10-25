M_REQUIRE([|__sx_util_eval|])dnl
### sx_util_eval - 文字列をシェルコマンドとして実行する
##
## 使い方:
##   sx_util_eval コマンド文字列
##
## 説明:
##   実処理は内部関数 __sx_util_eval に委譲する。
##   引数で渡された文字列を eval を用いて実行する。
##   直接的な eval の使用を避け、意図を明確にするためのラッパー。
##
## 終了ステータス:
##    評価したコマンドの終了ステータスを返す

sx_util_eval() {
	M_CFG_CHECK([|sx_util_eval|])

	__sx_util_eval "${@}" || return
}
