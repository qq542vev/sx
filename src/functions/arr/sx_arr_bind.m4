dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arr_bind __sx_arr_is_ebind __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_bind - 配列対応バインドで変数を順次割り当てる
##
## 使い方:
##   sx_arr_bind bind_res chain_res bind varname1 [varname2 ...]
##
## 説明:
##   拡張バインド形式（sx_var_is_ebind 参照）を解析し、chain（src-dst ペア）
##   と残り bind を生成して __sx_arr_bind に委譲する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  書き込み権限なし (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bres Q_cres Q_bind|])dnl

sx_arr_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_bind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name ${1:+"${1}"} "${2-}" || return M_EX_USAGE
	__sx_var_is_rw ${1:+"${1}"} "${2}" || return M_EX_NOPERM
	__sx_arr_is_ebind "${3-!}" || return M_EX_USAGE

	Q_bres="${1}"
	Q_cres="${2}"
	Q_bind="${3}"

	shift 3

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	set -- "${Q_bres}" "${Q_cres}" "${Q_bind}" "${@}"

	unset CLEANUP

	__sx_arr_bind "${@}" || return
}
|], [|arr_bind|])dnl
popdef([|CLEANUP|])dnl
