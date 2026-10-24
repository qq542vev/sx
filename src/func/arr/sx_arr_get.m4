M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arr_get __sx_arr_is_bind __sx_arr_is_bindable __sx_arr_is_spec __sx_var_is_arr sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_get - 配列から指定要素を順序保持で切り出して分配する
##
## 使い方:
##   sx_arr_get bind 配列名 [spec ...]
##   spec := 整数 | [始点][:終点[:刻み]]
##   整数は符号付き10進整数（+1 / -1 の接頭辞可、前ゼロなし、-0 は 0 とみなす）。
##   刻みは 0 以外でなければならない。省略した場合は 1 となるが、
##   第二コロンを書いた場合の空の刻みは不可である（s::t 形式では t 必須）。
##
## 説明:
##   指定された sx 配列から spec の順に要素を取り出し、要素ストリームを
##   bind（sx_arr_cat と同一の配列分配形式。例: x, 2a:x）へ分配する（get = 取得）。
##   sx_arr_has（全 spec が1要素以上に一致すれば 0 を返す）とは異なり、
##   空の spec はスキップし、結果が空でも 0 を返して空配列を確定する。
##   spec なしの場合も空配列を確定して成功する。
##   単体指定:
##     正確値に換算する（負は len+n、そのまま負に落ちれば空）。
##     換算値が [0, len) に収まる場合のみ取り出す。
##   範囲指定 s:e[:t]（始点・終点は省略可。: のみ。- / ~ 区切りは不可）:
##     正確な等差数列と定義域 [0, len) の交叉を順に取り出す。
##     始点・終点は負なら len+n に換算する（丸めなし。負に落ちてもよい）。
##     始点を省略した場合は t>0 なら 0、t<0 なら len-1 から開始する。
##     Python の range と同様に開始を含み、t>0 では終了を含まない（exclusive）。
##     t<0 では終了も含む（逆半開区間）。
##     t を省略した場合は 1 となる。空の刻みは不可。
##     s==e は t>0 で空、s<e かつ t<0 は空、e<s かつ 0<t は空である。
##     終点を省略した場合は t>0 なら末尾まで、t<0 なら先頭まで含む。
##     例: arr=[a,b,c,d,e] なら 0:3→a,b,c、0:5:2→a,c,e、
##     3:0→空（逆方向は 3:0:-1→d,c,b,a）、2::-1→c,b,a、-6:5:2→b,d、6:10→空。
##
## 注意:
##   分配先に既存配列を使う場合は、事前に sx_var_unset を明示的に呼び出してから呼び出すこと。
##   源配列と分配先の名前が重複する場合は未定義。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK。空結果・spec なしも空配列で成功)
##   64  引数不正（bind 形式不正、spec 形式不正を含む）(SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind Q_arr|])dnl

sx_arr_get() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_get "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_arr_is_bind "${1-!}" || return M_EX_USAGE

	__sx_arr_is_bindable "${1}" || return M_EX_NOPERM

	sx_var_is_name "${2-}" || return M_EX_USAGE

	__sx_var_is_arr "${2}" || return M_EX_DATAERR

	Q_bind="${1}"
	Q_arr="${2}"
	shift 2

	__sx_arr_is_spec "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_arr_get "${Q_bind}" "${Q_arr}" "${@}"
	unset CLEANUP
}
|], [|arr_get|])dnl
popdef([|CLEANUP|])dnl
