M_REQUIRE([|__sx_num_add_int __sx_num_divmod_int __sx_num_range __sx_num_sub_int __sx_sh_param_ref|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_sh_pos_ref - 位置パラメータの参照文字列を範囲指定で生成する（内部用）
##
## 使い方:
##   __sx_sh_pos_ref 結果変数名 区切り文字 [spec ...]
##
## 説明:
##   sx_sh_pos_ref の内部実装。引数チェックは行わない。
##   各 spec を解析し、出力対象のインデックスが 1 以上になるよう範囲を
##   事前計算してから __sx_num_range に渡す。
##   昇順では符号付き除算により等差数列のうち最初の 1 以上の要素を求め、
##   降順では終端を max(終点, 0) にクランプする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_res Q_sep Q_spec Q_s Q_e Q_t Q_d Q_q Q_r Q_tmp|])dnl

__sx_sh_pos_ref() {
	Q_res="${1}"
	Q_sep="${2-}"
	Q_tmp=
	shift ${2+'2'}

	for Q_spec in "${@}"; do
		Q_spec="${Q_spec#+}"
		case "${Q_spec}" in
			# 0 < s && e < 0 && t < 0 ⇒ e = 0
			[1-9]*:-*:-*) Q_spec="${Q_spec%%:*}:0:${Q_spec##*:}";;
			# 0 < s ⇒ 変更なし
			[1-9]*:*) ;;
			# s <= 0 && (e or t) <= 0 ⇒ スキップ
			*:[-0]* | *:+0*) continue;;
			# s <= 0 && 1 <= t
			*:*:[!-]*)
				Q_s="${Q_spec%%:*}"
				Q_e="${Q_spec#*:}"
				Q_e="${Q_e%:*}"
				Q_t="${Q_spec##*:}"

				__sx_num_sub_int Q_d 1 "${Q_s}"
				__sx_num_divmod_int 'Q_q:Q_r:' "${Q_d}" "${Q_t}"
				case "${Q_r}" in
					0) Q_s=1;;
					*)
						__sx_num_sub_int Q_q "${Q_t}" "${Q_r}"
						__sx_num_add_int Q_s 1 "${Q_q}"
						;;
				esac

				Q_spec="${Q_s}:${Q_e}:${Q_t}"
				;;
			# s <= 0 && t == none ⇒ s = 1
			*:*) Q_spec="1:${Q_spec##*:}";;
			# (s and t) == none ⇒ s = 1
			*) Q_spec="1:${Q_spec}";;
		esac

		M_STR_APPEND([|Q_tmp|], [|" ${Q_spec}"|])
	done

	eval __sx_num_range Q_tmp "${Q_tmp}"
	eval __sx_sh_param_ref "${Q_res}" '"${Q_sep}"' "${Q_tmp}"

	unset CLEANUP
}
|], [|sh_pos_ref|])dnl
popdef([|CLEANUP|])dnl
