dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_uri_is_enc|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_uri_is_enc_safe - 構成要素の形式と NUL の不在を確認する（内部用）
##
## 使い方:
##   __sx_uri_is_enc_safe [入力文字列 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   %00 を拒否し、エンコードされた構成要素の形式検査へ委譲する。
##   空文字列・入力なしは成功とする。
##
## 終了ステータス:
##    0  すべての入力が非予約文字と正しい %HH だけで構成され %00 を含まない
##    1  許可しない文字、不正なパーセント表記、または %00 が含まれる
define([|CLEANUP|], [|Q_arg|])dnl

__sx_uri_is_enc_safe() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *%00*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
	__sx_uri_is_enc "${@}" || return
}
|], [|uri_is_enc_safe|])dnl
popdef([|CLEANUP|])dnl
