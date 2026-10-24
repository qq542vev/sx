M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_divceil_arith __sx_num_divceil_nat0 __sx_num_is_int_fit_dec __sx_num_sub_arith __sx_num_sub_nat0 __sx_str_rep __sx_str_substr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_pad - 文字列を指定された長さになるように埋める（内部用）
##
## 使い方:
##   __sx_str_pad 結果変数名 文字列 長さ [埋め込み文字列]
##
## 説明:
##   sx_str_pad の内部実装。引数チェックは行わない。
##   長さは10進整数表記（任意の符号付き、先行する 0 なし）を前提とする。
##   埋め込み文字列が空の場合は何もせず成功を返す。
##   文字列長と数値引数の絶対値が数値範囲内なら算術、それ以外は多倍長で処理する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_slen Q_plen Q_needed Q_cnt Q_rep Q_fill Q_type|])dnl

__sx_str_pad() {
	set -- "${1}" "${2-}" "${3-0}" "${4- }"

	case "${4:+${3}}" in '' | 0 | [+-]0*)
		M_VAR_SET([|${1}|], [|${2}|])
		return
	esac

	Q_slen="${#2}"
	Q_plen="${#4}"
	Q_needed="${3#[+-]}"

	# 絶対値で判定し、負の最小値も多倍長演算に回す。
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_slen}" "${Q_plen}" "${Q_needed}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	# 減算前に比較し、被減数が減数未満になる場合はそのまま返す。
	"__sx_num_cmp_${Q_type}" "${Q_needed}" "${Q_slen}" || case "${?}" in [12])
		M_VAR_SET([|${1}|], [|${2}|])
		unset CLEANUP
		return
	esac

	"__sx_num_sub_${Q_type}" Q_needed "${Q_needed}" "${Q_slen}"
	"__sx_num_divceil_${Q_type}" Q_cnt "${Q_needed}" "${Q_plen}"
	__sx_str_rep Q_rep "${4}" "${Q_cnt}"
	__sx_str_substr Q_fill "${Q_rep}" 0 "${Q_needed}"

	case "${3}" in
		-*) M_VAR_SET([|${1}|], [|${2}${Q_fill}|]);;
		*) M_VAR_SET([|${1}|], [|${Q_fill}${2}|]);;
	esac

	unset CLEANUP
}
|], [|str_pad|])dnl
popdef([|CLEANUP|])dnl
