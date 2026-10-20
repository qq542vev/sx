dnl 定義と依存宣言はこのファイルで管理する。
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
##   状態は位置変数で管理し、for ループでイテレートする。
##   呼び出し時の引数個数が算術域内なら算術、それ以外は多倍長で添字を更新する。
##   管理用の5項目は負のカウンタを算術で進めてスキップする。
##   コールバック呼び出し前に一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス
##

define([|CLEANUP|], [|Q_arg Q_next Q_ret Q_sts Q_fmt|])dnl

__sx_arg_map() {
	__sx_var_bind_init "${1}"

	case "${1:+${3+X}}" in '')
		return
	esac

	# $1: 終了状態、$2: 添字、$3: 数値経路、$4: バインド、$5: コールバック
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#}"; then
		set -- 0 -5 arith "${@}"
	else
		set -- 0 -5 nat0 "${@}"
	fi

	for Q_arg in "${@}"; do
		case "${2}" in
			-*) Q_next=$((${2} + 1));;
			*) "__sx_num_add1_${3}" Q_next "${2}";;
		esac

		set -- "${1}" "${Q_next}" "${3}" "${4}" "${5}" "${Q_arg}"

		case "${2}" in -* | 0)
			continue
		esac

		case "${4:+X}" in '')
			break
		esac

		case "${1}" in
			0)
				unset CLEANUP

				"${5}" Q_ret "${6}" "${2}" || {
					Q_sts="${?}"
					Q_ret="${6}"
				}
				;;
			*) Q_ret="${6}";;
		esac

		case "${Q_ret+X}" in X)
			__sx_var_ubind Q_fmt "${4}" "${Q_ret}"

			set -- "${Q_sts-${1}}" "${2}" "${3}" "${Q_fmt}" "${5}"
		esac

		unset Q_ret Q_fmt Q_sts
	done

	unset CLEANUP
	return "${1}"
}
|], [|arg_map|])dnl
popdef([|CLEANUP|])dnl
