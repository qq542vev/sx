M_REQUIRE([|__sx_fn_is_valid|])dnl
### sx_fn_is_valid - 関数定義の妥当性（名前および構文）を確認する
##
## 使い方:
##   sx_fn_is_valid 名前=本体 [名前=本体 ...]
##
## 説明:
##   実処理は内部関数 __sx_fn_is_valid に委譲する。
##
## 終了ステータス:
##    0  すべて妥当
##    1  無効な名前、または構文エラーが含まれる

sx_fn_is_valid() {
	__sx_fn_is_valid "${@}" || return
}
