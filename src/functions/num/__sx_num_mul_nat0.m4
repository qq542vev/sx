dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_NUM_QM_1 SX_NUM_QM_10 SX_NUM_QM_11 SX_NUM_QM_12 SX_NUM_QM_13 SX_NUM_QM_14 SX_NUM_QM_15 SX_NUM_QM_16 SX_NUM_QM_17 SX_NUM_QM_18 SX_NUM_QM_19 SX_NUM_QM_2 SX_NUM_QM_20 SX_NUM_QM_21 SX_NUM_QM_22 SX_NUM_QM_23 SX_NUM_QM_24 SX_NUM_QM_25 SX_NUM_QM_26 SX_NUM_QM_27 SX_NUM_QM_28 SX_NUM_QM_29 SX_NUM_QM_3 SX_NUM_QM_30 SX_NUM_QM_31 SX_NUM_QM_32 SX_NUM_QM_33 SX_NUM_QM_34 SX_NUM_QM_35 SX_NUM_QM_36 SX_NUM_QM_37 SX_NUM_QM_4 SX_NUM_QM_5 SX_NUM_QM_6 SX_NUM_QM_7 SX_NUM_QM_8 SX_NUM_QM_9 SX_NUM_ZR_1 SX_NUM_ZR_10 SX_NUM_ZR_11 SX_NUM_ZR_12 SX_NUM_ZR_13 SX_NUM_ZR_14 SX_NUM_ZR_15 SX_NUM_ZR_16 SX_NUM_ZR_17 SX_NUM_ZR_18 SX_NUM_ZR_19 SX_NUM_ZR_2 SX_NUM_ZR_20 SX_NUM_ZR_21 SX_NUM_ZR_22 SX_NUM_ZR_23 SX_NUM_ZR_24 SX_NUM_ZR_25 SX_NUM_ZR_26 SX_NUM_ZR_27 SX_NUM_ZR_28 SX_NUM_ZR_29 SX_NUM_ZR_3 SX_NUM_ZR_30 SX_NUM_ZR_31 SX_NUM_ZR_32 SX_NUM_ZR_33 SX_NUM_ZR_34 SX_NUM_ZR_35 SX_NUM_ZR_36 SX_NUM_ZR_37 SX_NUM_ZR_4 SX_NUM_ZR_5 SX_NUM_ZR_6 SX_NUM_ZR_7 SX_NUM_ZR_8 SX_NUM_ZR_9 SX_SYS_NUM_MAX SX_SYS_NUM_QM SX_SYS_NUM_WLEN __sx_num_add_nat0 __sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_mul_nat0 - 複数の絶対値を乗算する（内部用）
##
## 使い方:
##   __sx_num_mul_nat0 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を乗算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   逐次方式でアキュムレータに各数値を順次乗算する。

define([|CLEANUP|], [|Q_res Q_a Q_b Q_endz Q_shift Q_tmp Q_ch_a Q_ch_b Q_a_len Q_b_len Q_max_x Q_min_ops Q_opt_x Q_opt_y Q_x Q_y Q_ops Q_qchunk_a Q_qchunk_b Q_zchunk_a Q_zchunk_b Q_carry Q_g Q_fit Q_safe|])dnl

