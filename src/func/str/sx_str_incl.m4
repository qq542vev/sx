M_REQUIRE([|__sx_str_incl|])dnl
### sx_str_incl - 2つの文字列の相互包含関係を判定する
##
## 使い方:
##   sx_str_incl 文字列1 文字列2
##
## 説明:
##   実処理は内部関数 __sx_str_incl に委譲する。
##
## 終了ステータス:
##    1  文字列1が文字列2に含まれる (∈)
##    2  等しい (=)
##    3  文字列1が文字列2を含む (∋)
##    4  互いに素
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)

sx_str_incl() {
	M_CFG_CHECK([|sx_str_incl|])

	__sx_str_incl "${@}"
}
