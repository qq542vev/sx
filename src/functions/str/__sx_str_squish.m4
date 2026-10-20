dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SPACE __sx_str_trim|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_squish - XSLT normalize-space 相当（内部用）
##
## 使い方:
##   __sx_str_squish 結果変数名 [文字列 [文字セット [区切り文字]]]
##
## 説明:
##   sx_str_squish の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_str Q_out|])dnl

__sx_str_squish() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}" "${4- }"

	case "${3:+X}" in '')
		M_VAR_SET([|${1}|], [|${2}|])
		return
	esac

	__sx_str_trim Q_str "${2}" "${3}"

	Q_out=
	while M_STR_HAS([|"${Q_str}"|], [|["${3}"]|]); do
		M_STR_APPEND([|Q_out|], [|"${Q_str%%["${3}"]*}${4}"|])
		Q_str="${Q_str#*["${3}"]}"
		Q_str="M_STR_LTRIM([|Q_str|], [|[!"${3}"]|])"
	done

	M_VAR_SET([|${1}|], [|${Q_out}${Q_str}|])
	unset CLEANUP
}
|], [|str_squish|])dnl
popdef([|CLEANUP|])dnl
