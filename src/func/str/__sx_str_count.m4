M_REQUIRE([|__sx_arg_len __sx_str_find|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_count - 文字列から指定された文字列の出現回数を取得する（内部用）
##
## 使い方:
##   __sx_str_count 結果変数名 [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_count の内部実装。引数チェックは行わない。
##   空検索と Glob の * のみの検索は、元文字列に空白を1文字足した文字数を返す。
##   それ以外は検索結果の個数を取得する。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_count() {
	if
		M_STR_EQ([|"${3-}"|], [|''|]) ||
		{ M_NUM_BOOL([|${4:-0} & M_STR_COUNT_GLOB|]) && ! M_STR_HAS([|"${3-}"|], [|*[!*]*|]); }
	then
		set -- "${1}" " ${2-}"
		M_VAR_SET([|${1}|], [|${#2}|])
		return
	fi

	__sx_str_find Q_tmp "${2-}" "${3-}" "${4:-0}" || :
	eval __sx_arg_len '"${1}"' "${Q_tmp}"
	unset CLEANUP
}
|], [|str_count|])dnl
popdef([|CLEANUP|])dnl
