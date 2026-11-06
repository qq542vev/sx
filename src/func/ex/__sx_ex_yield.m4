M_REQUIRE([|SX_EX_CANTCREAT SX_EX_CONFIG SX_EX_DATAERR SX_EX_IOERR SX_EX_NOHOST SX_EX_NOINPUT SX_EX_NOPERM SX_EX_NOUSER SX_EX_OK SX_EX_OSERR SX_EX_OSFILE SX_EX_PROTOCOL SX_EX_SOFTWARE SX_EX_TEMPFAIL SX_EX_UNAVAILABLE SX_EX_USAGE|])dnl
M_DYNAMIC_CONSTS([|SX_EX_|], [|CANTCREAT CONFIG DATAERR IOERR NOHOST NOINPUT NOPERM NOUSER OK OSERR OSFILE PROTOCOL SOFTWARE TEMPFAIL UNAVAILABLE USAGE|])dnl
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

__sx_ex_yield() {
	case "${1-}" in [!0-9]*)
		eval "return \"\${SX_EX_${1}}\""
	esac

	return "${1-0}"
}
|], [|ex_yield|])dnl
popdef([|CLEANUP|])dnl