__sx_num_mul_nat0() {
	Q_res="${1}"
	Q_a="${2-1}"
	Q_endz=
	Q_fit=1
	shift "$((1 + 0${2+1}))"

	case "${Q_a}" in 0)
		set --
	esac

	# safe_: 分割探索式の (len + (x - 1)) が INT_MAX を超えないための上限
	Q_safe=$((SX_SYS_NUM_MAX - SX_SYS_NUM_WLEN + 2))

	for Q_b in "${@}"; do
		case "${Q_b}" in 0)
			Q_a=0
			Q_endz=
			break
		esac

		# 高速パス: 両因数が1語に収まればシェル算術で直接乗算
		case "${Q_a}${Q_b}" in
			${SX_SYS_NUM_QM}?*) ;;
			*)
				M_NUM_AMP([|Q_a|], [|Q_b|])
				continue
				;;
		esac

		# 末尾のゼロを一時分離し、後で結合する
		case "${Q_a}" in *0)
			Q_tmp="${Q_a##*[!0]}"
			Q_a="${Q_a%${Q_tmp}}"
			M_STR_APPEND([|Q_endz|], [|"${Q_tmp}"|])
		esac

		case "${Q_b}" in *0)
			Q_tmp="${Q_b##*[!0]}"
			Q_b="${Q_b%${Q_tmp}}"
			M_STR_APPEND([|Q_endz|], [|"${Q_tmp}"|])
		esac

		# 1の乗算をスキップ / 1語に収まらなければ多倍長処理へ
		case "${Q_a}:${Q_b}" in
			1:*) Q_a="${Q_b}";&
			*:1) ! :;;
			${SX_SYS_NUM_QM}??*) ;;
			*) ! M_NUM_AMP([|Q_a|], [|Q_b|])
		esac || continue

		# fit_: 桁数そのものが INT_MAX を超えると算術展開できないため、
		#       範囲内に収まる桁数かどうかを確認する
		Q_a_len="${#Q_a}"
		Q_b_len="${#Q_b}"

		case "${Q_fit}" in 1)
			__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_a_len}" "${Q_b_len}" || Q_fit=0
		esac

		# 長い方を a に統一し、分割最適化の効果を最大化
		case "$((Q_fit && Q_a_len < Q_b_len))" in 1)
			Q_tmp="${Q_b}"
			Q_b="${Q_a}"
			Q_a="${Q_tmp}"
			Q_tmp="${Q_b_len}"
			Q_b_len="${Q_a_len}"
			Q_a_len="${Q_tmp}"
		esac

		# 安全: 桁数が算術展開可能な範囲内 → 全分割点を探索
		# 危険: 桁数が算術展開不能 or 範囲超過 → 均等分割にフォールバック
		if M_NUM_BOOL([|Q_fit && Q_a_len <= Q_safe && Q_b_len <= Q_safe|]); then
			Q_max_x=$((Q_b_len < SX_SYS_NUM_WLEN ? Q_b_len : SX_SYS_NUM_WLEN - 1))
			Q_min_ops="${SX_SYS_NUM_MAX}"
			Q_opt_x=1
			Q_x=1

			while M_NUM_LE([|Q_x|], [|Q_max_x|]); do
				Q_y=$((SX_SYS_NUM_WLEN - Q_x))
				Q_ops=$((((Q_b_len + (Q_x - 1)) / Q_x) * ((Q_a_len + (Q_y - 1)) / Q_y)))

				case "$((Q_ops < Q_min_ops))" in 1)
					Q_min_ops="${Q_ops}"
					Q_opt_x="${Q_x}"
				esac

				M_NUM_INCR([|Q_x|])
			done
		else
			Q_opt_x=$(((SX_SYS_NUM_WLEN + 1) / 2))
		fi

		# 最適分割サイズに基づきチャンク用 QM/ZR をロード
		Q_opt_y=$((SX_SYS_NUM_WLEN - Q_opt_x))

		eval "Q_qchunk_a=\"\${SX_NUM_QM_${Q_opt_y}}\" \
		      Q_zchunk_a=\"\${SX_NUM_ZR_${Q_opt_y}}\" \
		      Q_qchunk_b=\"\${SX_NUM_QM_${Q_opt_x}}\" \
		      Q_zchunk_b=\"\${SX_NUM_ZR_${Q_opt_x}}\""

		Q_shift=

		set --

		# a を opt_y 桁ずつ下位からチャンク分割し位置パラメータに格納
		while
			case "${Q_a}" in
				${Q_qchunk_a}?*)
					Q_tmp="${Q_a%${Q_qchunk_a}}"
					Q_ch_a="${Q_a#"${Q_tmp}"}"
					Q_a="${Q_tmp}"

					case "${Q_ch_a}" in
						0*) set -- "${@}" "$((1${Q_ch_a} - 1${Q_zchunk_a}))";;
						*) set -- "${@}" "${Q_ch_a}";;
					esac
					;;
				*) set -- "${@}" "${Q_a}" && break;;
			esac

			continue
		do :; done

		Q_a=0

		# b を opt_x 桁ずつ分割しながら a の全チャンクと乗算
		while
			case "${Q_b}" in
				'') break;;
				${Q_qchunk_b}?*)
					Q_tmp="${Q_b%${Q_qchunk_b}}"
					Q_ch_b="${Q_b#"${Q_tmp}"}"
					Q_b="${Q_tmp}"

					case "${Q_ch_b}" in
						0*[1-9]*) Q_ch_b=$((1${Q_ch_b} - 1${Q_zchunk_b}));;
						0*)
							M_STR_PREPEND([|Q_shift|], [|"${Q_zchunk_b}"|])
							continue
							;;
					esac
					;;
				*)
					Q_ch_b="${Q_b}"
					Q_b=
					;;
			esac

			Q_g=
			Q_carry=

			# チャンク同士の乗算と桁上げ処理
			for Q_ch_a in "${@}"; do
				Q_tmp=$((Q_ch_b * Q_ch_a + ${Q_carry:-0}))

				case "$((1${Q_zchunk_a} <= Q_tmp))" in
					1)
						Q_carry="${Q_tmp%${Q_qchunk_a}}"
						M_STR_PREPEND([|Q_g|], [|"${Q_tmp#"${Q_carry}"}"|])
						;;
					*)
						Q_carry=

						case "${Q_tmp}" in
							${Q_qchunk_a}) M_STR_PREPEND([|Q_g|], [|"${Q_tmp}"|]);;
							*)
								M_NUM_INCR([|Q_tmp|], [|1${Q_zchunk_a}|])
								M_STR_PREPEND([|Q_g|], [|"${Q_tmp#1}"|])
								;;
						esac
						;;
				esac
			done

			case "${Q_carry}:${Q_g}" in :0*)
				Q_g="M_STR_LTRIM([|Q_g|], [|[!0]|])"
			esac

			# 部分積を結果リストに追加
			__sx_num_add_nat0 Q_a "${Q_a}" "${Q_carry}${Q_g}${Q_shift}"

			M_STR_PREPEND([|Q_shift|], [|"${Q_zchunk_b}"|])
			continue
		do :; done
	done

	M_VAR_SET([|${Q_res}|], [|${Q_a}${Q_endz}|])
	unset CLEANUP
}
|], [|num_mul_nat0|])dnl
popdef([|CLEANUP|])dnl
