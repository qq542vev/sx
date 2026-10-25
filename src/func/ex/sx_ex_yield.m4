M_REQUIRE([|SX_CFG_SKIP_CHK __sx_ex_is_valid __sx_ex_yield|])dnl
pushdef([|CLEANUP|])dnl
### sx_ex_yield - 任意の終了ステータスを発生させる
##
## 使い方:
##   sx_ex_yield [ステータス番号 | ステータス名]
##
## 説明:
##   指定された終了ステータス（数値または名前）を発生させる。
##   サブシェルを使用しないため、(exit n) よりも高速に動作する。
##
## 終了ステータス:
##   - 指定されたステータスを返す。
##   - 引数が指定されない場合は 0 (SX_EX_OK) を返す。
##   - ステータス値が 0-255 の範囲外、または整数でない場合は SX_EX_USAGE (64) を返す。
sx_ex_yield() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_ex_yield "${@}" || return; return 0;; esac

	__sx_ex_is_valid "${1-0}" || return M_EX_USAGE

	__sx_ex_yield "${@}" || return
}

popdef([|CLEANUP|])dnl
