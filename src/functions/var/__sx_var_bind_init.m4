M_REQUIRE([|SX_STR_SWORD __sx_arr_gen|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_bind_init - バインド形式に基づき変数を初期化する（内部用）
##
## 使い方:
##   __sx_var_bind_init [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   sx_var_bind_init の内部実装。
##   引数チェックは行わない。
##   通常の変数は削除（unset）され、数値プレフィックス（N名前）付きの変数と
##   最後の変数は空文字列（''）で初期化される。
##   対象が sx 配列である場合は、その関連要素（_len, _n 等）も含めて削除する。

define([|CLEANUP|], [|Q_arg Q_seg|])dnl

__sx_var_bind_init() {
	for Q_arg in "${@}"; do
		while
			Q_seg="${Q_arg%%:*}"

			case "${Q_seg}" in
				*@*) __sx_arr_gen "${Q_seg#*@}";;
				["${SX_STR_SWORD}"]*) unset "${Q_seg}";;
				*["${SX_STR_SWORD}"]*) eval "M_STR_LTRIM([|Q_seg|], [|[!0-9]|])=";;
			esac

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done

		case "${Q_seg}" in ["${SX_STR_SWORD}"]*)
			eval "${Q_seg}="
		esac
	done

	unset CLEANUP
}
|], [|var_bind_init|])dnl
popdef([|CLEANUP|])dnl
