M_REQUIRE([|SX_CFG_NUM_RANGE SX_STR_ISEP_CB SX_STR_ISEP_POST SX_STR_ISEP_PRE SX_STR_SUB_CB SX_STR_SUB_GLOB __sx_num_is_int_fit_dec __sx_str_isep __sx_str_sub_cb __sx_str_sub_isep_adapt __sx_str_sub_lit __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_sub - 方向・上限・数値経路を準備して置換を振り分ける（内部用）
##
## 使い方:
##   __sx_str_sub バインド形式 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   回数制限は符号付き10進整数、または無制限を表す空文字列を前提とする。
##   符号と絶対値は文字列として分離し、上限0は置換せずに結果をバインドする。
##   空パターンおよび Glob の * のみのパターンは __sx_str_isep に委譲する。
##   非空パターンの成功回数は元文字列長以下なので、文字列長から数値経路を選ぶ。
##   コールバックへ委譲する前に準備用変数を解放する。
##
## 終了ステータス:
##    0  成功
##   非0  コールバックの終了ステータス

define([|CLEANUP|], [|Q_abs Q_dir Q_type Q_flags Q_cb|])dnl

__sx_str_sub() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "${5-}" "${6:-0}"

	case "${5}" in 0 | [+-]0)
		__sx_var_bind_init "${1}"
		__sx_var_bind '' "${1}" "${2}" 0 || :
		return
	esac

	Q_abs="${5#[+-]}"
	Q_flags="${6}"
	Q_dir=$((${5%%"${Q_abs}"}1))

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|Q_flags & SX_STR_SUB_GLOB|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		set -- "${1}" "${2}" "${4}" "${Q_dir}" "${Q_abs}" "$((Q_flags & SX_STR_SUB_CB))"
		unset CLEANUP

		case "${6}" in
			0) __sx_str_isep "${1}" "${2}" "${3}" "${4}" "${5}" "$((SX_STR_ISEP_PRE | SX_STR_ISEP_POST))";;
			*) Q_cb="${3}" __sx_str_isep "${1}" "${2}" __sx_str_sub_isep_adapt "${4}" "${5}" "$((SX_STR_ISEP_PRE | SX_STR_ISEP_POST | SX_STR_ISEP_CB))";;
		esac || {
			set -- "${?}"
			unset Q_cb
			return "${1}"
		}

		unset Q_cb
		return
	fi

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#2}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	set -- "${1}" "${2}" "${3}" "${4}" "${Q_abs}" "$((Q_flags & SX_STR_SUB_GLOB))" "${Q_type}" "${Q_dir}" "$((Q_flags & SX_STR_SUB_CB))"
	unset CLEANUP

	case "${9}" in
		0) __sx_str_sub_lit "${@}";;
		*) __sx_str_sub_cb "${@}";;
	esac || return
}

|], [|str_sub|])dnl
popdef([|CLEANUP|])dnl
