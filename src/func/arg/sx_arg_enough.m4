M_REQUIRE([|SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_enough __sx_num_is_nat0_base|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_enough - 引数リストから callback の条件を満たす要素が指定数以上あるか確認する
##
## 使い方:
##   sx_arg_enough [cb [need]] ::: [arg ...]
##   sx_arg_enough [cb] [arg ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を適用し、
##   成功（終了ステータス 0）となった要素の数が指定された個数以上であれば
##   0、そうでなければ 1 を返す。
##
##   第1形式（::: 形式）:
##     [cb [need]] ::: [arg ...]
##     ::: で metadata とデータを分離する。
##     need を省略すると data の個数がデフォルト値となる。
##     need に 0 を指定すると常に成功する（callback は呼ばれない）。
##     need は符号なし10進整数を受け付ける（0以外は先頭の0を認めない）。
##
##   第2形式（短縮形式）:
##     [cb] [arg ...]
##     ::: を使用せず、第1引数が cb、第2引数以降が data となる。
##     need は常に data の個数（明示指定不可）。
##
##   コールバック関数のシグネチャ:
##     callback 値 インデックス
##   コールバックが 0 を返すと、その要素は条件を満たしたとカウントされる。
##
##   短絡評価:
##   - 条件を満たす要素が必要数に達した時点で即座に 0 を返す
##   - 残りの要素すべてが条件を満たしても必要数に達しないことが確定した時点で即座に 1 を返す
##   引数個数・インデックス・必要件数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  条件を満たす要素が必要数以上存在する (SX_EX_OK)
##    1  条件を満たす要素が必要数未満
##   64  引数不正 (SX_EX_USAGE)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arg_enough() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_enough "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_arg_enough|])

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}") ;;
		"${3+X${3}}") __sx_num_is_nat0_base 10 "${2}" || return M_EX_USAGE;;
	esac

	__sx_arg_enough "${@}" || return
}

popdef([|CLEANUP|])dnl
