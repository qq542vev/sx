dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_add1_arith __sx_num_add1_nat0 __sx_num_add_arith __sx_num_add_nat0 __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_var_bind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_isep_lit - 選択済みの境界に値を挿入して左からバインドする
##
## 使い方:
##   __sx_arg_isep_lit bind sep abs type first count head [マーカー ...] [値 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   first は最左の挿入境界。head=0 ではリテラル sep を挿入する。
##   head>0 では先頭の head 個を後方コールバックのマーカー列として消費する。
##   マーカーが ':' で始まる場合だけその後ろの値を挿入し、空なら省略する。
##   残り境界数が0になった後は位置を更新しない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_sep Q_abs Q_type Q_pos Q_left Q_head Q_mode Q_i Q_arg Q_val|])dnl

__sx_arg_isep_lit() {
	Q_bind="${1}" Q_sep="${2}" Q_abs="${3}" Q_type="${4}"
	Q_pos="${5}" Q_left="${6}" Q_head="${7}" Q_i=0
	case "${Q_head}" in 0) Q_mode=0;; *) Q_mode=1;; esac
	shift 7

	for Q_arg in "${@}"; do
		case "${Q_head}" in 0) ;; *)
			"__sx_num_sub1_${Q_type}" Q_head "${Q_head}"
			continue
		esac

		case "${Q_bind}" in '') break;; esac
		if M_STR_NE([|"${Q_left}"|], [|0|]) && M_STR_EQ([|"${Q_i}"|], [|"${Q_pos}"|]); then
			case "${Q_mode}" in
				0) Q_val=":${Q_sep}";;
				1) Q_val="${1}"; shift;;
			esac
			case "${Q_val}" in :*) __sx_var_bind Q_bind "${Q_bind}" "${Q_val#:}" || :;; esac
			"__sx_num_sub1_${Q_type}" Q_left "${Q_left}"
			case "${Q_left}" in 0) ;; *) "__sx_num_add_${Q_type}" Q_pos "${Q_pos}" "${Q_abs}";; esac
		fi

		__sx_var_bind Q_bind "${Q_bind}" "${Q_arg}" || break
		case "${Q_left}" in 0) ;; *) "__sx_num_add1_${Q_type}" Q_i "${Q_i}";; esac
	done

	# 元の値をすべて処理した後に残り得る境界は終了端の1つだけ。
	case "${Q_bind:+X}:${Q_left}" in :* | *:0) ;; *)
		case "${Q_mode}" in
			0) Q_val=":${Q_sep}";;
			1) Q_val="${1}";;
		esac
		case "${Q_val}" in :*) __sx_var_bind '' "${Q_bind}" "${Q_val#:}" || :;; esac
	esac

	unset CLEANUP
}
|], [|arg_isep_lit|])dnl
popdef([|CLEANUP|])dnl
