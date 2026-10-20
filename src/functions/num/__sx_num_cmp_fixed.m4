dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_cmp_fixed_abs|])dnl
pushdef([|CLEANUP|])dnl
### __sx_num_cmp_fixed - 正規化済み数値を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_fixed() {
	case "${1}:${2}" in
		*[1-9]*:* | *:*[1-9]*) ;;
		*) return 2;;
	esac

	case "${1}:${2}" in
		-*:[+0-9]*) return 1;;
		[+0-9]*:-*) return 3;;
	esac

	case "${1}" in
		-*) __sx_num_cmp_fixed_abs "${2#[+-]}" "${1#[+-]}";;
		*)  __sx_num_cmp_fixed_abs "${1#[+-]}" "${2#[+-]}";;
	esac || return
}

popdef([|CLEANUP|])dnl
