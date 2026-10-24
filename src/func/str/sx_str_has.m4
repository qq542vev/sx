M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_str_has - 第一引数に、第二引数以降のいずれかの文字列が含まれているか確認する
##
## 使い方:
##   sx_str_has [検索対象文字列 [含まれるべき文字列1 [含まれるべき文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 含まれるべき文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列に含まれていれば成功する
## - 含まれるべき文字列が 1 つも指定されなかった場合は失敗する
## - 含まれるべき文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかが含まれている (SX_EX_OK)
##    1  一致する文字列がない

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_has() {
	Q_tgt="${1-}"
	${1+'shift'}

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in *"${Q_arg}"*)
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_has|])dnl
popdef([|CLEANUP|])dnl
