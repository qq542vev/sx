M_REQUIRE([|__sx_str_upper_cb|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_title_cb - sx_str_title 用コールバック（内部用）
##
## 使い方:
##   __sx_str_title_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   マッチ文字列（セパレータ文字+小文字）の小文字部分を大文字に変換する。
__sx_str_title_cb() {
	__sx_str_upper_cb "${1}" "${2#?}"
	eval "${1}=\"\${2%?}\${${1}}\""
}

popdef([|CLEANUP|])dnl
