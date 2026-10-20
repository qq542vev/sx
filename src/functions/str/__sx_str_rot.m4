dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_ALPHA __sx_str_cycle __sx_str_tr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_rot - sx_str_rot の内部実装（内部用）
##
## 使い方:
##   __sx_str_rot 結果変数名 [元文字列 [文字セット [シフト量]]]
##
## 説明:
##   sx_str_rot の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_rotated|])dnl

__sx_str_rot() {
	set -- "${1}" "${2-}" "${3-${SX_STR_ALPHA}}" "${4:-13}"

	case '' in "${2}" | "${3}")
		M_VAR_SET([|${1}|], [|${2}|])
		return
	esac

	__sx_str_cycle Q_rotated "${3}" "${4}"
	__sx_str_tr "${1}:" "${2}" "${3}" "${Q_rotated}"

	unset CLEANUP
}
|], [|str_rot|])dnl
popdef([|CLEANUP|])dnl
