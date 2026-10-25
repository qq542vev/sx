M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_str_title __sx_var_is_name __sx_var_is_rw sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_title - 各単語の先頭を大文字、残りを小文字に変換する
##
## 使い方:
##   sx_str_title 結果変数名 [元文字列 [単語区切り文字セット]]

## 説明:
##   指定された文字列内の各単語の先頭文字を大文字に、残りの文字を小文字に変換する。
##   単語の区切りは単語区切り文字セットで判断する。デフォルトは ${SX_STR_SPACE}
##   （空白文字すべて）。文字セット内の各文字が単語区切りとして扱われる。
##   文字列先頭も単語の先頭として扱う。
##   元文字列・中間文字列の長さと変換回数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_title() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_title "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_str_title "${@}"
}

popdef([|CLEANUP|])dnl
