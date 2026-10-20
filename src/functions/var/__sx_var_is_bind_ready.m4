dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SWORD __sx_var_is_arr __sx_var_is_set|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_is_bind_ready - バインド形式が直ちにバインド可能な状態か確認する（内部用）
##
## 使い方:
##   __sx_var_is_bind_ready [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   sx_var_is_bind_ready の内部実装。
##   引数チェックは行わない。
##
## 終了ステータス:
##    0  すべてバインド可能な状態である (SX_EX_OK)
##    1  バインド可能な状態にないものが含まれる

define([|CLEANUP|], [|Q_arg Q_seg|])dnl

__sx_var_is_bind_ready() {
	for Q_arg in "${@}"; do
		while
			Q_seg="${Q_arg%%:*}"

			case "${Q_seg}" in
				*@*) __sx_var_is_arr "${Q_seg#*@}";;
				[${SX_STR_SWORD}]*)
					case "${Q_arg}" in
						*:*) ! __sx_var_is_set "${Q_seg}";;
						*) __sx_var_is_set "${Q_seg}";;
					esac
					;;
				*[${SX_STR_SWORD}]*) __sx_var_is_set "M_STR_LTRIM([|Q_seg|], [|[!0-9]|])";;
			esac || {
				unset CLEANUP
				return 1
			}

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done
	done

	unset CLEANUP
}
|], [|var_is_bind_ready|])dnl
popdef([|CLEANUP|])dnl
