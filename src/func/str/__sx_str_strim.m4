M_REQUIRE([|SX_STR_SPACE|])dnl
pushdef([|CLEANUP|])dnl
### __sx_str_strim - 文字列の先頭から指定された文字セットを削除する（内部用）
##
## 使い方:
##   __sx_str_strim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   sx_str_strim の内部実装。
##   引数チェックは行わない。
__sx_str_strim() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}"

	case "${3:+X}" in '')
		M_VAR_SET([|${1}|], [|${2}|])
		return
	esac

	M_VAR_SET([|${1}|], [|M_STR_LTRIM([|2|], [|[!"${3}"]|])|])
}

popdef([|CLEANUP|])dnl
