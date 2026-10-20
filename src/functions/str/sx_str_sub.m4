M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_num_is_nat0_safe __sx_str_sub __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_sub - 文字列内のパターンを置換する
##
## 使い方:
##   sx_str_sub バインド形式 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   元文字列の中に含まれる検索パターンを、置換文字列に置き換える。
##   バインド形式で置換結果と置換回数を取得できる。
##   例: res:（結果のみ）、res:cnt（結果と回数）。
##   元文字列・検索パターン・置換文字列の省略時は空文字列として扱う。
##   回数制限は符号付き10進整数（先行ゼロなし）とし、8進・16進表記は受け付けない。
##   回数制限の省略時・空指定時は前方から回数制限なしで置換する。
##   元文字列長・回数制限・置換回数に SX_CFG_NUM_RANGE による上限は設けない。
##   検索パターンが空文字列の場合は、各文字の間および両端に置換文字列を挿入する。
##   回数制限が正の場合は前方から、負の場合は後方から指定された回数分だけ置換する。
##   0・+0・-0 の場合は置換しない。
##   フラグに SX_STR_SUB_GLOB を指定すると、検索パターンを glob パターンとして扱う。
##   フラグに SX_STR_SUB_CB を指定すると、第4引数をコールバック関数名として扱う。
##   コールバック関数は以下の形式で呼び出される:
##     関数名 結果変数名 マッチ文字列 left(未置換) right(未置換) マッチ回数(1〜)
##     left: マッチ箇所より左側の文字列
##     right: マッチ箇所より右側の文字列
##   その実行結果（第1引数の変数に格納された値）が置換後の文字列として使用される。
##   結果変数が未設定の場合はマッチ文字列をそのまま使用する。
##   コールバックが非0を返すと、その回は置換せず、以降の置換も停止する。
##   未処理の元文字列は保持し、成功した置換だけを回数に数える。
##   コールバックの非0終了ステータスをそのまま返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  コールバックの終了ステータス
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_sub() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_sub "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${5:+"${5}"} && __sx_num_is_nat0_safe ${6:+"${6}"} || return M_EX_USAGE

	__sx_str_sub "${@}" || return
	return 0
}

popdef([|CLEANUP|])dnl
