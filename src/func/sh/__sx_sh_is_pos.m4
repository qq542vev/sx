M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_sh_is_pos - すべての引数が位置パラメータとして有効か確認する（内部用）
##
## 使い方:
##   __sx_sh_is_pos [位置パラメータ1 [位置パラメータ2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   各引数が数字のみで、1 つ以上の 1-9 を含むか確認する。
##   先頭に 0 が付いた位置パラメータは受け付けるが、全て 0 のものは受け付けない。
##   判定は M_SH_REJECT_POS を評価してから M_SH_ACCEPT_POS を評価する。
##
## 終了ステータス:
##    0  すべて有効な位置パラメータ (SX_EX_OK)
##    1  無効な位置パラメータが含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_sh_is_pos() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
		M_SH_REJECT_POS)
			unset CLEANUP
			return 1
			;;
		esac
		case "${Q_arg}" in
		M_SH_ACCEPT_POS) ;;
		*)
			unset CLEANUP
			return 1
			;;
		esac
	done

	unset CLEANUP
}
|], [|sh_is_pos|])dnl
popdef([|CLEANUP|])dnl
