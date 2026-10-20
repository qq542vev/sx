M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_str_any - 第一引数が、後続引数のいずれかの文字列と完全に一致するか確認する
##
## 使い方:
##   sx_str_any [比較元文字列 [比較対象1 [比較対象2 ...]]]
##
## 挙動:
## - 第一引数を比較元文字列として扱う
## - 第二引数以降を比較対象文字列として順に比較する
## - 比較対象文字列が 1 つもない場合は不一致として 1 を返す
## - 引数が 0 個の場合は、比較元文字列を空文字列として扱い、やはり 1 を返す
##
## 終了ステータス:
##    0  いずれかと一致する (SX_EX_OK)
##    1  一つも一致しない

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_any() {
	Q_tgt="${1-}"
	${1+'shift'}

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in "${Q_arg}")
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_any|])dnl
popdef([|CLEANUP|])dnl
