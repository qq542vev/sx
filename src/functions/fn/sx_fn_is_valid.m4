dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_LF sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_fn_is_valid - 関数定義の妥当性（名前および構文）を確認する
##
## 使い方:
##   sx_fn_is_valid 名前=本体 [名前=本体 ...]
##
## 終了ステータス:
##    0  すべて妥当
##    1  無効な名前、または構文エラーが含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_fn_is_valid() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *=*)
			sx_var_is_name "${Q_arg%%=*}" && continue
		esac

		unset CLEANUP
		return 1
	done

	unset CLEANUP

	(
		for arg in "${@}"; do
			body="${arg#*=}"
			eval "${arg%%=*}() { ${body:-:}${SX_STR_LF}}" || exit 1
		done
	) 2>&- || return 1
}
|], [|fn_is_valid|])dnl
popdef([|CLEANUP|])dnl
