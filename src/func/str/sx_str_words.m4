M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_str_words __sx_var_is_name __sx_var_is_rw sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_words - 命名規則を自動検出して単語に分割する
##
## 使い方:
##   sx_str_words 結果変数名 [文字列]
##
## 説明:
##   入力文字列の命名規則を自動検出し、単語をスペース区切りの小文字で
##   結果変数に格納する。
##   以下の命名規則に対応:
##   - snake_case: _ で分割
##   - kebab-case: - で分割
##   - camelCase / PascalCase: 大文字の境界で分割
##   - 連続大文字（頭字語）も適切に扱う
##   元文字列・中間文字列の長さと変換回数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_words() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_words "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_str_words "${@}"
}

popdef([|CLEANUP|])dnl
