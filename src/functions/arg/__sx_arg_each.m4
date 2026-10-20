dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_each - 引数リストの各要素に対してコールバック関数を実行する（内部用）
##
## 使い方:
##   __sx_arg_each コールバック [値 ...]
##
## 説明:
##   sx_arg_each の内部実装。引数チェックは行わない。
##   状態は位置変数で管理し、for ループでイテレートする。
##   呼び出し時の引数個数が算術域内なら算術、それ以外は多倍長で添字を更新する。
##   管理用の3項目は負のカウンタを算術で進めてスキップする。
##   コールバック呼び出し前に一時変数を解放し、再入時も状態を保持する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  コールバックの終了ステータス
##

define([|CLEANUP|], [|Q_arg Q_next|])dnl

__sx_arg_each() {
	case "${2+X}" in '')
		return M_EX_OK
	esac

	# $1: 添字、$2: 数値経路、$3: コールバック、$4以降: データ
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#}"; then
		set -- -3 arith "${@}"
	else
		set -- -3 nat0 "${@}"
	fi

	for Q_arg in "${@}"; do
		case "${1}" in
			-*) Q_next=$((${1} + 1));;
			*) "__sx_num_add1_${2}" Q_next "${1}";;
		esac

		set -- "${Q_next}" "${2}" "${3}" "${Q_arg}"

		case "${1}" in -* | 0)
			continue
		esac

		unset CLEANUP
		"${3}" "${4}" "${1}" || return
	done

	unset CLEANUP
}
|], [|arg_each|])dnl
popdef([|CLEANUP|])dnl
