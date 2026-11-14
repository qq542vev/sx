M_REQUIRE([|__sx_str_len_cmp|])dnl
### sx_str_len_cmp - 2つの文字列の長さを比較する
##
## 使い方:
##   sx_str_len_cmp 文字列1 文字列2
##
## 説明:
##   実処理は内部関数 __sx_str_len_cmp に委譲する。
##
## 終了ステータス:
##    1  文字列1の長さ < 文字列2の長さ
##    2  長さが等しい
##   3  文字列1の長さ > 文字列2の長さ
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

sx_str_len_cmp() {
	M_CFG_CHECK([|sx_str_len_cmp|])

	__sx_str_len_cmp "${@}"
}
