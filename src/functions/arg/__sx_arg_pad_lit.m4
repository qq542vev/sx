dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_arith __sx_num_sub_nat0 __sx_var_bind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_pad_lit - 引数リストをパディングする（内部用）
##
## 使い方:
##   __sx_arg_pad_lit スキーマ 長さ パディング値 [値 ...]
##
## 説明:
##   sx_arg_pad の内部実装。引数チェックは行わない。
##   長さの絶対値と元の個数が算術域内なら算術、それ以外は多倍長で不足件数を計算する。
##   不足件数は比較後に非負の差として求め、終了判定に算術を使用しない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_len Q_val Q_needed Q_arg Q_size Q_type|])dnl

__sx_arg_pad_lit() {
	Q_bind="${1}"
	Q_len="${2}"
	Q_val="${3}"
	Q_needed=0

	shift 4
	Q_size="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_len#[+-]}" "${Q_size}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	"__sx_num_cmp_${Q_type}" "${Q_len#[+-]}" "${Q_size}" || case "${?}" in 3)
		"__sx_num_sub_${Q_type}" Q_needed "${Q_len#[+-]}" "${Q_size}"
	esac

	# 左パディング（needed <= 0 なら何もしない）
	case "${Q_len}" in -*)
		while M_STR_NE([|"${Q_needed}"|], [|0|]) && M_STR_NE([|"${Q_bind}"|], [|''|]); do
			__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" || {
				unset CLEANUP
				return
			}

			"__sx_num_sub1_${Q_type}" Q_needed "${Q_needed}"
		done
	esac

	# 入力値を結合
	__sx_var_bind Q_bind "${Q_bind}" "${@}" || {
		unset CLEANUP
		return
	}

	# 右パディング（needed <= 0 なら何もしない）
	case "${Q_len}" in [!-]*)
		while M_STR_NE([|"${Q_needed}"|], [|0|]) && M_STR_NE([|"${Q_bind}"|], [|''|]); do
			__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" || break

			"__sx_num_sub1_${Q_type}" Q_needed "${Q_needed}"
		done
	esac

	unset CLEANUP
}
|], [|arg_pad_lit|])dnl
popdef([|CLEANUP|])dnl
