M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_is_bind __sx_arr_is_bindable __sx_arr_pop_raw __sx_var_is_arr __sx_var_is_name __sx_var_is_rw_deep|])dnl
### sx_arr_pop_raw - リビジョンを更新せず配列の末尾から要素を取り出して割り当てる
##
## 使い方:
##   sx_arr_pop_raw bind 配列名
##
## 説明:
##   sx_arr_pop と同じ引数検証を行い、末尾から要素を取り出して割り当てる。
##   bind の形式・分配順は sx_arr_pop と同じである。例えば x:y: は末尾から
##   x、y の順にスカラーへ割り当て、2v: は配列 v へ 2 個、1: は 1 個を破棄する。
##   @ を含む bind は無効。末尾の : がない bind も受理するが、末尾セグメントが
##   残り全部扱いになるため、実質的に常に要素不足として 1 を返す。
##   要素不足の場合は、元配列と分配先を一切変更しない。
##   元配列のリビジョンは更新しない。
##   分配先に新しく作る配列のリビジョンは通常どおり発行するため、
##   SX_SYS_REV が更新される場合がある。
##
## 注意:
##   分配先に既存配列を使う場合は、事前に sx_var_unset を明示的に呼び出すこと。
##   元配列と分配先の名前が重複する場合は未定義。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  合計スロット数が要素数を超えている（無変更）
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arr_pop_raw() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_pop_raw "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arr_pop_raw|])

	__sx_arr_is_bind "${1-!}" || return M_EX_USAGE
	__sx_arr_is_bindable "${1}" || return M_EX_NOPERM
	__sx_var_is_name "${2-}" || return M_EX_USAGE
	__sx_var_is_arr "${2}" || return M_EX_DATAERR
	__sx_var_is_rw_deep "${2}" || return M_EX_NOPERM

	__sx_arr_pop_raw "${@}" || return
}
