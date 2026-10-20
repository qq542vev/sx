M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_arr_cat __sx_arr_is_bind __sx_arr_is_bindable __sx_var_is_arr sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_cat - 複数の配列を連結する
##
## 使い方:
##   sx_arr_cat bind arr1 [arr2 ...]
##
## 説明:
##   指定された sx 配列（arr1, arr2, ...）の全要素を順方向に連結した要素ストリームを生成する
##   （cat = concatenate）。
##   分配先をバインド形式（sx_arr_is_bind 参照。例: x, 2a:x, a:10b:3c:1d:e）で指定できる。
##   `@` を含む形式は無効である。bind の省略は不可であり、引数なしは引数不正となる。
##   これは拡張機能で、連結したストリームをどの変数群へ割り当てるかを選ぶだけのもの
##   （単一の末尾セグメント（x 等）なら純粋な連結になる）。他の sx_arr_* 関数にも導入される
##   共通オプションである。
##
##   例:
##     sx_arr_cat x      a1 a2   # a1=[a,b,c], a2=[d,e] なら x=[a,b,c,d,e]
##     sx_arr_cat 2a:x   a1 a2   # 上記ストリームなら a=[a,b], x=[c,d,e]
##
##   分配先の扱い（sx_arr_is_bindable と同じ分類）:
##     - 数値先行セグメント（2b 等）と末尾セグメント（x 等）は配列として生成する。
##       割当日が無ければ空配列、一部のみならその要素数で生成する（切り詰め成功）。
##     - 先頭・中間の素セグメント（a:10b... の a 等）はスカラーとして扱い配列化しない。
##
##   トランザクション: まず全書き込み先の書き込み可否を一括検査し、一部でも不可なら
##   一切書き込まず SX_EX_NOPERM を返す（中途半端な書き込みを行わない）。
##
## 注意:
##   分配先に既存配列を使う場合は、事前に sx_var_unset を明示的に呼び出してから呼び出すこと。
##   源配列と分配先の名前が重複する場合は未定義。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_arr_cat() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_cat "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_arr_is_bind "${1-!}" || return M_EX_USAGE

	__sx_arr_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_var_is_arr "${@}" || {
		unset CLEANUP
		return M_EX_DATAERR
	}

	__sx_arr_cat "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|arr_cat|])dnl
popdef([|CLEANUP|])dnl
