M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_bind __sx_var_is_name __sx_var_is_rw __sx_var_to_ebind|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_to_ebind - bind形式を拡張bind形式に変換する
##
## 使い方:
##   sx_var_to_ebind 結果変数名 bind形式
##
## 説明:
##   bind形式（sx_var_is_bind 参照）を拡張bind形式（sx_var_is_ebind 参照）の
##   初期状態（進行度0）に変換し、結果変数に格納する。
##   中間の N / Nvn / N@vn は 0/N 形式に、同名の再利用は合算して M/N 形式にする。
##   末尾の素 vn / @vn は M/vn / M/@vn 形式の rest に変換する。
##   例: 2:3a:b:9@c:2a:2d::d -> 0/2:0/3a:b:0/9@c:3/5a:0/2d::2/d
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正、bind形式が不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_to_ebind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_to_ebind "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_var_to_ebind|])

	case "${#}" in 2) ;; *) return M_EX_USAGE;; esac

	__sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_var_is_bind "${2-}" || return M_EX_USAGE

	__sx_var_to_ebind "${@}"
}

popdef([|CLEANUP|])dnl
