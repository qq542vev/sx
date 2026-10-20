dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_WORD sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_var_is_chain - 文字列が有効な連鎖式であるか確認する
##
## 使い方:
##   sx_var_is_chain [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、sx_var_copy 等で使用可能な
##   有効な連鎖式（A-B-C または A=B=C）であるか、あるいは単一の有効な変数名
##   であるかを確認する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_var_is_chain() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) ! M_STR_MATCH([|"${Q_arg}"|], [|*[!"${SX_STR_WORD}"=]*|], [|*==*|], [|=*|], [|*=|], [|[0-9]*|], [|*=[0-9]*|]);;
			*-*) ! M_STR_MATCH([|"${Q_arg}"|], [|*[!"${SX_STR_WORD}"-]*|], [|*--*|], [|-*|], [|*-|], [|[0-9]*|], [|*-[0-9]*|]);;
			*) sx_var_is_name "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|var_is_chain|])dnl
popdef([|CLEANUP|])dnl
