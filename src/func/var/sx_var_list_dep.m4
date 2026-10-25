M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_bind __sx_var_is_bindable __sx_var_is_name __sx_var_list_dep|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_var_list_dep - 指定された変数に関連するすべての変数名を取得する
##
## 使い方:
##   sx_var_list_dep 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   指定された変数名、およびそれらがsx配列である場合に再帰的に含まれる
##   すべての変数名（_len, _0, _1...）をスペース区切りの文字列として取得し、
##   指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_var_list_dep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_list_dep "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_var_list_dep|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	__sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_var_list_dep "${Q_bind}" "${@}"

	unset CLEANUP
}
|], [|var_list_dep|])dnl
popdef([|CLEANUP|])dnl
