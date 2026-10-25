M_REQUIRE([|SX_ARG_FIND_CB SX_ARG_FIND_GLOB SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_find __sx_num_is_nat0_safe __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_find - 引数リストから指定された値を探し、そのインデックスまたは値を取得する
##
## 使い方:
##   sx_arg_find bind [検索対象 [フラグ]] ::: [値 ...]
##   sx_arg_find bind [検索対象 [値 ...]]
##
## 説明:
##   検索対象が、指定された値のリストの中で何番目（1開始）にあるかを探し、
##   一致した項目のインデックスをスペース区切りで結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   フラグに SX_ARG_FIND_GLOB (1) を指定すると、検索対象を glob パターンとして扱う。
##   フラグに SX_ARG_FIND_TEXT (4) を指定すると、インデックスの代わりにマッチした値を出力する。
##   フラグに SX_ARG_FIND_CB (2) を指定すると、検索対象をコールバック関数として扱う。
##   コールバックシグネチャ: callback value index count
##     0 を返すと一致、非0 は不一致としてスキップ。
##     count は現在の要素より前で一致した件数（0開始）。
##   見つからない場合は空文字列を格納する。
##   取得件数はバインド形式によって決まる。
##   例: res（全件）、3res:（最大3件）、idx1:idx2（2件を分配）
##   2つの呼び出し形式がある:
##     1. :::（SX_CFG_SEP）形式。bind は必須で、検索対象・フラグを
##        ::: より前に指定する。::: より後はすべてデータとなる。
##        検索対象・フラグは省略でき、それぞれ空文字列・0 とする。
##     2. 簡易形式。第1引数が bind、第2引数が検索対象、
##        第3引数以降がデータとなる。フラグは 0 とする。
##        検索対象の省略時は空文字列とする。
##   bind 自体の省略は不可。空文字列の bind は有効だが、検索せず 1 を返す。
##   データ先頭付近に SX_CFG_SEP の値を含む場合は、::: 形式で境界を明示する。
##   引数個数・インデックス・一致数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった (不一致)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arg_find() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_find "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_arg_find|])

		__sx_var_is_bind "${1-!}" || return M_EX_USAGE

		__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_num_is_nat0_safe "${3}" || return M_EX_USAGE

			case "$(((${3} & SX_ARG_FIND_GLOB) * (${3} & SX_ARG_FIND_CB)))" in [!0])
				return M_EX_USAGE
			esac
			;;
	esac

	__sx_arg_find "${@}" || return
}

popdef([|CLEANUP|])dnl
