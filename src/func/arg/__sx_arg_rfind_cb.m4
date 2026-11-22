M_REQUIRE([|SX_CFG_NUM_RANGE __sx_arg_find_emit4 __sx_arg_find_emit16 __sx_arg_find_emit20 __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_rfind_cb - 引数リストから指定された値をコールバックで検索する（内部用）
##
## 使い方:
##   __sx_arg_rfind_cb 結果変数名 コールバック フラグ [値 ...]
##
## 説明:
##    __sx_arg_rfind から呼ばれる。末尾から先頭に向かって検索し、
##    コールバックの終了ステータスで一致を判定する。
##    コールバックシグネチャ: callback value index count
##      0 を返すと一致、非0 は不一致としてスキップ。
##    引数は正規化済み。引数チェックは行わない。
##    状態は位置変数で管理し、形式別 emit 関数でバインドする。
##    添字と実際の位置番号を保持し、毎回オフセットを加算せず両方を減らす。
##    出力形式は POS|TEXT で指定し、未指定なら POS を既定とする。
##    形式別 emit 関数はループ前に選択し、ループ内では形式を検査しない。
##    NOT フラグ指定時は、コールバックが非0を返した要素を対象にする。
##    最大の位置番号が算術域内なら算術、それ以外は多倍長で添字・位置番号・一致数を更新する。
##    コールバック呼び出し前には一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_bind Q_cb Q_fmt Q_fn Q_not Q_i Q_pos Q_cnt Q_type Q_val|])dnl

__sx_arg_rfind_cb() {
	Q_bind="${1}"
	Q_cb="${2}"
	Q_fmt=$((${3} & (M_ARG_RFIND_POS | M_ARG_RFIND_TEXT)))

	case "${Q_fmt}" in 0)
		Q_fmt=M_ARG_RFIND_POS
	esac

	case "$((${3} & M_ARG_RFIND_NOT))" in
		0) Q_not=;;
		*) Q_not='! ';;
	esac

	# 管理用の8項目を含む最大の位置番号を、算術を使わずに取得する。
	set -- 0 0 0 0 0 "${@}"
	Q_pos="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_pos}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	shift 8

	# $1: 添字、$2: 位置番号、$3: 一致数、$4: バインド、$5: 数値経路、$6: コールバック、$7: 形式別 emit 関数、$8: NOT
	set -- "${#}" "${Q_pos}" 0 "${Q_bind}" "${Q_type}" "${Q_cb}" "__sx_arg_find_emit${Q_fmt}" "${Q_not}" "${@}"

	while
		unset CLEANUP

		if eval "${8}"'"${6}"' "\"\${${2}}\"" "${1}" "${3}"; then
			eval "Q_val=\"\${${2}}\""
			"${7}" Q_bind "${4}" "${1}" "${Q_val}"

			case "${Q_bind:+${1}}" in '' | 1)
				unset CLEANUP
				return
			esac

			"__sx_num_add1_${5}" Q_cnt "${3}"
		elif M_STR_NE([|"${1}"|], [|1|]); then
			Q_bind="${4}" Q_cnt="${3}"
		else
			break
		fi

		"__sx_num_sub1_${5}" Q_i "${1}"
		"__sx_num_sub1_${5}" Q_pos "${2}"
		shift 4
		set -- "${Q_i}" "${Q_pos}" "${Q_cnt}" "${Q_bind}" "${@}"
		continue
	do :; done

	unset CLEANUP

	case "${3}" in 0)
		return 1
	esac
}
|], [|arg_rfind_cb|])dnl
popdef([|CLEANUP|])dnl
