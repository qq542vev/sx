M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_is_ebind|])dnl
pushdef([|CLEANUP|])dnl
### sx_arr_is_ebind - 文字列が配列分配用拡張バインド形式として有効か確認する
##
## 使い方:
##   sx_arr_is_ebind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、配列分配用拡張バインド形式として有効かを確認する。
##   sx_var_is_ebind の検査に加え、`@` を含む形式を拒否する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arr_is_ebind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_ebind "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arr_is_ebind|])

	__sx_arr_is_ebind "${@}" || return
}

popdef([|CLEANUP|])dnl
