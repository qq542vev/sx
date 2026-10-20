dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_RFIND_TEXT SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_var_bind __sx_var_ubind|])dnl
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
##    状態は位置変数で管理し、__sx_var_bind でバインドする。
##    添字と実際の位置番号を保持し、毎回オフセットを加算せず両方を減らす。
##    最大の位置番号が算術域内なら算術、それ以外は多倍長で添字・位置番号・一致数を更新する。
##    コールバック呼び出し前には一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_bind Q_cb Q_text Q_i Q_pos Q_cnt Q_type|])dnl

__sx_arg_rfind_cb() {
	Q_bind="${1}" Q_cb="${2}"
	Q_text=$(((${3} & SX_ARG_RFIND_TEXT) != 0))

	# 管理用の7項目を含む最大の位置番号を、算術を使わずに取得する。
	set -- 0 0 0 0 "${@}"
	Q_pos="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_pos}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	shift 7
	Q_i="${#}"

	# $1: 添字、$2: 位置番号、$3: 一致数、$4: 数値経路、$5: バインド、$6: コールバック、$7: TEXT
	set -- "${Q_i}" "${Q_pos}" 0 "${Q_type}" "${Q_bind}" "${Q_cb}" "${Q_text}" "${@}"

	while M_STR_NE([|"${1}"|], [|0|]) && M_STR_NE([|"${5}"|], [|''|]); do
		unset CLEANUP

		if eval '"${6}"' "\"\${${2}}\"" "${1}" "${3}"; then
			case "${7}" in
				0) __sx_var_ubind Q_bind "${5}" "${1}";;
				*) eval __sx_var_bind Q_bind '"${5}"' "\"\${${2}}\"";;
			esac

			"__sx_num_add1_${4}" Q_cnt "${3}"
		else
			Q_bind="${5}" Q_cnt="${3}"
		fi

		"__sx_num_sub1_${4}" Q_i "${1}"
		"__sx_num_sub1_${4}" Q_pos "${2}"
		eval 'shift 5;' set -- "${Q_i}" "${Q_pos}" "${Q_cnt}" "${4}" '"${Q_bind}"' '"${@}"'
	done

	unset CLEANUP

	case "${3}" in 0)
		return 1
	esac
}
|], [|arg_rfind_cb|])dnl
popdef([|CLEANUP|])dnl
