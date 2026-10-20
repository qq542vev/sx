M_REQUIRE([|__sx_str_substr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_splice - 文字列の一部を削除し、そこに新しい文字列を挿入する（内部用）
##
## 使い方:
##   __sx_str_splice 結果変数名 [文字列 [開始位置 [削除数 [挿入文字列]]]]
##
## 説明:
##   sx_str_splice の内部実装。引数チェックは行わない。
##   数値引数は sx_str_substr と同じ10進整数表記を前提とする。
##   空の開始位置は 0、空の削除数は末尾までの削除として扱う。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_left Q_suffix Q_del|])dnl

__sx_str_splice() {
	# 開始位置を先頭・末尾に収めた前半を取得する。
	__sx_str_substr Q_left "${2-}" 0 "${3:-0}"
	Q_suffix="${2:+"${2#"${Q_left}"}"}"

	# 元文字列を基準に削除範囲を求め、先頭より前の分も長さに反映する。
	__sx_str_substr Q_del "${2-}" "${3:-0}" ${4:+"${4}"}
	M_VAR_SET([|${1}|], [|${Q_left}${5-}${Q_suffix#"${Q_del}"}|])

	unset CLEANUP
}
|], [|str_splice|])dnl
popdef([|CLEANUP|])dnl
