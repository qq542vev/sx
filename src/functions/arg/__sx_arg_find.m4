dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_FIND_CB SX_CFG_SEP __sx_arg_find_cb __sx_arg_find_lit __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_find - 引数リストから指定された値を探す（内部用: ディスパッチャ）
##
## 使い方:
##   __sx_arg_find 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##   __sx_arg_find 結果変数名 [検索対象 [値 ...]]
##
## 説明:
##   ::: セパレータをパースし、フラグに応じて __sx_arg_find_lit または
##   __sx_arg_find_cb にディスパッチする。
##   引数チェックは行わない。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_bind Q_tgt Q_flg|])dnl

__sx_arg_find() {
	Q_bind="${1}"

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}")
			shift 2;;
		"${3+X${3}}")
			Q_tgt="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_tgt="${2}" Q_flg="${3}"
			shift 4
			;;
		*)
			Q_tgt="${2-}"
			shift ${2+'2'}
			;;
	esac

	set -- "${Q_bind-}" "${Q_tgt-}" "${Q_flg:-0}" "${@}"
	unset CLEANUP

	__sx_var_bind_init "${1}"

	case "${1:+${4+X}}" in '')
		return 1
	esac

	case "$((${3} & SX_ARG_FIND_CB))" in
		0) __sx_arg_find_lit "${@}";;
		*) __sx_arg_find_cb "${@}";;
	esac || return
}
|], [|arg_find|])dnl
popdef([|CLEANUP|])dnl
