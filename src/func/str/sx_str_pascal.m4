M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_str_pascal __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_pascal - さまざまな命名規則を PascalCase に変換する
##
## 使い方:
##   sx_str_pascal 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   入力文字列の命名規則を自動検出し、PascalCase（各単語先頭大文字、
##   残り小文字、区切りなし）に変換する。
##   内部で sx_str_words と sx_str_title を使用し、単語分割後に
##   各単語をタイトルケース化して結合する。
##   対応する入力形式:
##   - snake_case: _ で分割
##   - kebab-case: - で分割
##   - camelCase / PascalCase: 大文字の境界で分割
##   - 空白区切り: 空白で分割
##   区切り文字セットの各文字は単語区切りとして扱われる。
##   デフォルトの区切り文字セットは "_-/.:${SX_STR_SPACE}"。
##   元文字列・中間文字列の長さと変換回数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_pascal() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_pascal "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_str_pascal "${@}"
}

popdef([|CLEANUP|])dnl
