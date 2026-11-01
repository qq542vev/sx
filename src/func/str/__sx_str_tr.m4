M_REQUIRE([|__sx_str_tr0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_tr - 文字単位の対応表を分割し、共通の置換処理へ渡す（内部用）
##
## 使い方:
##   __sx_str_tr バインド形式 [文字列 [from文字列 [to文字列 [limit]]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   to を1文字ずつ位置パラメータに格納し、__sx_str_tr0 へ渡す。
##   置換不要の場合は to の分割を省き、結果のバインドだけを共通処理に委譲する。
##   limit は空文字列、または符号付き10進整数（先行ゼロなし）を前提とする。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_to Q_lim|])dnl

__sx_str_tr() {
	Q_to="${4-}"
	set -- "${1}" "${2-}" "${3-}" "${5-}"
	Q_lim="${4:-${#2}}"

	case "${2:+${3:+${Q_lim#[+-]}:${2}}}" in [!0]*:*["${3}"]*)
		while M_STR_NE([|"${Q_to:+X}"|], [|''|]); do
			set -- "${@}" "${Q_to%%"${Q_to#?}"}"
			Q_to="${Q_to#?}"
		done
	esac

	unset CLEANUP
	__sx_str_tr0 "${@}"
}
|], [|str_tr|])dnl
popdef([|CLEANUP|])dnl
