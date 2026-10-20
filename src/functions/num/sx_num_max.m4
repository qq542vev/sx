dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_num_safe __sx_num_max __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_max - 与えられた数値の最大値を取得する
##
## 使い方:
##   sx_num_max 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   与えられた数値のうち最大のものを結果変数に格納する。
##   10進整数・16進数・8進数・小数・指数表記を受け付ける（sx_num_rel と同じ数値ドメイン）。
##   結果は最大値の元の表記のまま格納される。同値の場合は先に現れた値を採用する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE) — 数値が1つもない、または数値形式が不正
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_max() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_max "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	case "${#}" in 1)
		return M_EX_USAGE
	esac

	Q_res="${1}"
	shift

	__sx_num_is_num_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_max "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_max|])dnl
popdef([|CLEANUP|])dnl
