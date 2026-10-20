dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_sub_isep_adapt - 挿入コールバックを置換コールバックの形式に変換する（内部用）
##
## 使い方:
##   __sx_str_sub_isep_adapt 結果変数名 left right count
##
## 説明:
##   内部実装。引数チェックは行わない。
##   空パターン時の match は常に空文字列とする。
##   呼び出し先 Q_cb は __sx_str_isep の呼び出しに限定した一時代入で渡す。
##
## 終了ステータス:
##   コールバックの終了ステータス
__sx_str_sub_isep_adapt() {
	set -- "${Q_cb}" "${@}"
	unset Q_cb

	"${1}" "${2}" '' "${3}" "${4}" "${5}" && set -- "${1}" 0 || set -- "${1}" "${?}"

	Q_cb="${1}"
	return "${2}"
}
|], [|str_sub|])dnl
popdef([|CLEANUP|])dnl
