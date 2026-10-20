dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_NUM_QM SX_SYS_NUM_ZR __sx_num_cmp_arith_digit|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_cmp_fixed_frac - 小数部を左から比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺

define([|CLEANUP|], [||])dnl

__sx_num_cmp_fixed_frac() {
	# 接頭辞チェック（正規化により、長い方が必ず大きい）
	# 冒頭で行うことで、長い小数部の延長比較をループなしで高速に処理する
	# 完全に一致する場合は即座に終了 (EQ)
	case "${1}" in
		"${2}") return 2;;
		"${2}"*) return 3;;
	esac

	case "${2}" in "${1}"*)
		return 1
	esac

	# 両方の文字列が窓幅以上の間、チャンクごとに比較
	while M_STR_MATCH([|"${1}"|], [|${SX_SYS_NUM_QM}?*|]) && M_STR_MATCH([|"${2}"|], [|${SX_SYS_NUM_QM}?*|]); do
		set -- "${1#${SX_SYS_NUM_QM}}" "${2#${SX_SYS_NUM_QM}}" "${1}" "${2}"
		__sx_num_cmp_arith_digit "${3%"${1}"}" "${4%"${2}"}" || case "${?}" in
			1 | 3) return "${?}";;
		esac
	done

	# 接頭辞の関係にない（＝どこかの桁で異なる）残りの部分をパディングして最後の比較
	set -- "${1}${SX_SYS_NUM_ZR}" "${2}${SX_SYS_NUM_ZR}"

	__sx_num_cmp_arith_digit "${1%"${1#${SX_SYS_NUM_QM}}"}" "${2%"${2#${SX_SYS_NUM_QM}}"}" || return "${?}"
}
|], [|num_cmp_fixed_frac|])dnl
popdef([|CLEANUP|])dnl
