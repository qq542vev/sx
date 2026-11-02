M_REQUIRE([|__sx_str_tr0|])dnl
dnl 英字の位置に対応する [Aa]〜[Zz] の置換先引数列を生成する。
pushdef([|__sx_m4_gen_glob_esc_icase_args|], [|'[substr(M_STR_UPPER, $1, 1)[||]substr(M_STR_LOWER, $1, 1)]'ifelse($1, 25, [||], [| __sx_m4_gen_glob_esc_icase_args(incr($1))|])|])dnl
### __sx_glob_esc_icase - リテラル文字列を英字の大小を区別しない glob に変換する（内部用）
##
## 使い方:
##   __sx_glob_esc_icase 結果変数名 [文字列]
##
## 説明:
##   sx_glob_esc_icase の内部実装。引数チェックは行わない。
##   特殊文字と英字を一つの対応表で置換し、置換先のブラケット式は再走査しない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
__sx_glob_esc_icase() {
	__sx_str_tr0 "${1}:" "${2-}" M_SH_QUOTE(M_GLOB_SP_NORM[||]M_STR_ALPHA) '' \
		M_GLOB_SP_NORM_ESC_ARGS \
		__sx_m4_gen_glob_esc_icase_args(0) \
		__sx_m4_gen_glob_esc_icase_args(0)
}
popdef([|__sx_m4_gen_glob_esc_icase_args|])dnl
