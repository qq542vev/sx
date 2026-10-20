dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_num_is_nat0_base __sx_num_is_nat0_safe __sx_str_chunk __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_str_chunk - 文字列を一定の長さで区切って結果変数（またはバインドチェーン）に格納する
##
## 使い方:
##   sx_str_chunk スキーマ [文字列 [長さ [分割回数 [フラグ]]]]
##
## 説明:
##   指定された文字列を、指定された長さ（文字数）ごとに区切る。
##   長さが正の場合は基準方向から、負の場合はその逆方向から区切る。
##   基準方向は前方で、結果も前方からの順序で格納する。
##   後方基準で結果を返す場合は sx_str_rchunk を使用する。
##   チャンク内部の文字順は保持する。
##   分割回数が指定された場合、最大でその回数分だけ分割を行う。
##   長さの省略時または空文字列指定時は 1 とする。単独の 0 はエラー (SX_EX_USAGE)。
##   長さは 1:-2:3 のようにコロン区切りで指定でき、順番に繰り返す。
##   周期内の 0 は空チャンクを生成するが、全項目が 0 の指定はできない。
##   長さは任意桁の符号付き10進整数、分割回数は任意桁の符号なし10進整数。
##   先行する 0、8進・16進表記は受け付けない。回数の省略時・空指定時は回数制限なし。
##
##   スキーマ (第一引数) には、単一の変数名またはバインドチェーン (v1:v2:rest) を指定できる。
##   - 単一変数名: 各要素をシングルクォートで囲み、スペース区切りで結合した文字列を格納する。
##   - バインドチェーン: 分割された要素を順番に変数に代入する。
##     - 要素数が変数より多い場合、最後の変数は残りの全要素をクォート結合した文字列として保持する。
##     - 変数名が空 (v1::v3) の要素はスキップされる。
##     - スキーマがコロンで終わる (v1:v2:) 形式の場合、指定された変数への代入が完了した時点で
##       処理を早期終了する（巨大な文字列の部分取得に有効）。
##
##   格納される値およびクォート結合される文字列は、メタ文字が適切にエスケープされており、
##   eval 等を用いて安全に位置パラメータとして復元できる。
##
##   フラグ (第五引数) はビットマスクで指定する。
##   SX_STR_CHUNK_SKIP_SHORT / SX_STR_CHUNK_SKIP_LONG は、指定された条件に該当する
##   残余チャンクを結果に含めずスキップする。
##   例: abcde を長さ 2 で分割すると ab, cd, e、長さ -2 では a, bc, de。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  スキーマに含まれる変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
define([|CLEANUP|], [|Q_cycle Q_cur|])dnl

sx_str_chunk() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_chunk "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 ${4:+"${4}"} || return M_EX_USAGE
	__sx_num_is_nat0_safe ${5:+"${5}"} || return M_EX_USAGE

	case "${3:-1}" in
		*[1-9]*) ;;
		*) return M_EX_USAGE;;
	esac

	# split の文字列長制限に依存せず、周期の各項目を検証する。
	Q_cycle="${3:-1}:"
	while M_STR_HAS([|"${Q_cycle}"|], [|:|]); do
		Q_cur="${Q_cycle%%:*}"
		Q_cycle="${Q_cycle#*:}"
		__sx_num_is_int_base 10 "${Q_cur}" || {
			unset CLEANUP
			return M_EX_USAGE
		}
	done
	unset CLEANUP

	__sx_str_chunk "${@}"
}

|], [|str_chunk|])dnl
popdef([|CLEANUP|])dnl
