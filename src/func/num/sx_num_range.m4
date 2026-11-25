M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_slice __sx_num_range __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_range - 数値の範囲を生成する
##
## 使い方:
##   sx_num_range bind [spec...]
##
## 説明:
##   各 spec（整数 | [始点]:終点[:刻み]）を順に評価し、生成した数値を
##   連結して bind に格納する。単体整数 N は 0:N として扱う。
##   始点省略は 0、刻み省略は 1。コロン形式では終点は必須。
##   第2コロンを書いた場合は刻みが必須であり、刻みは 0 以外でなければならない。
##   終了値は含まない (exclusive)。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  書き込み不可 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_dest|])dnl

sx_num_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_range "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_range|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_dest="${1}"
	shift

	__sx_num_is_slice "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_range "${Q_dest}" "${@}"
	unset CLEANUP
}
|], [|num_range|])dnl
popdef([|CLEANUP|])dnl
