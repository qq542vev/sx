dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_isep __sx_num_is_int_base __sx_num_is_nat0_base __sx_num_is_nat0_safe __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arg_isep - 引数間にセパレータを挿入し、すべてをクォートして結合する
##
## 使い方:
##   sx_arg_isep bind [sep [inv [limit [flg]]]] ::: [arg ...]
##   sx_arg_isep bind [sep [arg ...]]
##
## 説明:
##   引数グループの間にセパレータを挿入し、すべての要素（セパレータを含む）を
##   シングルクォートで囲んでスペース区切りで結合し、結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   インターバルが正の場合は先頭から、負の場合は末尾から数えて挿入する。
##   リミットを指定すると、セパレータの挿入回数を制限できる。
##   インターバルに 0 は指定できない。
##   インターバルは符号付き、リミットは符号なしの10進整数（先行ゼロなし）とする。
##   インターバルの省略時・空指定時は1、リミットの省略時・空指定時は回数制限なし。
##   引数個数・インターバル・リミット・各カウンタに SX_CFG_NUM_RANGE による上限は設けない。
##   フラグには引き続き SX_CFG_NUM_RANGE による範囲検証を適用する。
##
##   コールバック契約: callback 結果変数名 slot count skip
##     slot は左端を0とした境界番号、count は1開始の呼び出し回数、
##     skip はそれまでに結果変数が未設定だった回数。
##   結果変数を未設定にすると挿入を省略するが、リミットは消費する。
##   非0を返した回の結果は破棄し、以後の挿入を停止して元の値を保持する。
##   正方向では逐次バインドし、負方向では右からコールバックを実行後、左からバインドする。
##   コールバックの非0終了ステータスはそのまま返す。
##   コールバックは途中の処理を別変数で行い、末尾で結果変数に単純代入する。
##   結果変数を他の関数の結果変数・バインド先として渡してはならない。
##
##   2 つの呼び出し形式がある:
##     1) ::: 形式: bind/sep/inv/limit/flg を ::: より前の位置引数で指定し、
##        ::: 以降をデータとして扱う。設定引数とデータを明確に分離できる。
##     2) 簡略形式: 第一引数が bind、第二引数が sep、第三引数以降がデータ
##        として扱われる。インターバルは 1、リミットは無制限、フラグは 0 とする。
##   bind は必須（空文字列可）。sep の省略時は空文字列とする。
##   ::: は SX_CFG_SEP の値を使用する。データ先頭付近にその値を含む場合は、
##   ::: 形式で境界を明示する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_int Q_lim Q_flg|])dnl

sx_arg_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_isep "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}") Q_int="${3}";;
		"${5+X${5}}") Q_int="${3}" Q_lim="${4}";;
		"${6+X${6}}") Q_int="${3}" Q_lim="${4}" Q_flg="${5}";;
	esac

	if ! __sx_num_is_int_base 10 ${Q_int:+"${Q_int}"} ||
		! __sx_num_is_nat0_base 10 ${Q_lim:+"${Q_lim}"} ||
		! __sx_num_is_nat0_safe ${Q_flg:+"${Q_flg}"}; then
		unset CLEANUP
		return M_EX_USAGE
	fi

	case ${Q_int:+"${Q_int#[+-]}"} in 0)
		unset CLEANUP
		return M_EX_USAGE
	esac

	unset CLEANUP

	__sx_arg_isep "${@}" || return
}
|], [|arg_isep|])dnl
popdef([|CLEANUP|])dnl
