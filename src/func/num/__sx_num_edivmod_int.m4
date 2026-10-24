M_REQUIRE([|__sx_num_add1_nat0 __sx_num_divmod_nat0 __sx_num_sub_nat0 __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_edivmod_int - ユークリッド除算で整数商と余剰を同時に求める（内部用）
##
## 使い方:
##   __sx_num_edivmod_int バインド形式 被除数 [除数]
##
## 説明:
##   sx_num_edivmod_int の内部実装。引数チェックは行わない。
##   絶対値どうしの除算（q0, r0: 0 ≤ r0 < |v|）の後にユークリッド規約を適用する。
##   - r0 = 0 のとき: q = sign(u)×sign(v)×q0、r = 0
##   - r0 ≠ 0 かつ u ≥ 0 のとき: q = ±q0（v < 0 なら負）、r = r0
##   - r0 ≠ 0 かつ u < 0 のとき: q = ±(q0 + 1)（v < 0 なら正）、r = |v| - r0
##   q0 + 1 は __sx_num_add1_nat0、|v| - r0 は __sx_num_sub_nat0 で算出し、
##   ネイティブ算術幅を超えても多倍長のまま正しく補正する。

define([|CLEANUP|], [|Q_bind Q_q Q_r Q_us Q_vs|])dnl

__sx_num_edivmod_int() {
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

	case "${Q_q}:${Q_r}:${Q_us}${Q_vs}" in
		*:[!0]*:1?)
			M_NUM_INCRM1([|Q_q|])

			case "${Q_vs}" in 0)
				M_STR_PREPEND([|Q_q|], [|-|])
			esac

			__sx_var_ubind Q_bind "${1}" "${Q_q}" || {
				unset CLEANUP
				return M_EX_OK
			}

			__sx_num_sub_nat0 Q_r "${3#[+-]}" "${Q_r}"
			;;
		[!0]*:0:10 | [!0]*:*:01) Q_q="-${Q_q}";&
		*)
			__sx_var_ubind Q_bind "${1}" "${Q_q}" || {
				unset CLEANUP
				return M_EX_OK
			}
			;;
	esac

	__sx_var_ubind Q_bind "${Q_bind}" "${Q_r}" || :

	unset CLEANUP
}
|], [|num_edivmod_int|])dnl
popdef([|CLEANUP|])dnl
