dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arg_rfold __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_rfold - 引数リストを右からコールバックで畳み込む（rfold）
##
## 使い方:
##   sx_arg_rfold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   sx_arg_fold と同様に畳み込みを行うが、右端の要素から処理を開始する。
##   コールバック契約: callback ret_var acc current_value index
##     - ret_var: 新しいアキュムレータ値を格納する変数名
##     - acc: 現在のアキュムレータ値
##     - current_value: 現在処理中の要素の値
##     - index: 元の引数リストにおける 1-based インデックス
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
##   78 => SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_rfold() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rfold "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_arg_rfold "${@}" || return
}

popdef([|CLEANUP|])dnl
