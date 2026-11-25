M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_sh_is_param - パラメータ名として有効か確認する（内部用）
##
## 使い方:
##   __sx_sh_is_param [パラメータ1 [パラメータ2 ...]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   ${...} の parameter 部分として各引数が有効か確認する。
##   特殊パラメータ、位置パラメータ、変数名を受け付ける。
##   先頭に 0 が付いた位置パラメータは受け付けるが、全て 0 のものは受け付けない。
##   判定は M_SH_REJECT_PARAM を評価してから M_SH_ACCEPT_PARAM を評価する。
##
## 終了ステータス:
##    0  すべて有効なパラメータ (SX_EX_OK)
##    1  無効なパラメータが含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_sh_is_param() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
		M_SH_REJECT_PARAM)
			unset CLEANUP
			return 1
			;;
		esac
		case "${Q_arg}" in
		M_SH_ACCEPT_PARAM) ;;
		*)
			unset CLEANUP
			return 1
			;;
		esac
	done

	unset CLEANUP
}
|], [|sh_is_param|])dnl
popdef([|CLEANUP|])dnl
