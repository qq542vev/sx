M_REQUIRE([|__sx_var_bind|])dnl
pushdef([|CLEANUP|])dnl

### __sx_str_find_emit20 - 検索結果を LEN:TEXT 形式でバインドする（内部用）
##
## 使い方:
##   __sx_str_find_emit20 バインド状態変数名 バインド形式 位置 一致長 マッチ文字列
##
## 説明:
##   __sx_str_find / __sx_str_rfind の内部実装。引数チェックは行わない。
##   LEN|TEXT フラグに対応し、一致長とマッチ文字列を LEN:TEXT 順でバインドする。
##
## 終了ステータス:
##    0  割り当て成功
##    1  バインド先がもうない

__sx_str_find_emit20() {
	__sx_var_bind "${1}" "${2}" "${4}:${5}" || return
}

popdef([|CLEANUP|])dnl
