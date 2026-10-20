dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_RESIZE_PAD_LEFT SX_CFG_NUM_RANGE SX_CFG_SEP __sx_arg_quote __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_divceil_nat0 __sx_num_is_int_fit_dec __sx_num_mul_nat0 __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_sub __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_resize - 引数リストをリサイズする（内部用）
##
## 使い方:
##   __sx_arg_resize bind [shape [pad_val [flag]]] ::: [値 ...]
##   __sx_arg_resize bind [shape [値 ...]]
##
## 説明:
##   sx_arg_resize の内部実装。引数チェックは行わない。
##   形状の積と推論値は多倍長で計算し、算術域内ならループの減算に算術を使う。
##   外側の要素を順に生成し、バインド枯渇時に停止する。
##   サイズ0の軸より内側は生成しない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_shape Q_val Q_flg Q_total Q_tmp Q_dim Q_inferred Q_dims Q_outer Q_block Q_plan Q_left Q_type Q_n Q_value Q_chunk Q_rest Q_step Q_cnt Q_out Q_group|])dnl

__sx_arg_resize() {
	Q_bind="${1}"
	Q_shape= Q_val= Q_flg=0
	case "X${SX_CFG_SEP}" in
		"${2+X${2}}") shift 2;;
		"${3+X${3}}") Q_shape="${2}"; shift 3;;
		"${4+X${4}}") Q_shape="${2}" Q_val="${3}"; shift 4;;
		"${5+X${5}}") Q_shape="${2}" Q_val="${3}" Q_flg="${4}"; shift 5;;
		*) Q_shape="${2-}"; shift ${2+'2'};;
	esac
	: "${Q_shape:=${#}}" "${Q_flg:=0}"
	__sx_var_bind_init "${Q_bind}"
	case "${Q_bind}" in '') unset CLEANUP; return 0;; esac

	# 既知の軸の積を求める。入力値を算術式として展開しない。
	Q_total=1 Q_tmp="${Q_shape}"
	while :; do
		Q_dim="${Q_tmp%%:*}"
		case "${Q_dim}" in -1) ;; *) __sx_num_mul_nat0 Q_total "${Q_total}" "${Q_dim}";; esac
		case "${Q_tmp}" in *:*) Q_tmp="${Q_tmp#*:}";; *) break;; esac
	done
	case ":${Q_shape}:" in *:-1:*)
		Q_inferred=0
		case "${Q_total}" in 0) ;; *) __sx_num_divceil_nat0 Q_inferred "${#}" "${Q_total}";; esac
		__sx_num_mul_nat0 Q_total "${Q_total}" "${Q_inferred}"
		__sx_str_sub Q_shape: "${Q_shape}" -1 "${Q_inferred}"
	esac

	# 空の軸の子孫は出力に現れないので、形状から取り除く。
	Q_dims= Q_tmp="${Q_shape}"
	while :; do
		Q_dim="${Q_tmp%%:*}"
		Q_dims="${Q_dims}${Q_dims:+:}${Q_dim}"
		case "${Q_dim}" in 0) break;; esac
		case "${Q_tmp}" in *:*) Q_tmp="${Q_tmp#*:}";; *) break;; esac
	done
	Q_outer="${Q_dims%%:*}"
	case "${Q_outer}" in 0) unset CLEANUP; return 0;; esac

	# 外側の1要素に必要な個数と、内側からのグループ化手順を保持する。
	Q_block=1 Q_plan=
	case "${Q_dims}" in *:*)
		Q_tmp="${Q_dims#*:}"
		while :; do
			Q_dim="${Q_tmp%%:*}"
			Q_plan="${Q_dim}:${Q_block} ${Q_plan}"
			__sx_num_mul_nat0 Q_block "${Q_block}" "${Q_dim}"
			case "${Q_tmp}" in *:*) Q_tmp="${Q_tmp#*:}";; *) break;; esac
		done
	esac
	Q_type=nat0
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_total}" "${Q_outer}" "${Q_block}" "${#}"; then
		Q_type=arith
	fi
	Q_left=0
	case "$((Q_flg & SX_ARG_RESIZE_PAD_LEFT))" in 0) ;; *)
		"__sx_num_cmp_${Q_type}" "${Q_total}" "${#}" || case "${?}" in 3)
			"__sx_num_sub_${Q_type}" Q_left "${Q_total}" "${#}"
		esac
	esac

	while M_STR_NE([|"${Q_outer}"|], [|0|]) && M_STR_NE([|"${Q_bind}"|], [|''|]); do
		Q_n="${Q_block}" Q_chunk=
		while M_STR_NE([|"${Q_n}"|], [|0|]); do
			case "${Q_left}" in
				0) case "${#}" in
					0) Q_value="${Q_val}";;
					*) Q_value="${1}"; shift;;
				esac;;
				*) Q_value="${Q_val}"; "__sx_num_sub1_${Q_type}" Q_left "${Q_left}";;
			esac
			case "${Q_plan}" in '') ;; *) __sx_var_bind '' Q_chunk "${Q_value}";; esac
			"__sx_num_sub1_${Q_type}" Q_n "${Q_n}"
		done

		case "${Q_plan}" in '') ;; *)
			__sx_arg_quote Q_rest "${@}"
			eval set -- "${Q_chunk}"
			Q_tmp="${Q_plan}"
			while M_STR_NE([|"${Q_tmp}"|], [|''|]); do
				Q_step="${Q_tmp%% *}" Q_tmp="${Q_tmp#* }"
				Q_dim="${Q_step%%:*}" Q_cnt="${Q_step#*:}" Q_out=
				while M_STR_NE([|"${Q_cnt}"|], [|0|]); do
					Q_group=
					case "${Q_dim}" in 0) ;; *)
						__sx_arg_quote "${Q_dim}Q_group:" "${@}"
						# 生成済みの位置パラメータから取り出すため、この個数はシェルで扱える。
						shift "${Q_dim}"
					esac
					__sx_var_bind '' Q_out "${Q_group}"
					__sx_num_sub1_nat0 Q_cnt "${Q_cnt}"
				done
				eval set -- "${Q_out}"
			done
			Q_value="${1}"
			eval set -- "${Q_rest}"
		esac
		__sx_var_bind Q_bind "${Q_bind}" "${Q_value}" || break
		"__sx_num_sub1_${Q_type}" Q_outer "${Q_outer}"
	done
	unset CLEANUP
}
|], [|arg_resize|])dnl
popdef([|CLEANUP|])dnl
