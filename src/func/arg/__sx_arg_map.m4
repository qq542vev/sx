M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_map - 引数リストの各要素にコールバック関数を適用する（内部用）
##
## 使い方:
##   __sx_arg_map 結果変数名（またはバインド形式） コールバック [値 ...]
##
## 説明:
##   sx_arg_map の内部実装。引数チェックは行わない。
##   添字、数値経路、残りのバインド、コールバック、現在値を位置パラメータで管理し、
##   for ループで入力を巡回する。最初のコールバック失敗ステータスは Q_sts に保持する。
##   呼び出し時の引数個数が算術域内なら算術、それ以外は多倍長で添字を更新する。
##   コールバック呼び出し前に局所変数を解放し、再入時も位置パラメータの走査状態を保持する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス
##

define([|CLEANUP|], [|Q_bind Q_cb Q_type Q_arg Q_next Q_ret Q_sts|])dnl

__sx_arg_map() {
	__sx_var_bind_init "${1}"

	case "${1:+${3+X}}" in '')
		return
	esac

	Q_bind="${1}"
	Q_cb="${2}"
	shift 2

	# $1: 添字、$2: 数値経路、$3: 残りのバインド、$4: コールバック、$5: 現在の値
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	for Q_arg in "${@}"; do
		case "${Q_type-}" in
			'')
				"__sx_num_add1_${2}" Q_next "${1}"
				set -- "${Q_next}" "${2}" "${Q_bind-${3}}" "${4}" "${Q_arg}"
				;;
			*) set -- 1 "${Q_type}" "${Q_bind}" "${Q_cb}" "${Q_arg}"
		esac

		case "${Q_sts-}" in
			'')
				unset CLEANUP

				"${4}" Q_ret "${5}" "${1}" || {
					Q_sts="${?}"
					Q_ret="${5}"
				}
				;;
			*) Q_ret="${5}";;
		esac

		case "${Q_ret+X}" in X)
			__sx_var_ubind Q_bind "${3}" "${Q_ret}"

			case "${Q_bind:+X}" in '')
				break
			esac
		esac
	done

	set -- "${Q_sts-0}"
	unset CLEANUP
	return "${1}"
}
|], [|arg_map|])dnl
popdef([|CLEANUP|])dnl
