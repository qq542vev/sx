M_REQUIRE([|SX_CFG_SKIP_CHK __sx_num_is_slice|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_num_is_slice - すべての引数が slice として有効か確認する
##
## 使い方:
##   sx_num_is_slice [slice1 [slice2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、slice
##   （整数 | [始点]:終点[:刻み]）として有効かを確認する。
##   整数は符号付き10進整数（+1 / -1 の接頭辞可、前ゼロなし、-0 は 0 とみなす）。
##   単体の整数は 0:N の短縮形として利用側が解釈できる形式であり、形式検証では受理する。
##   コロン形式では終点は必須であり、省略できない。始点は省略できる。
##   第3要素（刻み）は 0 以外でなければならない。第2コロンを書いた場合は刻みが必須である。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる

sx_num_is_slice() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_slice "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_num_is_slice|])

	__sx_num_is_slice "${@}" || return
}
|], [|num_is_slice|])dnl
popdef([|CLEANUP|])dnl
