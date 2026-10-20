M_REQUIRE([|SX_CFG_NUM_RANGE SX_STR_CHUNK_SKIP_LONG SX_STR_CHUNK_SKIP_SHORT __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_qm __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_chunk0 - 基準方向を指定して文字列を一定の長さで区切る（内部用）
##
## 使い方:
##   __sx_str_chunk0 スキーマ 文字列 長さ 分割回数 フラグ 基準方向
##
## 説明:
##   内部実装。引数チェックは行わない。
##   基準方向は 1（前方）/-1（後方）。フラグは残余チャンクの扱いを指定する。
##   長さと ? パターンの交互リストを一度だけ構築し、周期的に反復する。
##   基準方向のチャンクは即座にバインドし、逆方向分は ? パターンを位置パラメータに逆順で予約する。
##   Q_str は未切り取りの文字列、Q_len は予約分を除いた未割り当て文字数。
##   終了後に中央の余りを処理し、予約したパターンで基準方向から順に切り取る。
##   基準方向でループ・余り・予約分の処理を分岐し、切り取り方向を反転する。
##   長さは符号付き、回数は符号なしの10進整数（先行ゼロなし）を前提とする。
##   文字列長・回数・各指定長の絶対値が算術域内なら高速経路、それ以外は多倍長で処理する。
##
## 終了ステータス:
##   0  成功（バインド枯渇による早期終了を含む）。

define([|CLEANUP|], [|Q_bind Q_str Q_cycle Q_lim Q_len Q_flg Q_dir Q_qms Q_cur Q_qm Q_abs Q_arg Q_prev Q_next Q_chunk Q_type Q_cmp|])dnl

__sx_str_chunk0() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2-}"
	Q_len="${#Q_str}"
	Q_cycle="${3:-1}:"
	Q_lim="${4-}"
	Q_flg="${5:-0}"
	Q_dir="${6}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_len}" ${Q_lim:+"${Q_lim}"}; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	# eval に埋め込むのは検証済みの10進整数と生成した ? だけとする。
	# 元文字列より長い項目は必ず停止するため、パターンを生成しない。
	Q_qms=
	while M_STR_HAS([|"${Q_cycle}"|], [|:|]); do
		Q_cur="${Q_cycle%%:*}"
		Q_cycle="${Q_cycle#*:}"
		Q_abs="${Q_cur#[+-]}"

		case "${Q_cur}" in [+-]0)
			Q_cur=0
		esac

		case "${Q_type}" in arith)
			__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_abs}" || Q_type=nat0
		esac

		Q_qm=
		"__sx_num_cmp_${Q_type}" "${Q_abs}" "${Q_len}" || case "${?}" in [12])
			__sx_str_qm Q_qm "${Q_abs}"
		esac

		M_STR_APPEND([|Q_qms|], [|" ${Q_cur} '${Q_qm}'"|])
	done

	# for の明示的な反復リストと、逆方向の予約パターン用の位置パラメータは独立する。
	set --

	case "${Q_dir}" in
		1)
			eval 'while
				for Q_arg in '"${Q_qms}"'; do
					case "${Q_arg}" in
						[0-9+-]*)
							Q_prev="${Q_arg}"
							Q_abs="${Q_prev#[+-]}"
							# 長さ 0 は、文字列が空でも空チャンクを生成する。
							"__sx_num_cmp_${Q_type}" "${Q_len}" "${Q_abs}" || Q_cmp="${?}"

							case "${Q_cmp}:${Q_lim}" in 1:* | *:0)
								break 2
							esac

							case "${Q_lim:+X}" in X)
								"__sx_num_sub1_${Q_type}" Q_lim "${Q_lim}"
							esac
							;;
						*)
							"__sx_num_sub_${Q_type}" Q_len "${Q_len}" "${Q_abs}"

							case "${Q_prev}" in
								-*)
									set -- "${Q_arg}" "${@}"
									continue
									;;
								*)
									Q_next="${Q_str#${Q_arg}}"
									__sx_var_bind Q_bind "${Q_bind}" "${Q_str%%"${Q_next}"}" || {
										unset CLEANUP
										return
									}
									;;
							esac

							Q_str="${Q_next}"
							;;
					esac
				done

				continue
			do :; done'

			# 中央の余りを先に取り出す。予約がなければ Q_str 全体が余りである。
			case "${Q_len}" in [1-9]*)
				case "${#}" in
					0) Q_next='' Q_chunk="${Q_str}";;
					*)
						__sx_str_qm Q_qm "${Q_len}"
						Q_next="${Q_str#${Q_qm}}"
						Q_chunk="${Q_str%%"${Q_next}"}"
						;;
				esac

				case "${Q_cmp}:$((Q_flg & SX_STR_CHUNK_SKIP_SHORT)):$((Q_flg & SX_STR_CHUNK_SKIP_LONG))" in 1:0:* | 2:* | 3:*:0)
					__sx_var_bind Q_bind "${Q_bind}" "${Q_chunk}" || {
						unset CLEANUP
						return
					}
				esac

				# 余りをスキップした場合も、予約分の先頭まで進める。
				Q_str="${Q_next}"
			esac

			for Q_qm in "${@}"; do
				Q_next="${Q_str#${Q_qm}}"
				__sx_var_bind Q_bind "${Q_bind}" "${Q_str%%"${Q_next}"}" || break
				Q_str="${Q_next}"
			done
			;;
		*)
			eval 'while
				for Q_arg in '"${Q_qms}"'; do
					case "${Q_arg}" in
						[0-9+-]*)
							Q_prev="${Q_arg}"
							Q_abs="${Q_prev#[+-]}"
							# 長さ 0 は、文字列が空でも空チャンクを生成する。
							"__sx_num_cmp_${Q_type}" "${Q_len}" "${Q_abs}" || Q_cmp="${?}"

							case "${Q_cmp}:${Q_lim}" in 1:* | *:0)
								break 2
							esac

							case "${Q_lim:+X}" in X)
								"__sx_num_sub1_${Q_type}" Q_lim "${Q_lim}"
							esac
							;;
						*)
							"__sx_num_sub_${Q_type}" Q_len "${Q_len}" "${Q_abs}"

							case "${Q_prev}" in
								-*)
									set -- "${Q_arg}" "${@}"
									continue
									;;
								*)
									Q_next="${Q_str%${Q_arg}}"
									__sx_var_bind Q_bind "${Q_bind}" "${Q_str##"${Q_next}"}" || {
										unset CLEANUP
										return
									}
									;;
							esac

							Q_str="${Q_next}"
							;;
					esac
				done

				continue
			do :; done'

			# 中央の余りを先に取り出す。予約がなければ Q_str 全体が余りである。
			case "${Q_len}" in [1-9]*)
				case "${#}" in
					0) Q_next='' Q_chunk="${Q_str}";;
					*)
						__sx_str_qm Q_qm "${Q_len}"
						Q_next="${Q_str%${Q_qm}}"
						Q_chunk="${Q_str##"${Q_next}"}"
						;;
				esac

				case "${Q_cmp}:$((Q_flg & SX_STR_CHUNK_SKIP_SHORT)):$((Q_flg & SX_STR_CHUNK_SKIP_LONG))" in 1:0:* | 2:* | 3:*:0)
					__sx_var_bind Q_bind "${Q_bind}" "${Q_chunk}" || {
						unset CLEANUP
						return
					}
				esac

				# 余りをスキップした場合も、予約分の末尾まで進める。
				Q_str="${Q_next}"
			esac

			for Q_qm in "${@}"; do
				Q_next="${Q_str%${Q_qm}}"
				__sx_var_bind Q_bind "${Q_bind}" "${Q_str##"${Q_next}"}" || break
				Q_str="${Q_next}"
			done
			;;
	esac

	unset CLEANUP
}
|], [|str_chunk0|])dnl
popdef([|CLEANUP|])dnl
