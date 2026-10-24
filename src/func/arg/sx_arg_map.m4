M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arg_map __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_map - 引数リストの各要素にコールバック関数を適用する
##
## 使い方:
##   sx_arg_map 結果変数名（またはバインド形式） コールバック [値 ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を適用し、
##   その結果をバインド形式に従って結果変数に格納する。
##   第一引数は必須（空文字列可）。空 bind ではコールバックを呼ばず成功する。
##
##   コールバック関数のシグネチャ:
##     callback 結果変数名 現在の値 インデックス
##
##   コールバックの戻り値と動作:
##     - 成功 (0) + 結果変数に値を設定 => その値を変換後の要素としてバインド
##     - 成功 (0) + 結果変数が unset のまま => その要素をスキップ
##     - 失敗 (非0) => 元の値をそのままバインド、終了ステータスに反映
##   最初のエラー以降の要素も元の値をバインドする。
##   引数個数とインデックスに SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##   すべてのコールバックが成功 => 0 (SX_EX_OK)
##   一部のコールバックが失敗 => 最初の失敗のステータス
##   64 => 引数不正 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78 => SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_map() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_map "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_arg_map "${@}" || return
}

popdef([|CLEANUP|])dnl
