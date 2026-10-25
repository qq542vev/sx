M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_norm __sx_var_is_bind __sx_var_is_bindable sx_num_is_num_safe|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_norm - 数値を10進固定小数点形式に正規化する
##
## 使い方:
##   sx_num_norm バインド形式 [数値1 [数値2 ...]]
##
## 説明:
##   引数で指定された各数値を、10進固定小数点形式に正規化し、バインド形式に従って
##   変数に代入する。
##   正規化の内容：
##   - 16進数（0x...）や8進数（0...）を10進整数に変換。
##   - 指数表記（1.2e+3）を固定小数点形式（1200）に展開。
##   - 小数点以下の不要な '0' を削除（6.0 -> 6, 1.20 -> 1.2）。
##   - 符号（+ / -）は維持される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正: 無効なバインド形式、または数値形式が正しくない (SX_EX_USAGE)
##   77  結果変数が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_num_norm() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_norm "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_num_norm|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	sx_num_is_num_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_norm "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|num_norm|])dnl
popdef([|CLEANUP|])dnl
