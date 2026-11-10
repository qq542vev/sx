M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_reach - 引数リストを末尾から順に走査してコールバックを実行する（内部用）
##
## 使い方:
##   __sx_arg_reach コールバック [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   末尾の要素から先頭に向かってコールバックを実行する。
##   添字と実際の位置番号を保持し、毎回オフセットを加算せず両方を減らす。
##   コールバック呼び出し前に一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス
##

define([|CLEANUP|], [|Q_i Q_pos Q_type Q_cb|])dnl

__sx_arg_reach() {
	case "${2+X}" in '')
		return M_EX_OK
	esac

	# $1: 添字、$2: 位置番号、$3: 数値経路、$4: コールバック、$5以降: 元の値
	set -- 0 0 0 "${@}"
	Q_cb="${4}"
	Q_pos="${#}"
	shift 4

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_pos}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	set -- "${#}" "${Q_pos}" "${Q_type}" "${Q_cb}" "${@}"

	while
		unset CLEANUP

		eval '"${4}"' "\"\${${2}}\"" '"${1}"' || {
			set -- "${?}"
			unset CLEANUP
			return "${1}"
		}

		case "${1}" in 1)
			return
		esac

		Q_cb="${4}"
		"__sx_num_sub1_${3}" Q_i "${1}"
		"__sx_num_sub1_${3}" Q_pos "${2}"
		eval 'shift 4; set -- ' "${Q_i}" "${Q_pos}" "${3}" '"${Q_cb}"' '"${@}"'
		continue
	do :; done
}

|], [|arg_reach|])dnl
popdef([|CLEANUP|])dnl
