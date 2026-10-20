dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_words_cb - sx_str_words 用コールバック（内部用）
##
## 使い方:
##   __sx_str_words_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   大文字の前後を判定し、単語境界なら _ を挿入する。
__sx_str_words_cb() {
	case "${3}" in
		'') eval "${1}=\"\${2}\"";;
		*[a-z]) eval "${1}=\"\${__sx_str_words_cb_c_}\${2}\"";;
		*[A-Z])
			case "${4}" in
				[a-z]*) eval "${1}=\"\${__sx_str_words_cb_c_}\${2}\"";;
				*) eval "${1}=\"\${2}\"";;
			esac
			;;
		*) eval "${1}=\"\${2}\"";;
	esac
}

# ========================================
#  GLOB (Glob Pattern Operations)
# ========================================

popdef([|CLEANUP|])dnl
