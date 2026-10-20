dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_num_is_nat0_base __sx_num_is_nat0_safe __sx_str_isep __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_isep - 文字列に一定の間隔でセパレータを挿入する
##
## 使い方:
##   sx_str_isep バインド形式 文字列 セパレータ [インターバル [リミット [フラグ]]]
##
## 説明:
##   指定された文字列に対して、指定された間隔（インターバル）ごとにセパレータを挿入して結合する。
##   インターバルが正の場合は前方から、負の場合は後方から数えて挿入する。
##   リミットを指定すると、セパレータの挿入回数を制限できる。
##   インターバルに 0 は指定できない。デフォルトのインターバルは 1。
##   インターバルは符号付き、リミットは符号なしの10進整数（先行ゼロなし）とする。
##   8進・16進表記は受け付けない。リミットの省略時・空指定時は回数制限なし。
##   元文字列長・インターバル・リミット・挿入回数に SX_CFG_NUM_RANGE による上限は設けない。
##   バインド形式で挿入結果と挿入回数を取得できる。
##   例: res:（結果のみ）、res:cnt（結果と回数）。
##
##   フラグに以下の値をビット和で指定できる：
##   - SX_STR_ISEP_CB (1): 第3引数をセパレータではなくコールバック関数名として扱う。
##   - SX_STR_ISEP_PRE (2): インターバルの境界が先頭と一致する場合に挿入を許可する。
##   - SX_STR_ISEP_POST (4): インターバルの境界が末尾と一致する場合に挿入を許可する。
##
##   コールバックのシグネチャ: callback 結果変数名 left right count
##     left: 挿入箇所より左側の文字列 (Left)
##     right: 挿入箇所より右側の文字列 (Right)
##     count: マッチカウンター (1から始まる)
##   コールバックが非0を返すと、その回の値は挿入せず、以降の挿入も停止する。
##   未処理の元文字列は保持し、成功した挿入だけを回数に数える。
##   コールバックの非0終了ステータスをそのまま返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_isep "${@}" || return; return; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${4:+"${4}"} && __sx_num_is_nat0_base 10 ${5:+"${5}"} || return M_EX_USAGE
	__sx_num_is_nat0_safe ${6:+"${6}"} || return M_EX_USAGE

	case "${4:-1}" in 0 | [+-]0)
		return M_EX_USAGE
	esac

	__sx_str_isep "${@}" || return
}

popdef([|CLEANUP|])dnl
