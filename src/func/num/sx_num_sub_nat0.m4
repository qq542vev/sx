M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_cmp_nat0 __sx_num_is_nat0_base __sx_num_sub_nat0 __sx_var_is_name __sx_var_is_rw sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_sub_nat0 - 2つの絶対値の差（被減数 - 減数）を計算する
##
## 使い方:
##   sx_num_sub_nat0 結果変数名 被減数 減数
##
## 説明:
##   符号なし10進整数の減算（被減数 - 減数）を行う。
##   引数の検証を行い、すべて符号なし整数（nat0）であることを確認する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 数値以外、符号付き整数、または被減数 &lt; 減数
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_sub_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_sub_nat0 "${@}" || return; return 0;; esac

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_nat0_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_cmp_nat0 "${1-0}" "${2-0}" || case "${?}" in 1)
		unset CLEANUP
		return M_EX_USAGE
	esac

	__sx_num_sub_nat0 "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_sub_nat0|])dnl
popdef([|CLEANUP|])dnl
