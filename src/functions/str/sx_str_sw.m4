dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_str_sw - 第一引数が、第二引数以降のいずれかの文字列で始まっているか確認する
##
## 使い方:
##   sx_str_sw [検索対象文字列 [開始文字列1 [開始文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 開始文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列の接頭辞であれば成功する
## - 開始文字列が 1 つも指定されなかった場合は失敗する
## - 開始文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかの開始文字列で始まっている (SX_EX_OK)
##    1  一致する開始文字列がない

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_sw() {
	Q_tgt="${1-}"
	${1+'shift'}

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in "${Q_arg}"*)
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_sw|])dnl
popdef([|CLEANUP|])dnl
