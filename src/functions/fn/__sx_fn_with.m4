dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SEP __sx_fn_anon|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_fn_with - 一時的な匿名関数を定義してコマンドを実行する（内部用）

define([|CLEANUP|], [|Q_fns Q_map Q_arg Q_anon Q_tmp|])dnl

__sx_fn_with() {
	Q_fns=
	Q_map=' '

	# 1. エイリアスの解析と関数定義
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${SX_CFG_SEP-}") shift; break;;
			*=*)
				__sx_fn_anon Q_anon "${Q_arg#*=}"
				M_STR_APPEND([|Q_fns|], [|"${Q_anon} "|])
				M_STR_APPEND([|Q_map|], [|"${Q_arg%%=*}:${Q_anon} "|])
				shift
				;;
			*) break;;
		esac
	done

	# 2. コマンド引数の置換とクォート処理
	for Q_arg in "${@}"; do
		case "${Q_map}" in *" ${Q_arg}:"*)
			Q_tmp="${Q_map#*" ${Q_arg}:"}"
			Q_arg="${Q_tmp%% *}"
		esac

		shift
		set -- "${@}" "${Q_arg}"
	done

	# 3. 実行と状態の保持 (set -e 対策)
	eval "unset CLEANUP; \"\${@:-:}\" && set -- '${Q_fns}' 0 || set -- '${Q_fns}' \"\${?}\""

	# 4. 後始末
	case "${1:+X}" in X)
		eval "unset -f ${1}"
	esac

	return "${2}"
}
|], [|fn_with|])dnl
popdef([|CLEANUP|])dnl
