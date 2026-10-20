dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_fn_anon __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid sx_fn_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_fn_anon - 一意な名前を持つ匿名関数を生成して定義する
##
## 使い方:
##   sx_fn_anon 結果変数名（またはバインド形式） 本体 [本体 ...]
##
## 説明:
##   指定された本体（コマンド文字列）を持つ関数を一意な名前で定義し、
##   その名前を結果変数に格納する。複数の本体を指定した場合は、
##   それぞれの関数名がスペース区切りで格納される。
##   生成された関数名は sx_fn_anon_N の形式となる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  本体の構文が不正 (SX_EX_USAGE)

define([|CLEANUP|], [|Q_bind Q_arg|])dnl

sx_fn_anon() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_anon "${@}" || return; return;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		shift
		set -- "${@}" "sx_fn_anon_0=${Q_arg}"
	done

	sx_fn_is_valid "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	for Q_arg in "${@}"; do
		shift
		set -- "${@}" "${Q_arg#sx_fn_anon_0=}"
	done

	__sx_fn_anon "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|fn_anon|])dnl
popdef([|CLEANUP|])dnl
