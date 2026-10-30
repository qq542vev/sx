M_REQUIRE([|SX_CFG_SKIP_CHK __sx_glob_bracket __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_glob_bracket - 文字セットを glob ブラケット式で安全な形に並べ替える
##
## 使い方:
##   sx_glob_bracket 結果変数名 [文字セット]
##
## 説明:
##   指定された文字セットを、glob のブラケット式 [...] 内で安全に使用できる
##   順序に並べ替える。以下の処理を行う:
##   - ] は必ず先頭に配置
##   - - は末尾に配置
##   - ! ^ は後方に配置して、先頭での否定解釈を避ける
##   - = . : は重複を除いて後方に配置し、先頭と末尾が同じ記号になる3要素以上の形を避ける
##   - [ は = . : より後ろ、! ^ - より前に配置し、特殊構文 [= [. [: の開始を避ける
##   結果は [...] で囲まれたブラケット式として返される。
##   ただし、文字セットが ! のみの場合はブラケット式として表現できないため ! をそのまま返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  結果変数名が無効 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_glob_bracket() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_bracket "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_glob_bracket|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM
	case "${2:+X}" in '')
		return M_EX_USAGE
	esac

	__sx_glob_bracket "${@}"
}

popdef([|CLEANUP|])dnl
