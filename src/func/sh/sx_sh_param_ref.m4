M_REQUIRE([|SX_CFG_SKIP_CHK __sx_sh_param_ref __sx_sh_is_param __sx_var_is_name __sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_sh_param_ref - シェルパラメータの参照文字列を生成する
##
## 使い方:
##   sx_sh_param_ref 結果変数名 区切り文字 [パラメータ1 ...]
##
## 説明:
##   指定されたシェルパラメータを "${parameter}" 形式の参照に変換し、
##   区切り文字で結合した文字列を結果変数に格納する。
##   パラメータには変数名、位置パラメータ、特殊パラメータを指定できる。
##   パラメータの設定有無や値は検査しない。
##   区切り文字に半角空白を指定すると、eval "set -- ${結果}" のように
##   シェルコードの単語列として利用できる。半角空白以外を指定した場合は
##   シェルコードとしての評価を前提としない。
##   "${@}" や "${*}" は評価時の展開規則が通常の変数と異なる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)

define([|CLEANUP|], [|Q_res Q_sep|])dnl

sx_sh_param_ref() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_sh_param_ref "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_sh_param_ref|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	Q_res="${1}"
	Q_sep="${2-}"
	shift ${2+'2'}

	__sx_sh_is_param "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_sh_param_ref "${Q_res}" "${Q_sep}" "${@}"
	unset CLEANUP
}
|], [|sh_param_ref|])dnl
popdef([|CLEANUP|])dnl
