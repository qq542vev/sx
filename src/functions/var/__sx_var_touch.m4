dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_REV __sx_num_add1_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_touch - 変数のリビジョン番号を更新する（内部用）
##
## 使い方:
##   __sx_var_touch 変数名1 [変数名2 ...]
##
## 説明:
##   指定された変数の値に含まれるリビジョン番号（末尾の : 以降）を
##   現在の SX_SYS_REV で更新し、SX_SYS_REV をインクリメントする。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_touch() {
	for Q_arg in "${@}"; do
		eval "${Q_arg}=\"\${${Q_arg}:+\"\${${Q_arg}%:*}\"}:\${SX_SYS_REV}\""
		M_NUM_INCRM1([|SX_SYS_REV|])
	done

	unset CLEANUP
}
|], [|var_touch|])dnl
popdef([|CLEANUP|])dnl
