dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_is_bind|])dnl
pushdef([|CLEANUP|])dnl
### sx_arr_is_bind - 文字列が配列分配用バインド形式として有効か確認する
##
## 使い方:
##   sx_arr_is_bind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、配列分配用バインド形式として有効かを確認する。
##   sx_var_is_bind の検査に加え、`@` を含む形式を拒否する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
sx_arr_is_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_bind "${@}" || return; return 0;; esac

	__sx_arr_is_bind "${@}" || return
}

popdef([|CLEANUP|])dnl
