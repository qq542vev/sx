M_REQUIRE([|SX_CFG_SKIP_CHK __sx_uri_is_enc_safe|])dnl
pushdef([|CLEANUP|])dnl
### sx_uri_is_enc_safe - エンコードされた構成要素が %00 を含まないか確認する
##
## 使い方:
##   sx_uri_is_enc_safe [入力文字列 ...]
##
## 説明:
##   sx_uri_is_enc の条件に加え、NUL を表す %00 を拒否する。
##   safe は1回のデコードで NUL が生じないことを意味する。
##   %2500 や、その他の制御文字を表す %HH は許可する。
##   空文字列・入力なしは成功とし、埋め込み先での意味的な安全性は保証しない。
##
## 終了ステータス:
##    0  すべての入力が非予約文字と正しい %HH だけで構成され %00 を含まない (SX_EX_OK)
##    1  許可しない文字、不正なパーセント表記、または %00 が含まれる
sx_uri_is_enc_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_uri_is_enc_safe "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_uri_is_enc_safe|])

	__sx_uri_is_enc_safe "${@}" || return
}

popdef([|CLEANUP|])dnl
