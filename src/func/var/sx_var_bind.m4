M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_bind __sx_var_is_bind __sx_var_is_bind_ready __sx_var_is_bindable __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_bind - バインド状態に従って値を割り当てる
##
## 使い方:
##   sx_var_bind 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   バインド形式（a:b:c 等）を解析し、値を適切な変数に割り当てる。
##   割り当て後、残りのバインド形式が結果変数に格納される。
##   結果変数名に空文字列を指定した場合は、残りのバインド形式を書き込まずに破棄する。
##   複数の値を一度に割り当てることができ、各値はバインド形式の
##   セグメントに対して順次処理される。バインド先が枯渇し、未処理の
##   値が残る場合は終了ステータス 1 を返し、結果変数が空でない場合に限り
##   残りのバインド形式（枯渇時は空文字列）が書き込まれる。
##   蓄積スロット（数値プレフィックス付き・最後の変数）へ値を蓄積する際は
##   値をクォートする。クォートせずに蓄積したい場合は sx_var_ubind を
##   使用する。代入スロット（名前:残り）への代入は値のクォートを行わない。
##   蓄積スロットは、既存値が空文字列の場合（bind 未到達を含む）は
##   セパレータを付加せず蓄積する。
##   @name / N@name 形式の要素は sx 配列への分配先となる。配列要素への
##   代入時は値をクォートしない（sx_var_ubind と同一）。
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
sx_var_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_bind "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_var_bind|])

	# 結果変数名自体の妥当性と書き込み権限をチェック

	case "${1:+X}" in X)
		__sx_var_is_name "${1-}" || return M_EX_USAGE

		__sx_var_is_rw "${1}" || return M_EX_NOPERM
	esac

	__sx_var_is_bind "${2-}" || return M_EX_USAGE

	__sx_var_is_bindable "${2-}" || return M_EX_NOPERM

	__sx_var_is_bind_ready "${2-}" || return M_EX_DATAERR

	__sx_var_bind "${@}" || return
}

popdef([|CLEANUP|])dnl
