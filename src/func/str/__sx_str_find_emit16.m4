M_REQUIRE([|__sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl

### __sx_str_find_emit16 - 検索結果を LEN 形式でバインドする（内部用）
##
## 使い方:
##   __sx_str_find_emit16 バインド状態変数名 バインド形式 位置 一致長 マッチ文字列
##
## 説明:
##   __sx_str_find / __sx_str_rfind の内部実装。引数チェックは行わない。
##   LEN フラグに対応し、一致長だけを数値としてバインドする。
##
## 終了ステータス:
##    0  割り当て成功
##    1  バインド先がもうない

__sx_str_find_emit16() {
	__sx_var_ubind "${1}" "${2}" "${4}" || return
}

popdef([|CLEANUP|])dnl
