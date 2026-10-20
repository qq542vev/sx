M_REQUIRE([|SX_STR_XDIGIT|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_uri_is_pct - パーセント表記の構文を確認する（内部用）
##
## 使い方:
##   __sx_uri_is_pct [入力文字列 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   % の後にある非16進数字、または末尾の桁不足を case で検出する。
##   空文字列・入力なしは成功とする。
##
## 終了ステータス:
##    0  すべての入力のパーセント表記が正しい
##    1  不正なパーセント表記が含まれる
define([|CLEANUP|], [|Q_arg|])dnl

__sx_uri_is_pct() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *%[!"${SX_STR_XDIGIT}"]* | *%?[!"${SX_STR_XDIGIT}"]* | *% | *%?)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|uri_is_pct|])dnl
popdef([|CLEANUP|])dnl
