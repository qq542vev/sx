M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_is_bind __sx_arr_is_bindable __sx_arr_pop __sx_var_is_arr __sx_var_is_name __sx_var_is_rw_deep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_pop - 配列の末尾から要素を取り出して割り当てる
##
## 使い方:
##   sx_arr_pop bind 配列名
##
## 説明:
##   指定された sx 配列の末尾から、bind の各セグメントが示す個数ぶんの要素を
##   取り出して割り当てる（または破棄する）拡張 pop。
##   bind は固定スロット形式であり、各セグメントの末尾に「:」を付けて指定する
##   （例: x: はスカラー x へ 1 個、2v: は配列 v へ 2 個、1: は 1 個を破棄）。
##   bind に `@` を含む形式は無効である（sx_arr_is_bind 参照）。
##   合計スロット数は各セグメントの個数の合計であり、元配列の要素数を超える
##   場合は一切書き込まずに 1 を返す（トランザクション）。
##
##   セグメントの種類:
##     - N名前:  配列「名前」へ N 個割り当てる（N は 1 以上の整数）
##     - 名前:   スカラー「名前」へ 1 個割り当てる
##     - N:      値は割り当てずに N 個破棄する
##
##   取り出しは末尾から行い、先頭セグメントが最後の要素を受け取る
##   （例: sx_arr_pop x:y: a （a=[1,2]）なら x=2, y=1 となり a は空になる）。
##   成功すると元配列は残った要素のみになり、長さとリビジョンが更新される。
##
##   末尾「:」の無い bind（x や a:b 等）も bind として受理はされるが、
##   末尾セグメントが「残り全部」扱いになるため実質的に常に要素不足となり 1 を返す。
##
## 注意:
##   分配先に既存配列を使う場合は、事前に sx_var_unset を明示的に呼び出してから呼び出すこと。
##   元配列と分配先の名前が重複する場合は未定義。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  合計スロット数が要素数を超えている（無変更）
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [||])dnl

sx_arr_pop() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_pop "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arr_pop|])

	__sx_arr_is_bind "${1-!}" || return M_EX_USAGE

	__sx_arr_is_bindable "${1}" || return M_EX_NOPERM

	__sx_var_is_name "${2-}" || return M_EX_USAGE

	__sx_var_is_arr "${2}" || return M_EX_DATAERR

	__sx_var_is_rw_deep "${2}" || return M_EX_NOPERM

	__sx_arr_pop "${@}" || return
}
|], [|arr_pop|])dnl
popdef([|CLEANUP|])dnl
