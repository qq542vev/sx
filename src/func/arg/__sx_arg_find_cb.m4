M_REQUIRE([|SX_CFG_NUM_RANGE __sx_arg_find_emit4 __sx_arg_find_emit16 __sx_arg_find_emit20 __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec|])dnl
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
##   走査状態は $1: 添字、$2: 一致数、$3: 数値経路、$4: バインド、
##   $5: コールバック、$6: 形式別 emit 関数、$7: NOT、$8: 現在の値の順で
##   位置変数に管理する。
##   出力形式は POS|TEXT で指定し、未指定なら POS を既定とする。
##   形式別 emit 関数はループ前に選択し、ループ内では形式を検査しない。
##   NOT フラグ指定時は、コールバックが非0を返した要素を対象にする。
##   正規化後の引数個数が算術域内なら算術、それ以外は多倍長で添字と一致数を更新する。
##   コールバック呼び出し前に一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_bind Q_cb Q_fmt Q_fn Q_not Q_type Q_arg Q_next|])dnl

__sx_arg_find_cb() {
	Q_bind="${1}"
	Q_cb="${2}"
	Q_fmt=$((${3} & (M_ARG_FIND_POS | M_ARG_FIND_TEXT)))
	Q_not=$((${3} & M_ARG_FIND_NOT))
	shift 3

	case "${Q_fmt}" in 0)
		Q_fmt=M_ARG_FIND_POS
	esac

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	for Q_arg in "${@}"; do
		case "${Q_type-}" in
			'')
				"__sx_num_add1_${3}" Q_next "${1}"
				set -- "${Q_next}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${Q_arg}"
				;;
			*) set -- 1 0 "${Q_type}" "${Q_bind}" "${Q_cb}" "${Q_fmt}" "${Q_not}" "${Q_arg}";;
		esac

		unset CLEANUP

		case "${7}" in
			0) "${5}" "${8}" "${1}" "${2}";;
			*) ! "${5}" "${8}" "${1}" "${2}";;
		esac || continue

		"__sx_arg_find_emit${6}" Q_bind "${4}" "${1}" "${8}"

		case "${Q_bind}" in '')
			unset CLEANUP
			return
		esac

		"__sx_num_add1_${3}" Q_next "${2}"
		set -- "${1}" "${Q_next}" "${3}" "${Q_bind}" "${5}" "${6}" "${7}"
	done

	unset CLEANUP

	case "${2}" in 0)
		return 1
	esac
}
|], [|arg_find_cb|])dnl
popdef([|CLEANUP|])dnl
