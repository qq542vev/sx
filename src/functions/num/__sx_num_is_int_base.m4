dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_is_nat0_base|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_is_int_base - 指定された基数で整数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_int_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_int_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		__sx_num_is_nat0_base "${Q_rad}" "${Q_arg#[+-]}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_int_base|])dnl
popdef([|CLEANUP|])dnl
