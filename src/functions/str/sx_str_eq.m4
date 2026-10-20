M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_str_eq - すべての引数が文字列として一致するか確認する
##
## 使い方:
##   sx_str_eq [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて一致する (または引数が1つ以下)
##    1  一致しない文字列が含まれる

define([|CLEANUP|], [|Q_first Q_arg|])dnl

sx_str_eq() {
	Q_first="${1-}"
	${1+'shift'}

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${Q_first}") ;;
			*)
				unset CLEANUP
				return 1
				;;
		esac
	done

	unset CLEANUP
}
|], [|str_eq|])dnl
popdef([|CLEANUP|])dnl
