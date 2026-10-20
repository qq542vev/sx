M_REQUIRE([|SX_CFG_NUM_RANGE SX_CFG_SKIP_CHK __sx_num_is_num_safe __sx_num_rel sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_rel - 数値間の関係を確認する
##
## 使い方:
##   sx_num_rel [数値1 [演算子1 数値2 ...]]
##
## 説明:
##   数値と演算子を交互に指定し、すべての関係が満たされるかを確認する。
##   演算子には以下が使用可能：
##     eq, ==   : 等しい
##     ne, !=  : 等しくない
##     lt, <   : 未満
##     le, <=  : 以下
##     gt, >   : より大きい
##     ge, >=  : 以上
##
## 終了ステータス:
##    0  すべての条件を満たす (SX_EX_OK)
##    1  条件を満たさない引数が含まれる
##   64  引数不正 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_rel() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_rel "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			eq | '==' | ne | '!=' | lt | '<' | le | '<=' | gt | '>' | ge | '>=') continue;;
		esac

		__sx_num_is_num_safe "${Q_arg}" || {
			unset CLEANUP
			return M_EX_USAGE
		}
	done

	unset CLEANUP

	__sx_num_rel "${@}" || return
}
|], [|num_rel|])dnl
popdef([|CLEANUP|])dnl
