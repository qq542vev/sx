M_REQUIRE([|SX_ARG_ISEP_CB SX_ARG_ISEP_POST SX_ARG_ISEP_PRE SX_CFG_NUM_RANGE SX_CFG_SEP SX_SYS_NUM_MAX __sx_arg_isep_cb __sx_arg_isep_lit __sx_arg_isep_rcb __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_divmod_arith __sx_num_divmod_nat0 __sx_num_is_int_fit_dec __sx_num_mul_arith __sx_num_mul_nat0 __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_arith __sx_num_sub_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_isep - 引数間にセパレータを挿入する（ディスパッチャ、内部用）
##
## 使い方:
##   __sx_arg_isep bind [sep [inv [limit [flg]]]] ::: [arg ...]
##   __sx_arg_isep bind [sep [arg ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   引数を分離し、走査方向で最初の境界と実際に処理する境界数を求める。
##   元の個数・間隔・上限が算術域内で、個数+1も収まる場合だけ算術経路を使う。
##   境界数は最大で個数+1。上限を適用してから位置を求め、余分な加減算を避ける。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  コールバックの終了ステータス

define([|CLEANUP|], [|Q_bind Q_sep Q_int Q_lim Q_flg Q_abs Q_size Q_type Q_dir Q_start Q_end Q_count Q_rem Q_pos Q_tmp|])dnl

__sx_arg_isep() {
	Q_bind="${1}"

	# ::: の位置を特定 (Bounded Search: $2, $3, $4, $5, $6)
	case "X${SX_CFG_SEP}" in
		"${2+X${2}}") shift 2;;
		"${3+X${3}}")
			Q_sep="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_sep="${2}" Q_int="${3}"
			shift 4
			;;
		"${5+X${5}}")
			Q_sep="${2}" Q_int="${3}" Q_lim="${4}"
			shift 5
			;;
		"${6+X${6}}")
			Q_sep="${2}" Q_int="${3}" Q_lim="${4}" Q_flg="${5}"
			shift 6
			;;
		*)
			Q_sep="${2-}"
			shift ${2+'2'}
			;;
	esac

	__sx_var_bind_init "${Q_bind}"

	case "${Q_bind:+X}:${Q_lim-}" in :* | *:0)
		__sx_var_bind '' "${Q_bind}" "${@}" || :
		unset CLEANUP
		return
	esac

	: "${Q_int:=1}" "${Q_flg:=0}"
	Q_abs="${Q_int#[+-]}" Q_size="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_size}" "${Q_abs}" ${Q_lim:+"${Q_lim}"} &&
		M_STR_NE([|"${Q_size}"|], [|"${SX_SYS_NUM_MAX}"|]); then
		Q_type=arith
	else
		Q_type=nat0
	fi

	case "${Q_int}" in
		-*) Q_dir=1 Q_start=$(((Q_flg & SX_ARG_ISEP_POST) != 0)) Q_end=$(((Q_flg & SX_ARG_ISEP_PRE) != 0));;
		*) Q_dir=0 Q_start=$(((Q_flg & SX_ARG_ISEP_PRE) != 0)) Q_end=$(((Q_flg & SX_ARG_ISEP_POST) != 0));;
	esac

	# 商から内部境界数を求める。反対側の端は、空でなく余り0の場合だけ有効。
	"__sx_num_divmod_${Q_type}" Q_count:Q_rem: "${Q_size}" "${Q_abs}"
	case "${Q_size}:${Q_rem}" in
		0:*) Q_end=0;;
		*:0) "__sx_num_sub1_${Q_type}" Q_count "${Q_count}";;
		*) Q_end=0;;
	esac
	case "${Q_start}" in 1) "__sx_num_add1_${Q_type}" Q_count "${Q_count}";; esac
	case "${Q_end}" in 1) "__sx_num_add1_${Q_type}" Q_count "${Q_count}";; esac

	case "${Q_lim:+X}" in X)
		"__sx_num_cmp_${Q_type}" "${Q_count}" "${Q_lim}" || case "${?}" in
			3) Q_count="${Q_lim}";;
		esac
	esac

	case "${Q_count}" in 0)
		__sx_var_bind '' "${Q_bind}" "${@}" || :
		unset CLEANUP
		return
	esac

	case "${Q_dir}${Q_start}" in
		00) Q_pos="${Q_abs}";;
		01) Q_pos=0;;
		10) "__sx_num_sub_${Q_type}" Q_pos "${Q_size}" "${Q_abs}";;
		11) Q_pos="${Q_size}";;
	esac

	case "$((Q_flg & SX_ARG_ISEP_CB))" in
		0)
			# リテラルは左から直接バインドするため、選択された最左の境界に換算する。
			case "${Q_dir}" in 1)
				"__sx_num_sub1_${Q_type}" Q_tmp "${Q_count}"
				"__sx_num_mul_${Q_type}" Q_tmp "${Q_tmp}" "${Q_abs}"
				"__sx_num_sub_${Q_type}" Q_pos "${Q_pos}" "${Q_tmp}"
			esac
			set -- "${Q_bind}" "${Q_sep-}" "${Q_abs}" "${Q_type}" "${Q_pos}" "${Q_count}" 0 "${@}"
			unset CLEANUP
			__sx_arg_isep_lit "${@}"
			;;
		*)
			set -- "${Q_dir}" "${Q_bind}" "${Q_sep-}" "${Q_abs}" "${Q_type}" "${Q_pos}" "${Q_count}" "${Q_size}" "${@}"
			unset CLEANUP
			case "${1}" in
				0) shift; __sx_arg_isep_cb "${@}";;
				1) shift; __sx_arg_isep_rcb "${@}";;
			esac
			;;
	esac || return
}
|], [|arg_isep|])dnl
popdef([|CLEANUP|])dnl
