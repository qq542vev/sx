dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_arith __sx_num_sub_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_rfold - 引数リストを右からコールバックで畳み込む（内部用）
##
## 使い方:
##   __sx_arg_rfold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   sx_arg_rfold の内部実装。引数チェックは行わない。
##   状態は位置変数で管理し、eval で後方から間接参照する。
##   添字と実際の位置番号を保持し、毎回オフセットを加算せず両方を減らす。
##   最大の位置番号が算術域内なら算術、それ以外は多倍長で更新する。
##   コールバック呼び出し前には一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  最初に失敗したコールバックの終了ステータス
##

define([|CLEANUP|], [|Q_ret Q_cb Q_i Q_pos Q_type|])dnl

__sx_arg_rfold() {
	case "${4+X}" in '')
		M_VAR_SET([|${1}|], [|${3-}|])
		return
	esac

	# 管理用の6項目を含む最大の位置番号を、算術を使わずに取得する。
	set -- 0 0 0 "${@}"
	Q_pos="${#}"
	shift 3

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_pos}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	"__sx_num_sub_${Q_type}" Q_i "${Q_pos}" 6

	# $1: 添字、$2: 位置番号、$3: 数値経路、$4: 結果変数、$5: コールバック、$6: アキュムレータ
	set -- "${Q_i}" "${Q_pos}" "${Q_type}" "${@}"

	while M_STR_NE([|"${1}"|], [|0|]); do
		unset CLEANUP

		eval '"${5}"' Q_ret '"${6}"' "\"\${${2}}\"" "${1}" || {
			set -- "${?}" "${4}" "${6}"
			unset CLEANUP
			M_VAR_SET([|${2}|], [|${3}|])
			return "${1}"
		}

		Q_cb="${5}"
		Q_ret="${Q_ret-${6}}"
		"__sx_num_sub1_${3}" Q_i "${1}"
		"__sx_num_sub1_${3}" Q_pos "${2}"

		eval 'shift 6;' set -- "${Q_i}" "${Q_pos}" "${3}" "${4}" '"${Q_cb}"' '"${Q_ret}"' '"${@}"'
	done

	unset CLEANUP
	M_VAR_SET([|${4}|], [|${6}|])
}
|], [|arg_rfold|])dnl
popdef([|CLEANUP|])dnl
