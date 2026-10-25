M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_match - 第一引数が、後続引数のいずれかのパターンにマッチするか確認する（内部用）
##
## 使い方:
##   __sx_str_match [検索対象文字列 [パターン1 [パターン2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - パターンはシェル標準の glob 形式（*, ?, [...]）を使用できる
## - 第二引数以降のいずれかが検索対象文字列にマッチすれば成功する
## - パターンが 1 つも指定されなかった場合は失敗する
##
## 説明:
##   内部実装。引数チェックは行わない。
##
## 終了ステータス:
##    0  いずれかのパターンにマッチする (SX_EX_OK)
##    1  マッチするパターンがない

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

__sx_str_match() {
	Q_tgt="${1-}"
	${1+'shift'}

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in ${Q_arg})
			unset CLEANUP
			return
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_match|])dnl
popdef([|CLEANUP|])dnl
