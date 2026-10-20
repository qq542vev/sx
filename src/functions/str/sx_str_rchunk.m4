dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_num_is_nat0_base __sx_num_is_nat0_safe __sx_str_rchunk __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_str_rchunk - 文字列を一定の長さで区切り後方から結果を格納する
##
## 使い方:
##   sx_str_rchunk スキーマ [文字列 [長さ [分割回数 [フラグ]]]]
##
## 説明:
##   指定された文字列を、指定された長さ（文字数）ごとに区切る。
##   基準方向と結果の格納順は後方とし、チャンク内部の文字順は保持する。
##   長さが正の場合は後方から、負の場合は前方から切り取る。
##   例: abcde を長さ 2 で分割すると de, bc, a、長さ -2 では e, cd, ab。
##   長さの省略時または空指定時は 1 とする。単独の 0 はエラーとする。
##   長さは 1:-2:3 のような周期で指定でき、周期内の 0 は空チャンクを生成する。
##   全項目が 0 の周期は指定できない。
##   長さは任意桁の符号付き10進整数、分割回数は任意桁の符号なし10進整数。
##   先行する 0、8進・16進表記は受け付けない。
##   回数の省略時・空指定時は無制限、0 は分割しない。
##   スキーマの形式と引用規則は sx_str_chunk と同じ。
##   バインドチェーンには後方からの結果を順に割り当て、末尾がコロンなら枯渇時に終了する。
##   SX_STR_RCHUNK_SKIP_SHORT / SX_STR_RCHUNK_SKIP_LONG は、指定された条件に該当する
##   残余チャンクを結果に含めずスキップする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  スキーマに含まれる変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_cycle Q_cur|])dnl

sx_str_rchunk() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rchunk "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 ${4:+"${4}"} || return M_EX_USAGE
	__sx_num_is_nat0_safe ${5:+"${5}"} || return M_EX_USAGE

	case "${3:-1}" in
		*[1-9]*) ;;
		*) return M_EX_USAGE;;
	esac

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

	__sx_str_rchunk "${@}"
}
|], [|str_rchunk|])dnl
popdef([|CLEANUP|])dnl
