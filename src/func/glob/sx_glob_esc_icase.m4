M_REQUIRE([|SX_CFG_SKIP_CHK __sx_glob_esc_icase __sx_var_is_name __sx_var_is_rw|])dnl
### sx_glob_esc_icase - リテラル文字列を英字の大小を区別しない glob に変換する
##
## 使い方:
##   sx_glob_esc_icase 結果変数名 [文字列] [追加エスケープ文字]
##
## 説明:
##   A〜Z と a〜z を、大文字・小文字の順のブラケット式 [Aa]〜[Zz] に変換する。
##   glob 特殊文字（* ? [ およびバックスラッシュ）は、sx_glob_esc と同じく
##   [*] [?] [[] [\\] に変換する。他の文字はそのまま保持する。
##   第3引数で指定された文字も追加でエスケープする。! と ^ は照合記号を使った
##   ブラケット式で表す。
##   入力はリテラル文字列として扱い、省略時と空文字列の結果は空文字列になる。
##   結果は case のパターンなどに使用できる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  結果変数名が無効 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_glob_esc_icase() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_esc_icase "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_glob_esc_icase|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_glob_esc_icase "${@}" || return
}
