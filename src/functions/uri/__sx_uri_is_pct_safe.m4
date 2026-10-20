dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_uri_is_pct|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_uri_is_pct_safe - パーセント表記と NUL の不在を確認する（内部用）
##
## 使い方:
##   __sx_uri_is_pct_safe [入力文字列 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   %00 を拒否し、パーセント表記の構文検査へ委譲する。
##   空文字列・入力なしは成功とする。
##
## 終了ステータス:
##    0  すべての入力のパーセント表記が正しく %00 を含まない
##    1  不正なパーセント表記、または %00 が含まれる
define([|CLEANUP|], [|Q_arg|])dnl

__sx_uri_is_pct_safe() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *%00*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
	__sx_uri_is_pct "${@}" || return
}
|], [|uri_is_pct_safe|])dnl
popdef([|CLEANUP|])dnl
