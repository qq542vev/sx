M_REQUIRE([|__sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl

### __sx_arg_find_emit16 - 検索結果を POS 形式でバインドする（内部用）
##
## 使い方:
##   __sx_arg_find_emit16 バインド状態変数名 バインド形式 インデックス 値
##
## 説明:
##   __sx_arg_find / __sx_arg_rfind の内部実装。引数チェックは行わない。
##   POS フラグに対応し、インデックスだけを数値としてバインドする。
##   出力形式フラグ未指定時もこの形式を使用する。
##
## 終了ステータス:
##    0  割り当て成功
##    1  バインド先がもうない

__sx_arg_find_emit16() {
	__sx_var_ubind "${1}" "${2}" "${3}" || return
}

popdef([|CLEANUP|])dnl
