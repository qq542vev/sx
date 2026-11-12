M_REQUIRE([||])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_list_export_cb - エクスポート属性付き変数名を蓄積する（内部用）
##
## 使い方:
##   __sx_var_list_export_cb エクスポート宣言
##
## 説明:
##   __sx_var_list_export から呼び出され、エクスポート宣言に含まれる変数名を
##   コールバック用の蓄積変数へ追加する。蓄積変数の初期化と後始末は呼び出し側が行う。
##   引数チェックは行わない。
##
## 終了ステータス:
##    0  変数名を蓄積した

define([|CLEANUP|], [||])dnl

__sx_var_list_export_cb() {
	M_STR_APPEND([|Q_names|], [|" ${1%%=*}"|])
}
|], [|var_list_export_cb|])dnl
popdef([|CLEANUP|])dnl
