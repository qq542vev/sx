dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_unexport - 変数のエクスポート属性を解除する（内部用）
##
## 使い方:
##   __sx_var_unexport 名前1 [名前2 ...]
##
## 説明:
##   sx_var_unexport の内部実装。
##   引数チェックは行わない。値を保持したまま export 属性のみを除去する。

define([|CLEANUP|], [|Q_arg Q_tmp Q_set|])dnl

__sx_var_unexport() {
	for Q_arg in "${@}"; do
		eval "Q_tmp=\"\${${Q_arg}-}\" Q_set=\"\${${Q_arg}+X}\""
		unset -v "${Q_arg}"

		case "${Q_set}" in X)
			M_VAR_SET([|${Q_arg}|], [|${Q_tmp}|])
		esac
	done

	unset CLEANUP
}
|], [|var_unexport|])dnl
popdef([|CLEANUP|])dnl
