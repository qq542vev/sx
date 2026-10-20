dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SEP __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_enough - 引数リストから callback の条件を満たす要素が指定数以上あるか確認する（内部用）
##
## 使い方:
##   __sx_arg_enough [cb [need]] [:::] [arg ...]
##
## 説明:
##   sx_arg_enough の内部実装。引数チェックは行わない。
##   SX_CFG_SEP を $1/$2/$3 のいずれかから検出し、cb・need を抽出した上で
##   添字・残件数・必要件数・数値経路・コールバックを位置変数で管理する。
##   残件数と必要件数が算術域内なら算術、それ以外は多倍長で更新・比較する。
##   コールバック呼び出し前には一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  条件を満たす要素が必要数以上存在する (SX_EX_OK)
##    1  条件を満たす要素が必要数未満
##

define([|CLEANUP|], [|Q_arg Q_cb Q_need Q_left Q_type Q_next|])dnl

__sx_arg_enough() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			Q_cb="${1}"
			shift 2
			;;
		"${3+X${3}}")
			Q_cb="${1}" Q_need="${2}"
			shift 3
			;;
		*)
			Q_cb="${1-}"
			${1+'shift'}
			;;
	esac

	Q_left="${#}"
	Q_need="${Q_need:-${#}}"

	case "${Q_need}" in 0)
		unset CLEANUP
		return
	esac

	case "${Q_left}" in 0)
		unset CLEANUP
		return 1
	esac

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_left}" "${Q_need}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	# $1: 添字、$2: 残件数、$3: 必要件数、$4: 数値経路、$5: コールバック
	set -- -5 "${Q_left}" "${Q_need}" "${Q_type}" "${Q_cb-}" "${@}"

	for Q_arg in "${@}"; do
		case "${1}" in
			-*) Q_next=$((${1} + 1));;
			*) "__sx_num_add1_${4}" Q_next "${1}";;
		esac

		set -- "${Q_next}" "${2}" "${3}" "${4}" "${5}" "${Q_arg}"

		case "${1}" in -* | 0)
			continue
		esac

		unset CLEANUP

		# 短絡評価: 残りの全要素が成功しても必要数に達しない
		"__sx_num_cmp_${4}" "${2}" "${3}" || case "${?}" in 1)
			return 1
		esac

		if "${5}" "${6}" "${1}"; then
			"__sx_num_sub1_${4}" Q_need "${3}"
			set -- "${1}" "${2}" "${Q_need}" "${4}" "${5}"
		fi

		# 短絡評価: 必要数に達した
		case "${3}" in 0)
			unset CLEANUP
			return
		esac

		"__sx_num_sub1_${4}" Q_left "${2}"
		set -- "${1}" "${Q_left}" "${3}" "${4}" "${5}"
	done

	unset CLEANUP
	return 1
}
|], [|arg_enough|])dnl
popdef([|CLEANUP|])dnl
