M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_between - 引数の個数が指定範囲内か確認する（内部用）
##
## 使い方:
##   __sx_arg_between 最小個数 最大個数 [引数 ...]
##
## 説明:
##   引数チェックを行わずに個数の範囲判定を行う。
##   最小個数または最大個数に空文字が渡された場合は、その境界の判定を省略する。
##   個数判定は command shift の成否により行う。
##
## 終了ステータス:
##   0  最小個数 <= 個数 <= 最大個数 (SX_EX_OK)
##   1  範囲外

define([|CLEANUP|], [|Q_min Q_max|])dnl

__sx_arg_between() {
	case "${1:+X}${2:+Y}" in
		X) command shift "${1}" && case "${#}" in [01]) ! :; esac;;
		Y) ! command shift "${2}" || case "${#}" in [3-9] | ??*) ! :;; esac;;
		XY)
			Q_min="${1}"
			Q_max="${2}"
			shift 2

			__sx_arg_between '' "${Q_max}" "${@}" && command shift "${Q_min}" || {
				unset CLEANUP
				return 1
			}

			unset CLEANUP
			;;
	esac 2>&- || return 1
}
|], [|arg_between|])dnl
popdef([|CLEANUP|])dnl
