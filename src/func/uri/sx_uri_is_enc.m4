M_REQUIRE([|SX_CFG_SKIP_CHK __sx_uri_is_enc|])dnl
pushdef([|CLEANUP|])dnl
### sx_uri_is_enc - 非予約文字と正しいパーセント表記だけか確認する
##
## 使い方:
##   sx_uri_is_enc [入力文字列 ...]
##
## 説明:
##   各入力が ASCII の英数字と - . _ ~、および %HH だけで構成されるか確認する。
##   %HH の16進数字は大文字・小文字を許可し、%00 も許可する。
##   sx_uri_enc の出力に対応する形式を検査し、文字コードの検証は行わない。
##   URI 全体や、埋め込み先での意味的な安全性は検査しない。
##   空文字列・入力なしは成功とする。
##
## 終了ステータス:
##    0  すべての入力が非予約文字と正しい %HH だけで構成される (SX_EX_OK)
##    1  許可しない文字、または不正なパーセント表記が含まれる
sx_uri_is_enc() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_uri_is_enc "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_uri_is_enc|])

	__sx_uri_is_enc "${@}" || return
}

popdef([|CLEANUP|])dnl
