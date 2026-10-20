M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_bind __sx_var_is_bind_ready|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_bind_ready - バインド形式が直ちにバインド可能な状態か確認する
##
## 使い方:
##   sx_var_is_bind_ready [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   引数で指定されたすべてのバインド形式が、直ちに sx_var_bind / sx_var_ubind
##   で使用できる状態（bind_init 直後の状態）にあるかを確認する。
##   各要素は以下の状態である必要がある。
##     - @name / N@name: 対象が sx 配列であること
##     - 中間の素変数名: 未設定であること
##     - 末尾の素変数名: 設定済みであること
##     - 数値プレフィックス付きの要素（N名前）: 数字を除いた名前が設定済みであること
##   空セグメントと裸の数値は検査対象外とする。
##   bind_init を事前に実行していないバインド形式は拒否される。
##
## 終了ステータス:
##    0  すべてバインド可能な状態である (SX_EX_OK)
##    1  バインド可能な状態にないものが含まれる
##   64  バインド形式が不正 (SX_EX_USAGE)
sx_var_is_bind_ready() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_bind_ready "${@}" || return; return 0;; esac

	__sx_var_is_bind "${@}" || return M_EX_USAGE

	__sx_var_is_bind_ready "${@}" || return
}

popdef([|CLEANUP|])dnl
