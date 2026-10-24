M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_copy_script __sx_var_is_rw sx_var_is_chain sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_copy_script - 変数のコピー用スクリプトを生成する
##
## 使い方:
##   sx_var_copy_script 結果変数名 [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   与えられた連鎖式群に対するコピー処理で必要となる、
##   実行可能なコピースクリプトを生成して結果変数に格納する。
##   連鎖ごとにコピー先の削除（__sx_var_unset）に続けて、
##   コピー元の現在値を取得した代入式（dest='値'）または削除式（unset -v dest）を
##   SX_STR_LF 区切りで並べる。コピー元が sx 配列である場合は、
##   関連するすべての要素も含めて展開する。
##   生成されたスクリプトは eval で実行できる。
##   連鎖式が指定されない場合や引数が単一の変数名の場合は、空文字列を格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_copy_script() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_copy_script "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_rw "${1}" || return M_EX_NOPERM
	sx_var_is_chain "${@}" || return M_EX_USAGE

	__sx_var_copy_script "${@}"
}

popdef([|CLEANUP|])dnl
