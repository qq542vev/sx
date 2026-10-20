dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_range __sx_str_sub|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_range - 位置パラメータの参照文字列を指定範囲で生成する（内部用）
##
## 使い方:
##   __sx_arg_range 宛先変数名 [開始 [終了 [ステップ]]]
##
## 説明:
##   指定された範囲のインデックスに対応する位置パラメータの参照文字列を生成し、
##   宛先変数に格納する。バリデーションは行わない。

define([|CLEANUP|], [|Q_res Q_idxs Q_tmp|])dnl

__sx_arg_range() {
	Q_res="${1}"
	shift
	__sx_num_range Q_idxs "${@}"

	case "${Q_idxs:+X}" in
		'') M_VAR_SET([|${Q_res}|], [||]);;
		*)
			__sx_str_sub Q_tmp: "${Q_idxs}" ' ' '}" "${'
			M_VAR_SET([|${Q_res}|], [|\"\${${Q_tmp}}\"|])
			;;
	esac

	unset CLEANUP
}
|], [|arg_range|])dnl
popdef([|CLEANUP|])dnl
