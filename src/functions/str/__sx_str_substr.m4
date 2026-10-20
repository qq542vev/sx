dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_qm|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_substr - 文字列の部分文字列を取得する（内部用）
##
## 使い方:
##   __sx_str_substr 結果変数名 [元文字列 [オフセット [長さ]]]
##
## 説明:
##   sx_str_substr の内部実装。引数チェックは行わない。
##   オフセットと長さは10進整数表記（任意の符号付き、先行する 0 なし）を前提とする。
##   負のオフセットは末尾から抽出し、長さの省略は末尾までの抽出として扱う。
##   文字列長と数値引数の絶対値が数値範囲内なら算術、それ以外は多倍長で比較・減算する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_str Q_off Q_len Q_off_abs Q_len_abs Q_qm Q_type|])dnl

__sx_str_substr() {
	case "${2-}" in '')
		M_VAR_SET([|${1}|])
		return
	esac

	case "${4-}" in 0 | [+-]0)
		M_VAR_SET([|${1}|])
		return
	esac

	Q_str="${2-}"
	Q_off="${3:-0}"
	Q_len="${4:-${#Q_str}}"

	# 元の符号は保持し、絶対値と補正後の文字数は _abs 側で管理する。
	Q_off_abs="${Q_off#[+-]}"
	Q_len_abs="${Q_len#[+-]}"

	# 絶対値で判定し、負の最小値も多倍長演算に回す。
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#Q_str}" "${Q_off_abs}" "${Q_len_abs}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	case "${Q_off}" in
		0 | [+-]0) ;;
		-*)
			"__sx_num_cmp_${Q_type}" "${Q_off_abs}" "${#Q_str}" || case "${?}${4-}" in
				1*)
					__sx_str_qm Q_qm "${Q_off_abs}"
					Q_str="${Q_str#"${Q_str%${Q_qm}}"}"
					;;
				3[!-]*)
					# 先頭より前の文字数を、明示された非負の長さから除く。
					"__sx_num_sub_${Q_type}" Q_off_abs "${Q_off_abs}" "${#Q_str}"
					"__sx_num_cmp_${Q_type}" "${Q_len_abs}" "${Q_off_abs}" || case "${?}" in
						3) "__sx_num_sub_${Q_type}" Q_len_abs "${Q_len_abs}" "${Q_off_abs}";;
						*) Q_len_abs=0;;
					esac
					;;
			esac
			;;
		*)
			"__sx_num_cmp_${Q_type}" "${Q_off_abs}" "${#Q_str}" || case "${?}" in
				1)
					__sx_str_qm Q_qm "${Q_off_abs}"
					Q_str="${Q_str#${Q_qm}}"
					;;
				*) Q_str=;;
			esac
			;;
	esac

	"__sx_num_cmp_${Q_type}" "${Q_len_abs}" "${#Q_str}" || case "${?}${Q_len}" in
		1-*)
			__sx_str_qm Q_qm "${Q_len_abs}"
			Q_str="${Q_str%${Q_qm}}"
			;;
		?-*) Q_str=;;
		1*)
			__sx_str_qm Q_qm "${Q_len_abs}"
			Q_str="${Q_str%"${Q_str#${Q_qm}}"}"
			;;
	esac

	M_VAR_SET([|${1}|], [|${Q_str}|])
	unset CLEANUP
}
|], [|str_substr|])dnl
popdef([|CLEANUP|])dnl
