M_REQUIRE([|SX_CFG_SKIP_CHK SX_STR_CR SX_STR_LF __sx_csv_parse __sx_var_is_name __sx_var_is_rw __sx_var_is_rw_deep|])dnl
pushdef([|CLEANUP|])dnl
### sx_csv_parse - CSV を行ごとの SX 配列に変換する
##
## 使い方:
##   sx_csv_parse res [data [errcallback [sep [quote]]]]
##
## 説明:
##   RFC 4180 の引用規則で解析し、res の各要素を行の SX 配列にする。
##   data の既定値は空文字列。省略時も空入力として0行の配列を保存する。
##   第6引数以降は無視する。
##   sep はリテラル文字列（既定はカンマ）、quote は引用符に使う文字の集合（既定は二重引用符）。
##   sep の空指定で列区切りを無効にし、各レコードを一つのフィールドとして保存する。
##   フィールドの開始に使った一文字で閉じ、同じ文字の二重化でその引用符自体を表す。
##   引用内では集合内の別の引用符も通常文字として保持する。引用の入れ子は行わない。
##   quote の空指定で引用処理を無効にでき、タブ区切りの TSV にも対応する。
##   sep に CR・LF・quote 内のいずれかの文字を含めること、および quote に CR・LF を含めることはできない。
##   レコード区切りは CRLF または LF。引用内の改行、空白、数値表記は保持する。
##   空入力は0行、空行は空フィールド一つ。末尾改行だけでは余分な行を追加しない。
##   ヘッダは通常の行として保存し、行ごとの列数の違いを許可する。
##   ARR_REF・ARR_HOLE による解釈を行わず、全フィールドを文字列として保存する。
##   検証成功後に res を初期化する。配列を再代入する前は呼び出し側で sx_var_unset res を行う。
##   パースエラーでは完成行に加え、失敗行の確定済みフィールドだけを残す。
##   エラーになったフィールドは含めず、確定済みフィールドがなければ0列の行を残す。
##   res の長さは失敗行を含む保存済み行数とする。
##   errcallback は空またはコマンド名。最初のパースエラーで以下の形式で一度だけ呼ぶ。
##     errcallback エラーコード レコード番号 フィールド番号
##   番号は1始まり。コールバックを呼んだ場合は、その終了ステータスをそのまま返す。
##   コールバックは失敗行の保存と配列設定の復元後に呼ぶ。
##   修復・解析継続は行わない。
##   コールバックを呼ばない CSV の構文エラーは、形式不正を64とする一般規約の例外として1〜3を返す。
##
## 終了ステータス:
##   コールバックを呼んだ場合はその終了ステータス。それ以外は以下を返す。
##    0  成功
##    1  引用符が閉じないまま入力終了
##    2  非引用フィールド内に引用符が出現
##    3  閉じ引用符の後に区切り・改行・入力終了以外が出現
##   64  引数不正 (SX_EX_USAGE)
##   77  res・配下の変数・SX_CFG_ARR_HOLE・SX_CFG_ARR_REF が書き込み不可 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_csv_parse() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_csv_parse "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_csv_parse|])

	__sx_var_is_rw SX_CFG_ARR_HOLE SX_CFG_ARR_REF || return M_EX_NOPERM

	__sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM

	set -- "${1}" "${2-}" "${3-}" "${4-,}" "${5-\"}"

	case "${4}${5}" in *["${SX_STR_CR}${SX_STR_LF}"]*)
		return M_EX_USAGE
	esac

	case "${5:+${4}}" in *["${5}"]*)
		return M_EX_USAGE
	esac

	__sx_csv_parse "${@}" || return
}

popdef([|CLEANUP|])dnl
