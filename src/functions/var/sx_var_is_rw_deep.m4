dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_var_is_rw_deep sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_var_is_rw_deep - 変数およびその配下のサブ変数がすべて書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw_deep 変数名 [変数名 ...]
##
## 説明:
##   指定された変数と、その配下に存在するサブ変数（${変数名}_len, ${変数名}_0, 等）が
##   すべて書き込み可能か確認する。
##   実際の変数構造に依存せず、現在読み取り専用として登録されている名前を
##   深さを問わず走査して検証する。実体が sx 配列でない場合でも確認自体は可能で、
##   その場合は変数名と配下のサブ変数の書き込み可否を検査する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_var_is_rw_deep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_rw_deep "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw_deep "${@}" || return
}

popdef([|CLEANUP|])dnl
