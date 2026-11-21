M_REQUIRE([|__sx_var_bind __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_find_bind - 検索結果を指定された出力形式でバインドする（内部用）
##
## 使い方:
##   __sx_str_find_bind バインド状態変数名 バインド形式 PFLG LFLG TFLG 位置 一致長 マッチ文字列
##
## 説明:
##   __sx_str_find / __sx_str_rfind の内部実装。引数チェックは行わない。
##   PFLG / LFLG / TFLG は対応する出力形式フラグが ON なら 1、OFF なら空文字列。
##   有効なフィールドだけを POS:LEN:TEXT の固定順で ':' 連結し、
##   TEXT を含む場合は空白を保持するためクォート付きでバインドする。
##   区切りは蓄積済みの値の有無で判断するため、POS が OFF でも LEN の前に ':' は付かない。
##   find / rfind で出力形式フラグの値は共通である。

define([|CLEANUP|], [|Q_bind Q_val|])dnl

__sx_str_find_bind() {
	Q_bind="${1}"
	Q_val=${3:+${6}}
	Q_val=${Q_val}${4:+${Q_val:+:}${7}}
	Q_val=${Q_val}${5:+${Q_val:+:}${8}}

	case "${5}" in
		1) __sx_var_bind "${Q_bind}" "${2}" "${Q_val}";;
		*) __sx_var_ubind "${Q_bind}" "${2}" "${Q_val}";;
	esac
	set -- "${?}"

	unset CLEANUP
	return "${1}"
}
|], [|str_find_bind|])dnl
popdef([|CLEANUP|])dnl
