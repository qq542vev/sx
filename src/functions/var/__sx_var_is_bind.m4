dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SWORD SX_STR_WORD|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_bind - 文字列が分配代入バインド形式として有効か確認する（内部用）
##
## 使い方:
##   __sx_var_is_bind [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_var_is_bind の内部実装。SX_CFG_NUM_RANGE の妥当性チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_mark Q_seg Q_vn Q_type Q_tmp|])dnl

__sx_var_is_bind() {
	for Q_arg in "${@}"; do
		Q_mark=

		case "${Q_arg}" in *[!":@${SX_STR_WORD}"]* | 0* | *:0* | *@ | *@[!"${SX_STR_SWORD}"]* | @*:* | *[!0-9]@*:*)
			eval unset CLEANUP "${Q_mark}"
			return 1
		esac

		case "${Q_arg##*:}" in [0-9]*)
			eval unset CLEANUP "${Q_mark}"
			return 1
		esac

		while
			Q_seg="${Q_arg%%:*}"
			Q_vn=

			case "${Q_seg}" in
				*[!0-9]*@*)
					eval unset CLEANUP "${Q_mark}"
					return 1
					;;
				*@*) Q_vn="${Q_seg#*@}" Q_type=arr;;
				["${SX_STR_SWORD}"]*)
					case "${Q_arg}" in
						*:*) Q_vn="${Q_seg}" Q_type=scalar;;
						*) Q_vn="${Q_seg}" Q_type=list;;
					esac
					;;
				*["${SX_STR_SWORD}"]*) Q_vn="M_STR_LTRIM([|Q_seg|], [|[!0-9]|])" Q_type=list;;
			esac

			case "${Q_vn:+X}" in X)
				eval "Q_tmp=\"\${Q_v${Q_vn}_=${Q_type}}\""
				M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])

				if M_STR_NE([|"${Q_tmp}"|], [|"${Q_type}"|]); then
					eval unset CLEANUP "${Q_mark}"
					return 1
				fi
			esac

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done

		eval ${Q_mark:+"unset ${Q_mark}"}
	done

	unset CLEANUP
}
|], [|var_is_bind|])dnl
popdef([|CLEANUP|])dnl
