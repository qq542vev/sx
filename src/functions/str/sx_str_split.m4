dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_num_is_int_safe_inv __sx_str_split __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_str_split - 文字列を分割して結果変数に格納する
##
## 使い方:
##   sx_str_split 結果変数名（またはバインド形式） [文字列 [区切り文字 [分割回数 [フラグ]]]]
##
## 説明:
##   指定された文字列を区切り文字で分割し、
##   各要素をシングルクォートで囲み、スペース区切りで結合した文字列として結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   区切り文字が空の場合は、文字列の両端と文字間の境界で分割する。
##   空の元文字列では文頭と文末が重なる一つの境界を分割し、空要素を二つ返す。
##   分割回数（limit）が指定された場合、最大でその回数分だけ分割を行う。
##   分割回数が正の場合は前方から、負の場合は後方から分割する。
##   回数は任意桁の符号付き10進整数（先行ゼロなし）。8進・16進表記は受け付けない。
##   回数の省略時・空指定時は前方から無制限。0・+0・-0 は分割しない。
##   元文字列長・分割回数に SX_CFG_NUM_RANGE による上限は設けない。
##   フラグに SX_STR_SPLIT_GLOB を指定すると、区切り文字を glob パターンとして扱う。
##   フラグに SX_STR_SPLIT_INC を指定すると、分割に使用した区切り文字を結果に含める。
##   SX_STR_SPLIT_GLOB と併用した場合は、glob パターンに一致した実際の文字列を結果に含める。
##   INCで追加する区切り要素は、分割回数を増やさない。
##   フラグの形式と範囲は sx_num_is_int_safe_inv に従う。
##   空区切りと非空区切りの前方分割では、バインドが枯渇を返すと途中で終了する。
##   非空区切りの後方分割は、分割位置を確定してから前方順にバインドする。
##   互換性: 従来受理した8進・16進の回数指定は拒否し、従来拒否した空指定は無制限とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_split() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_split "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	# 回数は空指定を省略扱いにし、桁数を制限せず10進表記だけを検査する。
	# フラグはビット演算を行うため、シェルの算術で安全に扱える整数に制限する。
	__sx_num_is_int_base 10 ${4:+"${4}"} && __sx_num_is_int_safe_inv ${5+"${5}"} || return M_EX_USAGE

	__sx_str_split "${@}"
}

popdef([|CLEANUP|])dnl
