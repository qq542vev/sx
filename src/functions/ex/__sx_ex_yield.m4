dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_ex_map|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_ex_yield - 任意の終了ステータスを発生させる（内部用）
##
## 使い方:
##   __sx_ex_yield [ステータス番号 | ステータス名]
##
## 説明:
##   指定された終了ステータス（数値または名前）を発生させる。
##   名前が渡された場合は数値に変換して返す。バリデーションは行わない。
##
## 終了ステータス:
##   - 指定されたステータスを返す。

define([|CLEANUP|], [|Q_s|])dnl

__sx_ex_yield() {
	case "${1-0}" in [!0-9]*)
		__sx_ex_map Q_s "${1}"
		set -- "${Q_s}"
		unset CLEANUP
	esac

	return "${1-0}"
}
|], [|ex_yield|])dnl
popdef([|CLEANUP|])dnl
