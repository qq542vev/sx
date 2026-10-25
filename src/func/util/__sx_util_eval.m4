M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
### __sx_util_eval - 文字列をシェルコマンドとして実行する（内部用）
##
## 使い方:
##   __sx_util_eval コマンド文字列
##
## 説明:
##   内部実装。引数チェックは行わない。
##   引数で渡された文字列を eval を用いて実行する。
##   直接的な eval の使用を避け、意図を明確にするためのラッパー。
##
## 終了ステータス:
##    評価したコマンドの終了ステータスを返す

__sx_util_eval() {
	eval "${1}" || return
}

popdef([|CLEANUP|])dnl
