dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SKIP_CHK __sx_arr_is_spec|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_arr_is_spec - 文字列が配列要素指定 spec として有効か確認する
##
## 使い方:
##   sx_arr_is_spec [spec1 [spec2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、sx_arr_get の spec
##   （整数 | [始点][:終点[:刻み]]）として有効かを確認する。
##   整数は符号付き10進整数（+1 / -1 の接頭辞可、前ゼロなし、-0 は 0 とみなす）。
##   第3要素（step）は 0 以外でなければならない。
##   始点・終点のみ省略できる（:e / s: / ::t / : 形式）。空の刻みは不可であり、
##   第二コロンを書いた場合は刻みが必須である。
##   始点の省略（:e 系）・全省略（:）も有効である。
##   範囲の意味的妥当性（空範囲等）は問わず、形式のみを検査する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる

sx_arr_is_spec() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_spec "${@}" || return; return 0;; esac

	__sx_arr_is_spec "${@}" || return
}
|], [|arr_is_spec|])dnl
popdef([|CLEANUP|])dnl
