M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arg_fold __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_fold - 引数リストをコールバックで畳み込む（fold）
##
## 使い方:
##   sx_arg_fold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を適用し、
##   アキュムレータを更新しながら畳み込みを行う。
##   コールバック契約: callback ret_var acc current_value index
##     - ret_var: 新しいアキュムレータ値を格納する変数名
##     - acc: 現在のアキュムレータ値
##     - current_value: 現在処理中の要素の値
##     - index: 1-based インデックス
##   コールバックが ret_var を unset した場合、アキュムレータは変更されない。
##   コールバックが非0を返した場合、その時点のアキュムレータ値を結果変数に格納し、
##   直ちに終了する。
##   引数個数とインデックスに SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##   すべてのコールバックが成功 => 0 (SX_EX_OK)
##   コールバックが失敗 => 最初のエラーのステータス
##   64 => 引数不正 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arg_fold() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_fold "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arg_fold|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_arg_fold "${@}" || return
}

popdef([|CLEANUP|])dnl
