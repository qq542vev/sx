M_REQUIRE([|__sx_num_cmp_arith __sx_num_cmp_fixed __sx_num_norm __sx_num_rel_classify|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_rel - 数値間の関係を確認する（内部用）
##
## 使い方:
##   __sx_num_rel [数値 | 演算子 ...]
##
## 説明:
##   sx_num_rel の内部実装。
##   引数チェックを行わずに数値と演算子の関係を順次評価する。

define([|CLEANUP|], [|Q_op Q_lhs Q_lcls Q_rcls Q_arg|])dnl

__sx_num_rel() {
	Q_op='eq'

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			eq | '==') Q_op=eq;;
			ne | '!=') Q_op=ne;;
			lt | '<')  Q_op=lt;;
			le | '<=') Q_op=le;;
			gt | '>')  Q_op=gt;;
			ge | '>=') Q_op=ge;;
			*) ! :;;
		esac && continue

		__sx_num_rel_classify "${Q_arg}" || Q_rcls="${?}"

		case "${Q_rcls}" in
			1) : $((Q_arg += 0));;
			2) Q_arg="${Q_arg#+}";;
			*)
				__sx_num_norm Q_arg "${Q_arg}"
				__sx_num_rel_classify "${Q_arg}" || Q_rcls="${?}"
				;;
		esac

		case "${Q_lhs+X}" in X)
			case "${Q_lcls}:${Q_rcls}" in
				1:1) __sx_num_cmp_arith "${Q_lhs}" "${Q_arg}";;
				*) __sx_num_cmp_fixed "${Q_lhs}" "${Q_arg}";;
			esac || case "${Q_op}:${?}" in
				eq:2 | ne:1 | ne:3 | lt:1 | le:1 | le:2 | gt:3 | ge:2 | ge:3) ;;
				*)
					unset CLEANUP
					return 1
					;;
			esac
		esac

		Q_lcls="${Q_rcls}"
		Q_lhs="${Q_arg}"
	done

	unset CLEANUP
}
|], [|num_rel|])dnl
popdef([|CLEANUP|])dnl
