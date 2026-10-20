dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_uri_is_pct|])dnl
pushdef([|CLEANUP|])dnl
### sx_uri_is_pct - すべての入力のパーセント表記が正しいか確認する
##
## 使い方:
##   sx_uri_is_pct [入力文字列 ...]
##
## 説明:
##   各入力に含まれる % がすべて %HH（H は ASCII の16進数字）であるか確認する。
##   % 以外の文字には制限を設けず、日本語や URI の区切り文字も許可する。
##   %00 も許可する。文字コードや URI 全体の妥当性は検査しない。
##   空文字列・入力なしは成功とし、最初の不一致で検査を打ち切る。
##
## 終了ステータス:
##    0  すべての入力のパーセント表記が正しい (SX_EX_OK)
##    1  不正なパーセント表記が含まれる
sx_uri_is_pct() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_uri_is_pct "${@}" || return; return 0;; esac

	__sx_uri_is_pct "${@}" || return
}

popdef([|CLEANUP|])dnl
