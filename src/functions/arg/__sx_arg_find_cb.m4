dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_FIND_TEXT SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec __sx_var_bind __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_find_cb - 引数リストからコールバックで値を検索する（内部用）
##
## 使い方:
##   __sx_arg_find_cb 結果変数名 コールバック フラグ [値 ...]
##
## 説明:
##   __sx_arg_find から呼ばれる。コールバックの終了ステータスで一致を判定する。
##   コールバックシグネチャ: callback value index count
##     0 を返すと一致、非0 は不一致としてスキップ。
##   引数は正規化済み。引数チェックは行わない。
##   状態は位置変数で管理し、__sx_var_bind でバインドする。
##   正規化後の引数個数が算術域内なら算術、それ以外は多倍長で添字と一致数を更新する。
##   コールバック呼び出し前に一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_arg Q_bind Q_next|])dnl

__sx_arg_find_cb() {
	# $1: 添字、$2: 一致数、$3: TEXT、$4: 数値経路、$5: バインド、$6: コールバック
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#}"; then
		set -- -7 0 "$(((${3} & SX_ARG_FIND_TEXT) != 0))" arith "${@}"
	else
		set -- -7 0 "$(((${3} & SX_ARG_FIND_TEXT) != 0))" nat0 "${@}"
	fi

	for Q_arg in "${@}"; do
		case "${1}" in
			-*) Q_next=$((${1} + 1));;
			*) "__sx_num_add1_${4}" Q_next "${1}";;
		esac

		set -- "${Q_next}" "${2}" "${3}" "${4}" "${5}" "${6}" "${Q_arg}"

		case "${1}" in -* | 0)
			continue
		esac

		case "${5:+X}" in '')
			break
		esac

		unset CLEANUP

		if "${6}" "${7}" "${1}" "${2}"; then
			case "${3}" in
				0) __sx_var_ubind Q_bind "${5}" "${1}";;
				*) __sx_var_bind Q_bind "${5}" "${7}";;
			esac

			"__sx_num_add1_${4}" Q_next "${2}"
			set -- "${1}" "${Q_next}" "${3}" "${4}" "${Q_bind}" "${6}"
		fi
	done

	unset CLEANUP

	case "${2}" in 0)
		return 1
	esac
}
|], [|arg_find_cb|])dnl
popdef([|CLEANUP|])dnl
