dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_RFIND_GLOB SX_ARG_RFIND_TEXT SX_CFG_NUM_RANGE __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_var_bind __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_rfind_lit - 引数リストから指定された値を後ろ向きに探す（内部用: リテラル/Glob）
##
## 使い方:
##   __sx_arg_rfind_lit 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   sx_arg_rfind のリテラル/Glob検索実装。末尾から先頭に向かって検索する。
##   引数チェックは行わない。
##   データ個数が算術域内なら算術、それ以外は多倍長で添字を減らす。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった

define([|CLEANUP|], [|Q_bind Q_match Q_glob Q_text Q_i Q_arg Q_sts Q_type|])dnl

__sx_arg_rfind_lit() {
	Q_bind="${1}"
	Q_match="${2}"
	Q_glob=$(((${3} & SX_ARG_RFIND_GLOB) != 0))
	Q_text=$(((${3} & SX_ARG_RFIND_TEXT) != 0))

	shift 3
	Q_i="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_i}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	while M_STR_NE([|"${Q_i}"|], [|0|]) && M_STR_NE([|"${Q_bind}"|], [|''|]); do
		eval Q_arg=\"\${${Q_i}}\"

		case "${Q_glob}${Q_arg}" in "0${Q_match}" | 1${Q_match})
			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_i}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${Q_arg}";;
			esac

			Q_sts=M_EX_OK
		esac

		"__sx_num_sub1_${Q_type}" Q_i "${Q_i}"
	done

	set -- "${Q_sts-1}"

	unset CLEANUP
	return "${1}"
}
|], [|arg_rfind_lit|])dnl
popdef([|CLEANUP|])dnl
