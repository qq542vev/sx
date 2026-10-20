dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_ALNUM __sx_uri_is_pct|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_uri_is_enc - エンコードされた構成要素の形式を確認する（内部用）
##
## 使い方:
##   __sx_uri_is_enc [入力文字列 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   非予約文字と % 以外を拒否し、パーセント表記の構文検査へ委譲する。
##   空文字列・入力なしは成功とする。
##
## 終了ステータス:
##    0  すべての入力が非予約文字と正しい %HH だけで構成される
##    1  許可しない文字、または不正なパーセント表記が含まれる
define([|CLEANUP|], [|Q_arg|])dnl

__sx_uri_is_enc() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *[!"${SX_STR_ALNUM}"%._~-]*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
	__sx_uri_is_pct "${@}" || return
}
|], [|uri_is_enc|])dnl
popdef([|CLEANUP|])dnl
