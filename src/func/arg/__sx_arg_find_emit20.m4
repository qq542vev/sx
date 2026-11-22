M_REQUIRE([|__sx_var_bind|])dnl
pushdef([|CLEANUP|])dnl

### __sx_arg_find_emit20 - 検索結果を POS:TEXT 形式でバインドする（内部用）
##
## 使い方:
##   __sx_arg_find_emit20 バインド状態変数名 バインド形式 インデックス 値
##
## 説明:
##   __sx_arg_find / __sx_arg_rfind の内部実装。引数チェックは行わない。
##   POS|TEXT フラグに対応し、インデックスとマッチした値を POS:TEXT 順で
##   クォートしてバインドする。値が空文字列でも区切り ':' を残す。
##   値にスペースを含む場合はクォートされた値を eval 等で復元する。
##
## 終了ステータス:
##    0  割り当て成功
##    1  バインド先がもうない

__sx_arg_find_emit20() {
	__sx_var_bind "${1}" "${2}" "${3}:${4}" || return
}

popdef([|CLEANUP|])dnl
