M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_ex_is_err - すべての引数がエラーを示す終了ステータス（1-255）であるか確認する
##
## 使い方:
##   sx_ex_is_err [値1 [値2 ...]]
##
## 説明:
##   引数で指定されたすべての値が、1 以上 255 以下の整数（10進数）であるかを確認する。
##
## 終了ステータス:
##    0  すべて 1-255 の範囲内である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_ex_is_err() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			[1-9] | [1-9][0-9] | 1[0-9][0-9] | 2[0-4][0-9] | 25[0-5]) continue;;
		esac

		unset CLEANUP
		return 1
	done

	unset CLEANUP
}
|], [|ex_is_err|])dnl
popdef([|CLEANUP|])dnl
