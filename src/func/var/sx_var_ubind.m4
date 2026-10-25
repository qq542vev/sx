M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_bind __sx_var_is_bind_ready __sx_var_is_bindable __sx_var_is_name __sx_var_is_rw __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_ubind - バインド状態に従って値を割り当てる（クォートなし）
##
## 使い方:
##   sx_var_ubind 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_var_bind と同様に複数の値をバインド形式に従って割り当てる。
##   蓄積スロット（数値プレフィックス付き・最後の変数）への蓄積時に
##   値のクォートを行わない点のみが sx_var_bind と異なる。
##   代入スロット（名前:残り）への代入は sx_var_bind と同様に生の値となる。
##   結果変数名に空文字列を指定した場合は、残りのバインド形式を書き込まずに破棄する。
##   バインド先が枯渇し、未処理の値が残る場合は終了ステータス 1 を返し、
##   結果変数が空でない場合に限り残りのバインド形式（空文字列）が書き込まれる。
##   @name / N@name 形式の要素は sx 配列への分配先となる。
##   バインド形式は事前に sx_var_bind_init で初期化されている必要がある。
##   未初期化の状態で呼び出すと終了ステータス 65 を返す。
##   詳細は sx_var_is_bind_ready を参照。
##
## 終了ステータス:
##    0  割り当て成功 (SX_EX_OK)
##    1  バインド先がもうない（データがバインド先より多い）。結果変数が空でない場合に限り空文字列が書き込まれる
##   64  引数不正 (SX_EX_USAGE)
##   65  バインド先が割当て可能な状態にない (SX_EX_DATAERR)
##   77  結果変数名（空でない場合）またはバインド先が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_var_ubind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_ubind "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_var_ubind|])

	# 結果変数名自体の妥当性と書き込み権限をチェック

	case "${1:+X}" in X)
		__sx_var_is_name "${1-}" || return M_EX_USAGE

		__sx_var_is_rw "${1}" || return M_EX_NOPERM
	esac

	__sx_var_is_bind "${2-}" || return M_EX_USAGE

	__sx_var_is_bindable "${2-}" || return M_EX_NOPERM

	__sx_var_is_bind_ready "${2-}" || return M_EX_DATAERR

	__sx_var_ubind "${@}" || return
}

popdef([|CLEANUP|])dnl
