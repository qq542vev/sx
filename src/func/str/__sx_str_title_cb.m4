M_REQUIRE([|__sx_str_lower_cb __sx_str_upper_cb|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_title_cb - sx_str_title 用コールバック（内部用）
##
## 使い方:
##   __sx_str_title_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   内部実装。引数チェックは行わない。
##   sx_str_sub のコールバックモードから呼び出される。
##   マッチ文字列（セパレータ文字+小文字）の小文字部分を大文字に変換する。
##   英字を含む区切り集合では、一文字のマッチと元文字列の左側を受け取り、
##   Q_cb_sep の文字集合に直前の文字が含まれるかで大文字化・小文字化を選ぶ。
##
## 終了ステータス:
##    0  成功

__sx_str_title_cb() {
	case "${2}" in
		?)
			case "${3}" in
				'' | *["${Q_cb_sep}"]) __sx_str_upper_cb "${1}" "${2}";;
				*) __sx_str_lower_cb "${1}" "${2}";;
			esac
			;;
		*)
			__sx_str_upper_cb "${1}" "${2#?}"
			eval "${1}=\"\${2%?}\${${1}}\""
			;;
	esac
}
|], [|str_title|])dnl
popdef([|CLEANUP|])dnl
