M_REQUIRE([|SX_STR_LF __sx_str_quote __sx_var_list_dep __sx_var_unset|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_copy_script - 変数のコピー用スクリプトを生成する（内部用）
##
## 使い方:
##   __sx_var_copy_script 結果変数名 [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   sx_var_copy_script の内部実装。
##   変数名列から右方向連鎖コピー用の実行スクリプトを生成する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_out Q_chain Q_dest Q_dep Q_src Q_vn Q_set Q_val Q_expr Q_unset|])dnl

__sx_var_copy_script() {
	Q_res="${1}"
	Q_out=
	shift

	for Q_chain in "${@}"; do
		Q_src=

		while
			case "${Q_chain}" in
				*=*) Q_dest="${Q_chain##*=}" Q_chain="${Q_chain%=*}";;
				*-*) Q_dest="${Q_chain%%-*}" Q_chain="${Q_chain#*-}";;
				*) Q_dest="${Q_chain}" Q_chain=;;
			esac

			case "${Q_src:+X}" in X)
				Q_expr= Q_unset=

				__sx_var_list_dep Q_dep "${Q_src}"

				eval set -- "${Q_dep}"

				for Q_vn in "${@}"; do
					eval "Q_set=\"\${${Q_vn}+X}\" Q_val=\"\${${Q_vn}-}\""
					case "${Q_set}" in
						X)
							__sx_str_quote Q_val "${Q_val}"

							M_STR_APPEND([|Q_expr|], [|"${Q_dest}${Q_vn#"${Q_src}"}=${Q_val} "|])
							;;
						*) M_STR_APPEND([|Q_unset|], [|"${Q_dest}${Q_vn#"${Q_src}"} "|]);;
					esac
				done

				M_STR_APPEND([|Q_out|], [|"__sx_var_unset ${Q_dest}${SX_STR_LF}${Q_expr}${SX_STR_LF}${Q_unset:+unset -v ${Q_unset}${SX_STR_LF}}"|])
			esac

			case "${Q_chain:+X}" in '')
				break
			esac

			Q_src="${Q_dest}"
			continue
		do :; done
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out}|])

	unset CLEANUP
}
|], [|var_copy_script|])dnl
popdef([|CLEANUP|])dnl
