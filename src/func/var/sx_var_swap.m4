M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_chain __sx_var_is_copyable __sx_var_swap|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_var_swap - 変数を連鎖的にローテーションする
##
## 使い方:
##   sx_var_swap [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   指定された連鎖式内の変数群をローテーションさせる。
##   連鎖式には以下の形式が使用できる：
##     A-B-C : 右方向に回転 (C の値を A に、A の値を B に、B の値を C に移動)
##     A=B=C : 左方向に回転 (A の値を C に、C の値を B に、B の値を A に移動)
##   例: v1-v2-v3 の場合、v3 の値を v1 に、v1 の値を v2 に、v2 の値を v3 に移動する。
##   引数が単一の変数名の場合は、何もせず成功する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_arg Q_chain|])dnl

sx_var_swap() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_swap "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_var_swap|])

	__sx_var_is_chain "${@}" || return M_EX_USAGE

	Q_chain=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) M_STR_APPEND([|Q_chain|], [|"${Q_arg##*=}=${Q_arg} "|]);;
			*-*) M_STR_APPEND([|Q_chain|], [|"${Q_arg}-${Q_arg%%-*} "|]);;
		esac
	done

	eval __sx_var_is_copyable "${Q_chain}" || {
		unset CLEANUP
		return M_EX_NOPERM
	}

	__sx_var_swap "${@}"
	unset CLEANUP
}
|], [|var_swap|])dnl
popdef([|CLEANUP|])dnl
