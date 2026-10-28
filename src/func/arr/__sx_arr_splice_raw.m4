M_REQUIRE([|SX_CFG_ARR_HOLE __sx_ex_yield __sx_num_add1_nat0 __sx_num_add_nat0 __sx_num_cmp_nat0 __sx_num_sub1_nat0 __sx_num_sub_nat0 __sx_var_copy __sx_var_unset|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_splice_raw - リビジョンを更新せず配列要素を挿入・削除する（内部用）
##
## 使い方:
##   __sx_arr_splice_raw 配列名 [n [del [値 ...]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   元配列のリビジョンは変更しない。挿入値は穴指定を除き文字列として保存する。
##   del が 0・+0・-0 で挿入値がなければ、作業変数を設定せず直ちに成功する。
##   長さ・添字・値個数は文字列数値関数で処理し、シェルの算術幅に依存しない。
##   負の n は len との和に換算し、範囲外の距離は穴として保持する。
##   非空配列の負の開始位置は正規化後に範囲内と確定するため、長さとの再比較を省く。
##   del は先頭より前の穴も数え、省略・空文字列は末尾まで、負数は末尾からの除外とする。
##   削除後に残る先頭側の穴は挿入数に加え、添字を非負に平行移動して尾部を移す。
##   挿入値がなければ範囲外の穴を作らず、空配列への負位置の挿入でも末尾に穴を作らない。
##   先頭前の穴がなく削除指定数と挿入数が等しければ、削除範囲の調整と尾部移動の準備を省く。
##   この置換が末尾を超える場合は、挿入後の終端まで長さを拡張する。
##   del の省略・空文字列では尾部が残らないため、新しい長さと余剰尾部の掃除だけを確定する。
##   先頭前の穴がなければ、尾部の開始位置を直接求め、残り長と実削除数の計算を省く。
##   先頭前からの操作でも、削除数を穴の距離または旧長さと比較し、残る穴と移動元を直接求める。
##   この場合の残り長は開始位置の絶対値に等しいため、入力を保持して削除・除外数の上限に使う。
##   尾部移動は要素単位の __sx_var_copy で行い、拡大時は後方から前方へ、
##   縮小時は前方から後方へ処理して未読のソースを保護する。
##   尾部移動後に長さと余剰尾部を確定し、中央の各要素を深く掃除してから代入する。
##   旧配列の末尾以降へ直接追加する場合は、未使用の挿入先の掃除を省く。
##   新しい穴と旧配列範囲が重なる箇所も深く掃除する。操作前の範囲外変数は掃除しない。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_arr Q_len Q_n Q_del Q_rest Q_cnt Q_gap Q_hole Q_hole_end Q_new Q_src Q_end Q_val|])dnl

__sx_arr_splice_raw() {
	case "${#}:${3-}" in 3:0 | 3:[+-]0)
		return M_EX_OK
	esac

	Q_arr="${1}"
	Q_n="${2:-0}"
	Q_del="${3-}"
	shift ${2+"$((2 ${3++ 1}))"}
	eval "Q_len=\"\${${Q_arr}_len}\""
	Q_cnt="${#}"
	Q_gap=0
	Q_hole=0
	Q_hole_end=0

	# 1) 開始位置と削除範囲の確定。先頭より前の穴と旧配列から削除する数を分離する。
	#    n>=len では尾部がなく、値がある場合だけ n+cnt まで拡張する。
	case "${Q_n}" in
		-[!0]*)
			Q_n="${Q_n#-}"

			__sx_num_cmp_nat0 "${Q_n}" "${Q_len}" || case "${?}" in
				3)
					Q_rest="${Q_n}"
					__sx_num_sub_nat0 Q_gap "${Q_n}" "${Q_len}"
					# この分岐だけは空配列の可能性がある。
					case "${Q_len}" in
						0) Q_n=0; __sx_ex_yield 2;;
						*) ! Q_n=0;;
					esac
					;;
				# 非空配列と n<len が最初の比較から確定している。
				2) ! Q_n=0;;
				1) ! __sx_num_sub_nat0 Q_n "${Q_len}" "${Q_n}";;
			esac
			;;
		[+-]*) Q_n="${Q_n#[+-]}";&
		*) __sx_num_cmp_nat0 "${Q_n}" "${Q_len}";;
	esac || case "${?}" in
		1)
			# 先頭前の穴がない同数置換は、準備計算を飛ばして書込みへ進む。
			# 末尾を超える場合も尾部は残らず、新しい終端まで長さを拡張するだけでよい。
			# 0・1 要素は n<len から範囲内と確定し、複数要素だけ終端を確認する。
			case "${Q_gap}:${Q_del}" in
				*:)
					# 末尾まで削除する場合は、残り長や削除数を求めず長さを直接確定する。
					__sx_num_add_nat0 Q_new "${Q_n}" "${Q_cnt}"
					M_VAR_SET([|${Q_arr}_len|], [|${Q_new}|])

					# 上書きする部分は共通の書込み処理で掃除し、余剰尾部だけをここで掃除する。
					__sx_num_cmp_nat0 "${Q_new}" "${Q_len}" || ! case "${?}" in 1)
						while M_STR_NE([|"${Q_new}"|], [|"${Q_len}"|]); do
							__sx_var_unset "${Q_arr}_${Q_new}"
							M_NUM_INCRM1([|Q_new|])
						done
					esac
					;;
				"0:${Q_cnt}" | "0:+${Q_cnt}")
					! case "${Q_cnt}" in [!01] | ??*)
						__sx_num_add_nat0 Q_end "${Q_n}" "${Q_cnt}"
						__sx_num_cmp_nat0 "${Q_end}" "${Q_len}" || case "${?}" in 3)
							M_VAR_SET([|${Q_arr}_len|], [|${Q_end}|]);;
						esac
					esac
					;;
				# 削除数へ換算せず、残る尾部の開始位置を直接求める。
				0:0 | 0:[+-]0) Q_src="${Q_n}";;
				0:-*)
					Q_del="${Q_del#-}"
					__sx_num_cmp_nat0 "${Q_del}" "${Q_len}" || case "${?}" in
						1)
							__sx_num_sub_nat0 Q_src "${Q_len}" "${Q_del}"
							__sx_num_cmp_nat0 "${Q_src}" "${Q_n}" || case "${?}" in 1)
								Q_src="${Q_n}"
							esac
							;;
						*) Q_src="${Q_n}";;
					esac
					;;
				0:*)
					__sx_num_add_nat0 Q_src "${Q_n}" "${Q_del#+}"
					__sx_num_cmp_nat0 "${Q_src}" "${Q_len}" || case "${?}" in 3)
						Q_src="${Q_len}"
					esac
					;;
				*:[1-9]* | *:[+-][1-9]*)
					# n=0、gap>0。残り長は入力から保持済みであり、丸めた総削除数も求めない。
					case "${Q_del}" in
						-*)
							# 末尾から除外する数が旧長さ未満なら、穴をすべて削除する。
							Q_del="${Q_del#-}"
							__sx_num_cmp_nat0 "${Q_del}" "${Q_len}" || case "${?}" in
								1)
									__sx_num_sub_nat0 Q_del "${Q_len}" "${Q_del}"
									Q_gap=0
									;;
								2) Q_del=0 Q_gap=0;;
								3)
									# 全体を除外する場合は穴を保持し、それ以外は旧長さとの差だけ残す。
									__sx_num_cmp_nat0 "${Q_del}" "${Q_rest}" || case "${?}" in 1)
										__sx_num_sub_nat0 Q_gap "${Q_del}" "${Q_len}"
									esac
									Q_del=0
									;;
							esac
							;;
						+*) Q_del="${Q_del#+}";&
						*)
							# 穴の距離との差から、残る穴と旧配列の削除数を直接求める。
							__sx_num_cmp_nat0 "${Q_del}" "${Q_gap}" || case "${?}" in
								1)
									__sx_num_sub_nat0 Q_gap "${Q_gap}" "${Q_del}"
									Q_del=0
									;;
								2) Q_del=0 Q_gap=0;;
								3)
									# 末尾を超える巨大数は、差分を計算せず旧長さに丸める。
									__sx_num_cmp_nat0 "${Q_del}" "${Q_rest}" || case "${?}" in
										1) __sx_num_sub_nat0 Q_del "${Q_del}" "${Q_gap}";;
										*) Q_del="${Q_len}";;
									esac
									Q_gap=0
									;;
							esac
							;;
					esac
					;&
				*)
					# 挿入値がなければ残った尾部を先頭へ平行移動し、穴は作らない。
					case "${Q_cnt}:${Q_gap}" in [!0]*:[!0]*)
						Q_hole="${Q_cnt}"
						__sx_num_add_nat0 Q_cnt "${Q_cnt}" "${Q_gap}"

						# 新しい穴の掃除は旧配列範囲との交差部分だけに限定する。
						__sx_num_cmp_nat0 "${Q_hole}" "${Q_len}" || case "${?}" in
							1)
								__sx_num_cmp_nat0 "${Q_cnt}" "${Q_len}" || case "${?}" in
									3) Q_hole_end="${Q_len}";;
									*) Q_hole_end="${Q_cnt}";;
								esac
								;;
							*) Q_hole=0;;
						esac
					esac

					# 先頭前からの操作では n=0 のため、加算せず開始位置を使える。
					Q_src="${Q_del#[+-]}"
					Q_end="${Q_cnt}"
					;;
				# 2) 尾部 [src, len) を [end, new) へ移す。
				#    両開始位置の比較で移動方向が決まり、実削除数は不要。
			esac && {
				${Q_end+':'} __sx_num_add_nat0 Q_end "${Q_n}" "${Q_cnt}"

				__sx_num_cmp_nat0 "${Q_end}" "${Q_src}" || case "${?}" in
					1)
						# 縮小: ソースと宛先を前方へ進め、未読のソースを保護する。
						case "${Q_src}" in
							"${Q_len}") Q_new="${Q_end}";;
							*)
								__sx_num_sub_nat0 Q_new "${Q_len}" "${Q_src}"
								__sx_num_add_nat0 Q_new "${Q_new}" "${Q_end}"

								while M_STR_NE([|"${Q_src}"|], [|"${Q_len}"|]); do
									__sx_var_copy "${Q_arr}_${Q_src}-${Q_arr}_${Q_end}"
									M_NUM_INCRM1([|Q_src|])
									M_NUM_INCRM1([|Q_end|])
								done
								;;
						esac

						# 長さを確定し、余剰尾部を深く掃除する。
						M_VAR_SET([|${Q_arr}_len|], [|${Q_new}|])
						while M_STR_NE([|"${Q_new}"|], [|"${Q_len}"|]); do
							__sx_var_unset "${Q_arr}_${Q_new}"
							M_NUM_INCRM1([|Q_new|])
						done
						;;
					3)
						# 拡大: 末尾から逆順で移す。削除なしなら旧長さを再利用する。
						case "${Q_src}" in
							"${Q_len}") M_VAR_SET([|${Q_arr}_len|], [|${Q_end}|]);;
							*)
								case "${Q_src}" in
									"${Q_n}") __sx_num_add_nat0 Q_new "${Q_len}" "${Q_cnt}";;
									*)
										__sx_num_sub_nat0 Q_new "${Q_len}" "${Q_src}"
										__sx_num_add_nat0 Q_new "${Q_new}" "${Q_end}"
										;;
								esac

								M_VAR_SET([|${Q_arr}_len|], [|${Q_new}|])

								while M_STR_NE([|"${Q_len}"|], [|"${Q_src}"|]); do
									M_NUM_DECRM1([|Q_len|])
									M_NUM_DECRM1([|Q_new|])
									__sx_var_copy "${Q_arr}_${Q_len}-${Q_arr}_${Q_new}"
								done
								;;
						esac
						;;
				esac
			}
			;;
		*)
			case "${Q_cnt}" in [!0]*)
				__sx_num_add_nat0 "${Q_arr}_len" "${Q_n}" "${Q_cnt}"

				# 追加先は旧配列の範囲外で未使用のため、深い掃除は不要。
				for Q_val in "${@}"; do
					case "${Q_val}" in
						'') ;;
						"${SX_CFG_ARR_HOLE}")
							M_NUM_INCRM1([|Q_n|])
							continue
							;;
					esac

					M_VAR_SET([|${Q_arr}_${Q_n}|], [|${Q_val}|])
					M_NUM_INCRM1([|Q_n|])
				done
			esac

			unset CLEANUP
			return
			;;
	esac

	while M_STR_NE([|"${Q_hole}"|], [|"${Q_hole_end}"|]); do
		__sx_var_unset "${Q_arr}_${Q_hole}"
		M_NUM_INCRM1([|Q_hole|])
	done

	# 3) 中央の書込み: 尾部移動後、各挿入位置を深く掃除してから
	#    直ちに代入する。スロットは互いに独立しているため、掃除と代入を
	#    一周に統合して添字の多倍長インクリメントを重複させない。
	for Q_val in "${@}"; do
		case "${Q_val}" in
			'') ;;
			"${SX_CFG_ARR_HOLE}")
				__sx_var_unset "${Q_arr}_${Q_n}"
				M_NUM_INCRM1([|Q_n|])
				continue
				;;
		esac

		__sx_var_unset "${Q_arr}_${Q_n}"
		eval "${Q_arr}_${Q_n}=\"\${Q_val}\""
		M_NUM_INCRM1([|Q_n|])
	done

	unset CLEANUP
}
|], [|arr_splice_raw|])dnl
popdef([|CLEANUP|])dnl
