M_REQUIRE([|SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_STR_ALUND SX_STR_WORD __sx_num_add1_nat0 __sx_num_add_nat0 __sx_num_cmp_nat0 __sx_num_sub1_nat0 __sx_num_sub_nat0 __sx_var_copy __sx_var_copy_script __sx_var_unset|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_splice_raw - リビジョンを更新せず配列要素を挿入・削除する（内部用）
##
## 使い方:
##   __sx_arr_splice_raw 配列名 [n [del [値 ...]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   元配列のリビジョンは変更しない。参照・穴の解釈は従来どおり行う。
##   長さ・添字・値個数は文字列数値関数で処理し、シェルの算術幅に依存しない。
##   負の n は len との和に換算し、範囲外の距離は穴として保持する。
##   del は先頭より前の穴も数え、省略・空文字列は末尾まで、負数は末尾からの除外とする。
##   削除後に残る先頭側の穴は挿入数に加え、添字を非負に平行移動して尾部を移す。
##   挿入値がなければ範囲外の穴を作らず、空配列への負位置の挿入でも末尾に穴を作らない。
##   尾部移動は要素単位の __sx_var_copy で行い、拡大時は後方から前方へ、
##   縮小時は前方から後方へ処理して未読のソースを保護する。
##   尾部移動後に長さと余剰尾部を確定し、中央の各要素を深く掃除してから代入する。
##   新しい穴と旧配列範囲が重なる箇所も深く掃除する。操作前の範囲外変数は掃除しない。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_arr Q_len Q_n Q_del Q_rest Q_cnt Q_gap Q_hole Q_hole_end Q_new Q_src Q_end Q_val Q_chain Q_script|])dnl

__sx_arr_splice_raw() {
	Q_arr="${1}"
	Q_n="${2:-0}"
	Q_del="${3-}"
	shift "$((1 + 0${2+1} + 0${3+1}))"
	eval "Q_len=\"\${${Q_arr}_len}\""
	Q_cnt="${#}"
	Q_gap=0
	Q_hole=0
	Q_hole_end=0

	case "${Q_n}" in
		-0 | +*) Q_n="${Q_n#[+-]}";;
		-*)
			Q_n="${Q_n#-}"

			__sx_num_cmp_nat0 "${Q_n}" "${Q_len}" || case "${?}" in
				3) __sx_num_sub_nat0 Q_gap "${Q_n}" "${Q_len}";&
				2) Q_n=0;;
				1) __sx_num_sub_nat0 Q_n "${Q_len}" "${Q_n}";;
			esac
			;;
	esac

	# 1) 削除範囲の確定。先頭より前の距離 gap も残り長に含める。
	#    n>=len では尾部がなく、値がある場合だけ n+cnt まで拡張する。
	__sx_num_cmp_nat0 "${Q_n}" "${Q_len}" || case "${?}" in
		[23])
			case "${Q_cnt}" in
				0) ;;
				*) __sx_num_add_nat0 "${Q_arr}_len" "${Q_n}" "${Q_cnt}";;
			esac
			;;
		*)
			__sx_num_sub_nat0 Q_rest "${Q_len}" "${Q_n}"
			case "${Q_gap}" in
				0) ;;
				*) __sx_num_add_nat0 Q_rest "${Q_rest}" "${Q_gap}";;
			esac

			case "${Q_del}" in
				'') Q_del="${Q_rest}";;
				-0) Q_del=0;;
				-*)
					Q_del="${Q_del#-}"
					__sx_num_cmp_nat0 "${Q_del}" "${Q_rest}" || case "${?}" in
						1) __sx_num_sub_nat0 Q_del "${Q_rest}" "${Q_del}";;
						*) Q_del=0;;
					esac
					;;
				+*) Q_del="${Q_del#+}";&
				*)
					# del が残り長を超える場合は、残り全体の削除に丸める。
					__sx_num_cmp_nat0 "${Q_del}" "${Q_rest}" || case "${?}" in 3)
						Q_del="${Q_rest}"
					esac
					;;
			esac

			# 先頭より前の穴を先に削除し、旧配列から削除する数と分離する。
			case "${Q_gap}" in
				0) ;;
				*)
					__sx_num_cmp_nat0 "${Q_del}" "${Q_gap}" || case "${?}" in
						1)
							__sx_num_sub_nat0 Q_gap "${Q_gap}" "${Q_del}"
							Q_del=0
							;;
						*)
							__sx_num_sub_nat0 Q_del "${Q_del}" "${Q_gap}"
							Q_gap=0
							;;
					esac
					;;
			esac

			# 挿入値がなければ残った尾部を先頭へ平行移動し、穴は作らない。
			case "${Q_cnt}:${Q_gap}" in
				0:* | *:0) ;;
				*)
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
					;;
			esac

		# 2) 尾部の移動 (要素ごと): 削除範囲の後ろ [n+del, len) を
		#    挿入後の位置 [n+cnt, new) へずらす。1要素ずつ __sx_var_copy
		#    で移すことで、巨大配列でも生成スクリプトを1要素ぶんに抑える。
		#    n>=len の末尾追加パスは尾部が空で len 確定済みのため、
		#    上の分岐で終了しここへは到達しない。cnt は先頭側の穴も含む。
		__sx_num_cmp_nat0 "${Q_cnt}" "${Q_del}" || case "${?}" in
			1)
				# 縮小 (cnt < del): ソースと宛先を前方へ進める。
				# src=n+del、end=n+cnt とし、尾部を重複しない順序で移動する。
				__sx_num_add_nat0 Q_src "${Q_n}" "${Q_del}"
				__sx_num_add_nat0 Q_end "${Q_n}" "${Q_cnt}"

				case "${Q_src}" in
					# 尾部がない場合は new=n+cnt=end を再利用する。
					"${Q_len}") Q_new="${Q_end}";;
					*)
						# 通常の縮小では new=len-del+cnt を求めてから尾部を移動する。
						__sx_num_sub_nat0 Q_new "${Q_len}" "${Q_del}"
						__sx_num_add_nat0 Q_new "${Q_new}" "${Q_cnt}"

						while M_STR_NE([|"${Q_src}"|], [|"${Q_len}"|]); do
							__sx_var_copy "${Q_arr}_${Q_src}-${Q_arr}_${Q_end}"
							M_NUM_INCRM1([|Q_src|])
							M_NUM_INCRM1([|Q_end|])
						done
						;;
				esac

				# 長さを確定し、new 以降に残った旧要素を深く掃除する。
				eval "${Q_arr}_len=${Q_new}"

				while M_STR_NE([|"${Q_new}"|], [|"${Q_len}"|]); do
					__sx_var_unset "${Q_arr}_${Q_new}"
					M_NUM_INCRM1([|Q_new|])
				done
				;;
			3)
				# 拡大 (cnt > del): src=n+del を起点に、末尾から逆順で移動する。
				__sx_num_add_nat0 Q_src "${Q_n}" "${Q_del}"

				case "${Q_src}" in
					# 尾部がない場合は new=n+cnt を直接求める。
					"${Q_len}") __sx_num_add_nat0 "${Q_arr}_len" "${Q_n}" "${Q_cnt}";;
					*)
						# 通常の拡大では new=len-del+cnt を求めてから尾部を移動する。
						__sx_num_sub_nat0 Q_new "${Q_len}" "${Q_del}"
						__sx_num_add_nat0 Q_new "${Q_new}" "${Q_cnt}"

						# 長さを確定する。拡大では余剰尾部の掃除は発生しない。
						eval "${Q_arr}_len=${Q_new}"

						while M_STR_NE([|"${Q_len}"|], [|"${Q_src}"|]); do
							M_NUM_DECRM1([|Q_len|])
							M_NUM_DECRM1([|Q_new|])
							__sx_var_copy "${Q_arr}_${Q_len}-${Q_arr}_${Q_new}"
						done
						;;
				esac
				;;
		esac
		;;
	esac

	while M_STR_NE([|"${Q_hole}"|], [|"${Q_hole_end}"|]); do
		__sx_var_unset "${Q_arr}_${Q_hole}"
		M_NUM_INCRM1([|Q_hole|])
	done

	# 3) 中央の書込み: 尾部移動後、各挿入位置を深く掃除してから
	#    直ちに代入する。スロットは互いに独立しているため、掃除と代入を
	#    一周に統合して添字の多倍長インクリメントを重複させない。
	case "${SX_CFG_ARR_REF:+X}" in X)
		Q_cnt="${Q_n}"
		Q_chain=

		for Q_val in "${@}"; do
			case "${Q_val}" in
				"${SX_CFG_ARR_HOLE}" | "${SX_CFG_ARR_REF}"*[!${SX_STR_WORD}]*) ;;
				"${SX_CFG_ARR_REF}"[${SX_STR_ALUND}]*) M_STR_APPEND([|Q_chain|], [|" ${Q_val#"${SX_CFG_ARR_REF}"}-${Q_arr}_${Q_cnt}"|]);;
			esac

			M_NUM_INCRM1([|Q_cnt|])
		done

		case "${Q_chain:+X}" in X)
			eval __sx_var_copy_script Q_script "${Q_chain}"
		esac
	esac

	for Q_val in "${@}"; do
		case "${Q_val}" in
			'') ;;
			"${SX_CFG_ARR_HOLE}")
				__sx_var_unset "${Q_arr}_${Q_n}"
				M_NUM_INCRM1([|Q_n|])
				continue
				;;
			"${SX_CFG_ARR_REF:-"${Q_val}"}" | "${SX_CFG_ARR_REF}"*[!${SX_STR_WORD}]*) ;;
			"${SX_CFG_ARR_REF}"[${SX_STR_ALUND}]*)
				# 参照の書込みは一括コピーに任せるが、挿入位置は1要素分進める。
				M_NUM_INCRM1([|Q_n|])
				continue
				;;
		esac

		__sx_var_unset "${Q_arr}_${Q_n}"
		eval "${Q_arr}_${Q_n}=\"\${Q_val}\""
		M_NUM_INCRM1([|Q_n|])
	done

	eval "${Q_script-}"

	unset CLEANUP
}
|], [|arr_splice_raw|])dnl
popdef([|CLEANUP|])dnl
