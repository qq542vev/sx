dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_add1_nat0 __sx_num_divmod_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_divfloor_int - 符号付き整数の除算で切り捨て商を求める（内部用）
##
## 使い方:
##   __sx_num_divfloor_int 結果変数名 被除数 [除数]
##
## 説明:
##   sx_num_divfloor_int の内部実装。引数チェックは行わない。
##   前提: 結果変数名は有効で書き込み可能、被除数は任意の符号付き整数、
##   除数は 0 以外の符号付き整数であること。被除数・除数は省略時、
##   それぞれ 0、1 として扱われる。
##   絶対値どうしの除算（q0, r0）の後に floor 規約を適用する。
##   - r0 = 0 のとき: q = sign(u)×sign(v)×q0（“-0”は作らない）
##   - r0 ≠ 0 かつ同符号のとき: q = ±q0（打ち切りがそのまま floor になる）
##   - r0 ≠ 0 かつ異符号のとき: q = ±(q0 + 1)（負方向に1だけ丸める）
##   加算は増分前の値で判定し、符号付与は増分後の値で判定することで、
##   q0 = 0 のときの -1 と r0 = 0 のときの -0 回避を両立する。

define([|CLEANUP|], [|Q_q Q_r Q_neg|])dnl

__sx_num_divfloor_int() {
	set -- "${1}" "${2:-0}" "${3:-1}"
	case "${2}:${3}" in
		-*:[!-]* | [!-]*:-*) Q_neg=1;;
		*) Q_neg=0;;
	esac

	__sx_num_divmod_nat0 'Q_q:Q_r:' "${2#[+-]}" "${3#[+-]}"

	case "${Q_neg}" in 1)
		case "${Q_r}" in [!0]*)
			M_NUM_INCRM1([|Q_q|])
		esac

		case "${Q_q}" in [!0]*)
			M_STR_PREPEND([|Q_q|], [|-|])
		esac
	esac

	M_VAR_SET([|${1}|], [|${Q_q}|])
	unset CLEANUP
}
|], [|num_divfloor_int|])dnl
popdef([|CLEANUP|])dnl
