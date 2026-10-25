M_REQUIRE([|SX_CFG_SKIP_CHK __sx_uri_enc __sx_var_is_bind __sx_var_is_bindable|])dnl
pushdef([|CLEANUP|])dnl
### sx_uri_enc - URI の構成要素に入れるバイト列をパーセントエンコードする
##
## 使い方:
##   sx_uri_enc バインド形式 [入力文字列 ...]
##
## 説明:
##   C (POSIX) ロケールで起動したシェルから呼び出すことを前提とする。
##   各入力は NUL を除くバイト列とし、入力省略時は 0 件として扱う。
##   ASCII の英数字と - . _ ~ を保持し、その他を大文字の %HH に変換する。
##   空白は %20、+ は %2B、% は %25 とし、既存の %HH も再エンコードする。
##   文字コードの変換・検証は行わない。UTF-8 入力はそのバイト列を変換する。
##   URI 全体の区切り文字を保持する用途ではなく、構成要素の値に使用する。
##   ロケールの検査・変更は行わない。
##   バインド先を初期化し、各入力の変換結果を sx_var_ubind と同じ規則で渡す。
##   単一変数には結果を空白区切りで蓄積し、a:b: 等では順番に分配する。
##   @name / N@name による配列への分配にも対応する。
##   空文字列は代入スロットと配列で保持するが、クォートなしの蓄積では
##   空要素の境界を保持しない。入力なしと空文字列 1 件は異なる。
##   バインド先が枯渇した場合は残りの入力を処理せず、成功を返す。
##   既存配列をバインド先へ使い回す場合は、事前に sx_var_unset で解放すること。
##
## 終了ステータス:
##    0  成功（バインド枯渇による早期終了を含む）(SX_EX_OK)
##   64  バインド形式が省略または不正 (SX_EX_USAGE)
##   77  バインド先に読み取り専用の変数がある (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_uri_enc() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_uri_enc "${@}" || return; return 0;; esac

	M_CFG_CHECK([|sx_uri_enc|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE
	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_uri_enc "${@}"
}

popdef([|CLEANUP|])dnl
