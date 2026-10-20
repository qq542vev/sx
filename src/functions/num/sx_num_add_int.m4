dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_add_int __sx_num_is_int_base __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_add_int - 複数の符号付き整数を加算する
##
## 使い方:
##   sx_num_add_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を加算する。正数群と負数群に分けて絶対値加算を行い、
##   最後に絶対値を比較して符号を決定する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 整数として不正な値が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_add_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_add_int "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_int_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_add_int "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_add_int|])dnl
popdef([|CLEANUP|])dnl
