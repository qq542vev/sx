M_REQUIRE([|__sx_num_divmod_nat0 __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_divmod_int - 符号付き整数の除算で整数商と余剰を同時に求める（内部用）
##
## 使い方:
##   __sx_num_divmod_int バインド形式 被除数 [除数]
##
## 説明:
##   sx_num_divmod_int の内部実装。引数チェックは行わない。
##   Truncated 規約: 商はゼロ方向へ丸め、余剰は被除数と同じ符号を持つ。
##   絶対値どうしの除算（q0, r0）の後に符号のみを適用する。
##   q = sign(u)×sign(v)×q0、r = sign(u)×r0 であり、
##   q0 や r0 が 0 のときは "-0" を作らない。

define([|CLEANUP|], [|Q_bind Q_q Q_r Q_us Q_vs|])dnl

__sx_num_divmod_int() {
	__sx_var_bind_init "${1}"
	set -- "${1}" "${2:-0}" "${3:-1}"
	Q_us=0
	Q_vs=0

	case "${2}" in -*)
		Q_us=1
	esac

	case "${3}" in -*)
		Q_vs=1
	esac

	__sx_num_divmod_nat0 'Q_q:Q_r:' "${2#[+-]}" "${3#[+-]}"

	case "$((Q_us ^ Q_vs))${Q_q}" in 1[!0]*)
		M_STR_PREPEND([|Q_q|], [|-|])
	esac

	__sx_var_ubind Q_bind "${1}" "${Q_q}" || {
		unset CLEANUP
		return
	}

	case "${Q_us}${Q_r}" in 1[!0]*)
		M_STR_PREPEND([|Q_r|], [|-|])
	esac

	__sx_var_ubind Q_bind "${Q_bind}" "${Q_r}" || :

	unset CLEANUP
}
|], [|num_divmod_int|])dnl
popdef([|CLEANUP|])dnl
