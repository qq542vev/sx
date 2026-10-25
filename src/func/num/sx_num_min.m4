M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_num_safe __sx_num_min __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_min - 与えられた数値の最小値を取得する
##
## 使い方:
##   sx_num_min 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   与えられた数値のうち最小のものを結果変数に格納する。
##   10進整数・16進数・8進数・小数・指数表記を受け付ける（sx_num_rel と同じ数値ドメイン）。
##   結果は最小値の元の表記のまま格納される。同値の場合は先に現れた値を採用する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE) — 数値が1つもない、または数値形式が不正
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_min() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_min "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_min|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	case "${#}" in 1)
		return M_EX_USAGE
	esac

	Q_res="${1}"
	shift

	__sx_num_is_num_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_min "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_min|])dnl
popdef([|CLEANUP|])dnl
