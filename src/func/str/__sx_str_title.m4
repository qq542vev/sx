M_REQUIRE([|__sx_str_capital __sx_str_lower|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_title - 各単語の先頭を大文字、残りを小文字に変換する（内部用）
##
## 使い方:
##   __sx_str_title 結果変数名 [元文字列 [単語区切り文字セット]]
##
## 説明:
##   sx_str_title の内部実装。引数チェックは行わない。
##   単語ごとのケース変換を内部の capital・lower 関数に委譲し、区切り文字は元のまま出力する。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_str Q_sep Q_out Q_tmp Q_conv|])dnl

__sx_str_title() {
	Q_str="${2-}"
	Q_sep="${3:-M_STR_SPACE()}"
	Q_out=

	while
		Q_tmp="${Q_str%%["${Q_sep}"]*}"

		case "${Q_tmp}" in
			[M_STR_ALPHA()]*) __sx_str_capital Q_conv "${Q_tmp}";;
			*[M_STR_UPPER()]*) __sx_str_lower Q_conv "${Q_tmp}";;
			*) Q_conv="${Q_tmp}";;
		esac

		case "${Q_str}" in *["${Q_sep}"]*)
			Q_str="${Q_str#"${Q_tmp}"}"
			M_STR_APPEND([|Q_out|], [|"${Q_conv}${Q_str%%"${Q_str#?}"}"|])
			Q_str="${Q_str#?}"

			continue
		esac

		break
	do :; done

	M_VAR_SET([|${1}|], [|${Q_out}${Q_conv}|])
	unset CLEANUP
}
|], [|str_title|])dnl
popdef([|CLEANUP|])dnl
