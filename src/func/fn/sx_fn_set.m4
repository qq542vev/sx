M_REQUIRE([|SX_CFG_SKIP_CHK __sx_fn_is_valid __sx_fn_set|])dnl
pushdef([|CLEANUP|])dnl
### sx_fn_set - 関数を動的に定義する
##
## 使い方:
##   sx_fn_set 名前=本体 [名前=本体 ...]
##
## 説明:
##   指定された名前と本体（コマンド文字列）を用いて、関数を定義する。
##   本体は eval を介して定義されるため、クォーティングに注意が必要。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (名前が無効、または '=' がない) (SX_EX_USAGE)
sx_fn_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_set "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_fn_set|])

	__sx_fn_is_valid "${@}" || return M_EX_USAGE

	__sx_fn_set "${@}"
}

popdef([|CLEANUP|])dnl
