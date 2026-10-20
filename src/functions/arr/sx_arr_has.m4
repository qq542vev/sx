dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arr_has __sx_arr_is_spec __sx_var_is_arr sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_has - 配列の全 spec が1要素以上に一致するか確認する
##
## 使い方:
##   sx_arr_has 配列名 [spec ...]
##   spec := 整数 | [始点][:終点[:刻み]]
##   整数は符号付き10進整数（+1 / -1 の接頭辞可、前ゼロなし、-0 は 0 とみなす）。
##   刻みは 0 以外でなければならない。省略した場合は 1 となるが、
##   第二コロンを書いた場合の空の刻みは不可である（s::t 形式では t 必須）。
##
## 説明:
##   指定された sx 配列に対し、各 spec を sx_arr_get と同一の解決
##   （正確な等差数列と定義域 [0, len) の交叉、t<0 では終端を含む逆半開区間）で評価し、
##   すべての spec が1要素以上に一致すれば 0 を返す（all 意味論）。
##   1つでも空の spec があれば 1 を返す。
##   単体・始点・終点は正確値に換算する（丸めなし）。
##   始点の省略時は t>0 なら 0、t<0 なら len-1 から開始する。
##   終点の省略時は t>0 なら末尾まで、t<0 なら先頭まで含む。
##   spec の形式検査は sx_arr_is_spec と同一である。
##   spec を指定しない場合は空真で成功する。
##
## 終了ステータス:
##    0  すべての spec が要素に一致 (SX_EX_OK)
##    1  1つ以上の spec が空
##   64  引数不正（配列名無効・spec 形式不正）(SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_arr|])dnl

sx_arr_has() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_has "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_arr "${1}" || return M_EX_DATAERR

	Q_arr="${1}"
	shift

	__sx_arr_is_spec "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	set -- "${Q_arr}" "${@}"
	unset CLEANUP

	__sx_arr_has "${@}" || return
}
|], [|arr_has|])dnl
popdef([|CLEANUP|])dnl
