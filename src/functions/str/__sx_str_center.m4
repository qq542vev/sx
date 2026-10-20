dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_divceil_arith __sx_num_divceil_nat0 __sx_num_is_int_fit_dec __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_rep __sx_str_substr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_center - 文字列を指定された幅で中央寄せする（内部用）
##
## 使い方:
##   __sx_str_center 結果変数名 文字列 幅 [左埋め文字列 [右埋め文字列]]
##
## 説明:
##   sx_str_center の内部実装。引数チェックは行わない。
##   幅は10進整数表記（任意の符号付き、先行する 0 なし）を前提とする。
##   左右の埋め文字列が両方とも空の場合は何もせず成功を返す。
##   文字列長と幅の絶対値が数値範囲内なら算術、それ以外は多倍長で処理する。
##   左右の埋め文字列が等しい場合、長い側に合わせて1回だけ str_rep を呼ぶ。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_slen Q_llen Q_rlen Q_needed Q_cnt Q_lpad Q_rpad Q_lrep Q_rrep Q_spad Q_epad Q_type|])dnl

__sx_str_center() {
	set -- "${1}" "${2-}" "${3-0}" "${4- }" "${5-${4- }}"

	case "${3}:${4:+X}${5:+X}" in 0* | [+-]0* | *:)
		M_VAR_SET([|${1}|], [|${2}|])
		return
	esac

	Q_slen="${#2}"
	Q_llen="${#4}"
	Q_rlen="${#5}"
	Q_needed="${3#[+-]}"

	# 絶対値で判定し、負の最小値も多倍長演算に回す。
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_slen}" "${Q_llen}" "${Q_rlen}" "${Q_needed}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	"__sx_num_cmp_${Q_type}" "${Q_needed}" "${Q_slen}" || case "${?}" in [12])
		M_VAR_SET([|${1}|], [|${2}|])
		unset CLEANUP
		return
	esac

	"__sx_num_sub_${Q_type}" Q_needed "${Q_needed}" "${Q_slen}"
	# Q_cnt は長い側の文字数。先に1を加算せず、切り上げ除算で求める。
	"__sx_num_divceil_${Q_type}" Q_cnt "${Q_needed}" 2

	case "${3}" in
		-*) Q_lpad="${Q_cnt}";;
		*) "__sx_num_sub_${Q_type}" Q_lpad "${Q_needed}" "${Q_cnt}";;
	esac

	"__sx_num_sub_${Q_type}" Q_rpad "${Q_needed}" "${Q_lpad}"

	case "${4:+X}" in X)
		"__sx_num_divceil_${Q_type}" Q_cnt "${Q_cnt}" "${Q_llen}"
		__sx_str_rep Q_lrep "${4}" "${Q_cnt}"
	esac

	case "${5}" in
		"${4}") Q_rrep="${Q_lrep}";;
		?*)
			"__sx_num_divceil_${Q_type}" Q_cnt "${Q_rpad}" "${Q_rlen}"
			__sx_str_rep Q_rrep "${5}" "${Q_cnt}"
			;;
	esac

	__sx_str_substr Q_spad "${Q_lrep-}" 0 "${Q_lpad}"
	__sx_str_substr Q_epad "${Q_rrep-}" 0 "${Q_rpad}"

	M_VAR_SET([|${1}|], [|${Q_spad}${2}${Q_epad}|])

	unset CLEANUP
}
|], [|str_center|])dnl
popdef([|CLEANUP|])dnl
