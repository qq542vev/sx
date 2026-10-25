M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arg_each|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_each - 引数リストの各要素に対してコールバック関数を実行する
##
## 使い方:
##   sx_arg_each コールバック [値 ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を実行する。
##   戻り値は収集せず、副作用のみを目的とする。
##   引数個数とインデックスに SX_CFG_NUM_RANGE による上限は設けない。
##
##   コールバック関数のシグネチャ:
##     callback 値 インデックス
##
##   コールバックの戻り値と動作:
##     - 成功 (0) => 次の要素に進む
##     - 失敗 (非0) => その時点で中断し、そのステータスを返す
##
## 終了ステータス:
##   すべてのコールバックが成功 => 0 (SX_EX_OK)
##   コールバックが失敗 => 最初の失敗のステータス
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arg_each() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_each "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_arg_each|])

	__sx_arg_each "${@}" || return
}

popdef([|CLEANUP|])dnl
