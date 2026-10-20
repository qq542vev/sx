dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_pad __sx_num_is_int_base __sx_num_is_int_safe_inv __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_pad - 引数リストを指定された長さになるようパディングする
##
## 使い方:
##   sx_arg_pad bind [len [val [flg]]] ::: [arg ...]
##   sx_arg_pad bind [len [arg ...]]
##
## 説明:
##   与えられた引数リスト [arg ...] を、絶対値が |len| になるよう
##   val で拡張する。len が正の場合は右側（末尾）に、
##   負の場合は左側（先頭）にパディングする。
##   元の引数リストの長さが |len| 以上の場合は、そのまま出力する。
##   結果はシングルクォートで囲まれ、スペース区切りで結合された形式で
##   結果変数に格納される。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   len は10進整数表記に限る。符号（+ または -）は任意で、0以外の先行する0は認めない。
##   引数個数・長さ・コールバックの各カウンタに SX_CFG_NUM_RANGE による上限は設けない。
##
##   2 つの呼び出し形式がある:
##     1) ::: 形式: bind/len/val/flg を ::: より前の位置引数で指定し、
##        ::: 以降をデータとして扱う。設定引数とデータを明確に分離できる。
##     2) 簡略形式: 第一引数が bind、第二引数が len、第三引数以降がデータ
##        となる。val は空文字列、flg は 0 とする。
##   bind は必須（空文字列可）。len の省略時は 0 とする。
##   簡略形式では空の len も 0 とする。::: 形式で len に空文字列を明示した場合は不正。
##   ::: は SX_CFG_SEP の値を使用する。データ先頭付近にその値を含む場合は、
##   ::: 形式で境界を明示する。
##
##   コールバックモード:
##     flg に SX_ARG_PAD_CB (1) を設定すると、val はコールバック関数名として
##     解釈される。コールバックはパディングスロットごとに呼び出され、
##     動的にパディング値を生成する。
##     コールバック契約: cb ret_var idx cnt skip
##       - ret_var: 結果を格納する変数名（unset するとそのスロットをスキップ）
##       - idx: 1-based 実際の出力位置（skip 考慮済み）
##       - cnt: 1-based パディングスロット番号
##       - skip: スキップ累計数
##     コールバックは途中の処理を別変数で行い、末尾で ret_var に単純代入する。
##     ret_var を他の関数の結果変数・バインド先として渡してはならない。
##     callback が非 0 を返した場合、処理を中断する。
##     左パディングで中断した場合も、元の値はバインドが続く限り末尾に結合する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_pad() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_pad "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}") ;;
		"${3+X${3}}" | "${4+X${4}}") __sx_num_is_int_base 10 "${2}";;
		"${5+X${5}}") __sx_num_is_int_base 10 "${2}" && __sx_num_is_int_safe_inv "${4}";;
		*) __sx_num_is_int_base 10 ${2:+"${2}"};;
	esac || return M_EX_USAGE

	__sx_arg_pad "${@}" || return
}

popdef([|CLEANUP|])dnl
