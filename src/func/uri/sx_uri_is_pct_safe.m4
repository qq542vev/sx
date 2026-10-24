M_REQUIRE([|SX_CFG_SKIP_CHK __sx_uri_is_pct_safe|])dnl
pushdef([|CLEANUP|])dnl
### sx_uri_is_pct_safe - パーセント表記が正しく %00 を含まないか確認する
##
## 使い方:
##   sx_uri_is_pct_safe [入力文字列 ...]
##
## 説明:
##   sx_uri_is_pct の条件に加え、NUL を表す %00 を拒否する。
##   safe は1回のデコードで NUL が生じないことを意味する。
##   再帰的なデコードは想定せず、%2500 は許可する。
##   その他の制御文字を表す %HH は許可し、一般的な安全性は保証しない。
##   空文字列・入力なしは成功とする。
##
## 終了ステータス:
##    0  すべての入力のパーセント表記が正しく %00 を含まない (SX_EX_OK)
##    1  不正なパーセント表記、または %00 が含まれる
sx_uri_is_pct_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_uri_is_pct_safe "${@}" || return; return 0;; esac

	__sx_uri_is_pct_safe "${@}" || return
}

popdef([|CLEANUP|])dnl
