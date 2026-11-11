M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_fold - 引数リストをコールバックで畳み込む（内部用）
##
## 使い方:
##   __sx_arg_fold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   sx_arg_fold の内部実装。引数チェックは行わない。
##   状態は位置変数で管理し、for ループでイテレートする。
##   呼び出し時の引数個数が算術域内なら算術、それ以外は多倍長で添字を更新する。
##   管理用の5項目は負のカウンタを算術で進めてスキップする。
##   コールバック呼び出し前に一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス
##

define([|CLEANUP|], [|Q_res Q_cb Q_ret Q_arg Q_next Q_type|])dnl

__sx_arg_fold() {
	case "${4+X}" in '')
		M_VAR_SET([|${1}|], [|${3-}|])
		return
	esac

	Q_res="${1}"
	Q_cb="${2}"
	Q_ret="${3}"
	shift 3

	# $1: 添字、$2: 数値経路、$3: 結果変数、$4: コールバック、$5: アキュムレータ
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	for Q_arg in "${@}"; do
		case "${Q_type-}" in
			'')
				"__sx_num_add1_${2}" Q_next "${1}"
				set -- "${Q_next}" "${2}" "${3}" "${4}" "${Q_ret-${5}}" "${Q_arg}"
				;;
			*) set -- 1 "${Q_type}" "${Q_res}" "${Q_cb}" "${Q_ret}" "${Q_arg}"
		esac

		unset CLEANUP

		"${4}" Q_ret "${5}" "${6}" "${1}" || {
			set -- "${?}" "${3}" "${5}"
			unset CLEANUP
			M_VAR_SET([|${2}|], [|${3}|])
			return "${1}"
		}
	done

	set -- "${3}" "${Q_ret-${5}}"
	unset CLEANUP
	M_VAR_SET([|${1}|], [|${2}|])
}
|], [|arg_fold|])dnl
popdef([|CLEANUP|])dnl
