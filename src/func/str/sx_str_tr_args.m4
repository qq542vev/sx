M_REQUIRE([|SX_CFG_SEP SX_CFG_SKIP_CHK __sx_num_is_int_base __sx_str_tr_args __sx_var_is_bind __sx_var_is_bindable|])dnl
### sx_str_tr_args - 文字列内の文字を引数で指定した文字列へ置換する
##
## 使い方:
##   sx_str_tr_args バインド形式 文字列 from文字列 [置換先 ...]
##   sx_str_tr_args バインド形式 文字列 from文字列 [limit] ::: [置換先 ...]
##
## 説明:
##   先頭3引数は必須。文字列と from は空文字列も許可する。
##   from の各文字を、対応する位置の置換先引数へ置換する。
##   置換先は空文字列・複数文字を許可し、挿入した文字列は再処理しない。
##   置換先の不足は削除、余剰は無視し、from の重複は最初の位置を使う。
##   from が空なら元の文字列をそのまま返す。
##   バインド形式で置換結果と置換回数を取得できる（例: res:cnt:）。
##   置換回数は元の文字への一致回数で、削除も一回として数える。
##
##   ::: は SX_CFG_SEP の値を使い、第4引数、第5引数の順に区切りを探す。
##   区切りより後はすべて置換先とし、区切りがなければ第4引数以降を置換先とする。
##   置換先の先頭付近に SX_CFG_SEP を含める場合は、区切りを明示する。
##   数値に見える置換先も、区切りがなければ limit と解釈しない。
##   limit は符号付き10進整数（先行ゼロなし）。算術域による上限は設けない。
##   limit の省略・空文字列は全置換、0 は無変換、負数は後方から置換する。
##
## 終了ステータス:
##    0  成功
##   64  引数不正
##   77  バインド先が書込不可
##   78  参照する設定値が不正または未設定
sx_str_tr_args() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_tr_args "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_str_tr_args|])

	case "${3+X}" in '') return M_EX_USAGE;; esac
	__sx_var_is_bind "${1}" || return M_EX_USAGE
	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${4+X${4}}") ;;
		"${5+X${5}}") __sx_num_is_int_base 10 ${4:+"${4}"} || return M_EX_USAGE;;
	esac

	__sx_str_tr_args "${@}"
}
