M_REQUIRE([|SX_CFG_SKIP_CHK __sx_glob_esc_eq __sx_var_is_name __sx_var_is_rw|])dnl
### sx_glob_esc_eq - 指定した文字を等価クラスにする glob を生成する
##
## 使い方:
##   sx_glob_esc_eq 結果変数名 [文字列] [等価クラス化する文字] [追加エスケープ文字]
##
## 説明:
##   第3引数に含まれる入力文字を、それぞれ glob の等価クラス表記に変換する。
##   等価クラスの照合内容は照合時のロケールに従う。等価クラス化は glob 特殊文字と
##   第4引数の追加エスケープ文字より優先する。
##   glob 特殊文字（* ? [ およびバックスラッシュ）は、第3引数で指定されない限り
##   sx_glob_esc と同じリテラル用ブラケット式に変換する。
##   第4引数で指定された文字も追加でエスケープする。! と ^ は照合記号を使った
##   ブラケット式で表す。第3・第4引数は文字の集合として扱い、その順序や重複は結果に影響しない。
##   結果は case のパターンなどに使用できる。
##   結果変数を SX Array から再利用する場合は、呼び出し前に利用者が sx_var_unset で処分する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  結果変数名が無効 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_glob_esc_eq() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_esc_eq "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_glob_esc_eq|])

	__sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_glob_esc_eq "${@}" || return
}
