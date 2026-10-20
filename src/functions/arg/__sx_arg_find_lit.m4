dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_FIND_GLOB SX_ARG_FIND_TEXT SX_CFG_NUM_RANGE __sx_num_add1_arith __sx_num_add1_nat0 __sx_num_is_int_fit_dec __sx_var_bind __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_find_lit - 引数リストから指定された値を探す（内部用: リテラル/glob照合）
##
## 使い方:
##   __sx_arg_find_lit 結果変数名 検索対象 フラグ [値 ...]
##
## 説明:
##   __sx_arg_find から呼ばれる。先頭から末尾に向かって検索する。
##   引数は正規化済み。引数チェックは行わない。
##   データ個数が算術域内なら算術、それ以外は多倍長で添字を更新する。
##   添字を0から開始し、各要素の処理前に増やして末尾の余分な加算を避ける。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_bind Q_tgt Q_glob Q_text Q_i Q_arg Q_sts Q_type|])dnl

__sx_arg_find_lit() {
	Q_bind="${1}"
	Q_tgt="${2}"
	Q_glob=$(((${3} & SX_ARG_FIND_GLOB) != 0))
	Q_text=$(((${3} & SX_ARG_FIND_TEXT) != 0))
	Q_i=0

	shift 3

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${#}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	for Q_arg in "${@}"; do
		case "${Q_bind:+X}" in '')
			break
		esac

		"__sx_num_add1_${Q_type}" Q_i "${Q_i}"

		case "${Q_glob}${Q_arg}" in "0${Q_tgt}" | 1${Q_tgt})
			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_i}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${Q_arg}";;
			esac

			Q_sts=M_EX_OK
		esac
	done

	set -- "${Q_sts-1}"

	unset CLEANUP
	return "${1}"
}
|], [|arg_find_lit|])dnl
popdef([|CLEANUP|])dnl
