dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_divmod_nat0 __sx_num_mul_nat0 __sx_str_qm __sx_str_zr|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_div_nat0 - 絶対値の除算で実数商（整数商 + 小数部）を求める（内部用）
##
## 使い方:
##   __sx_num_div_nat0 結果変数名 小数桁数 被除数 [除数1 [除数2 ...]]
##
## 説明:
##   sx_num_div_nat0 の内部実装。引数チェックは行わない。
##   前提: 小数桁数は 0 以上の自然数、被除数は 0 以上の自然数、
##   すべての除数は 1 以上の自然数であること。
##
##   実行フロー（ステップ 1〜3）:
##   1) すべての除数を __sx_num_mul_nat0 で乗算して単一の除数 den を求める
##      （除数が無い場合は 1）。
##   2) __sx_num_divmod_nat0 で整数商 q と余剰 r を求める。
##   3) 小数桁数 dp が 1 以上で余剰 r が 0 でない場合、小数部 dec を
##      floor(余剰 × 10^dp ÷ den) の商として dp 桁にゼロ埋めした文字列で求め、
##      末尾の 0 を除去する。dec が空（小数が 0）になれば整数商 q をそのまま返す。
##      ゼロ埋めの '?'×桁数 / "0"×桁数 は SX_NUM_QM / SX_NUM_ZR 定数（1〜37 桁）から参照し、
##      37 桁を超える場合のみ __sx_str_rep で生成する。

define([|CLEANUP|], [|Q_res Q_dp Q_u Q_den Q_q Q_r Q_dec Q_zr Q_qm|])dnl

__sx_num_div_nat0() {
	# ステップ 1: 引数の取得（結果変数名、小数桁数 dp、被除数 u、除数群）
	Q_res="${1}"
	Q_dp="${2:-0}"
	Q_u="${3:-0}"
	shift 3

	case "${Q_u}" in 0 | +0 | -0)
		M_VAR_SET([|${Q_res}|], [|0|])
		unset CLEANUP
		return M_EX_OK
	esac

	# ステップ 2: すべての除数を乗算して単一の除数にする（除数が無い場合は 1）
	__sx_num_mul_nat0 Q_den "${@}"

	# ステップ 3: 整数商と余剰を求める
	__sx_num_divmod_nat0 "Q_q:Q_r:" "${Q_u}" "${Q_den}"

	# ステップ 4: 小数部の導出（dp が 1 以上かつ余剰が 0 でない場合のみ）
	#   dec = floor(余剰 × 10^dp ÷ den) を dp 桁にゼロ埋めした文字列（末尾 0 は除去）
	Q_dec=

	case "${Q_dp}${Q_r}" in [!0]*[!0]*)
		# "0"×dp は SX_NUM_ZR 定数（1〜37 桁）から参照し、超過時のみ str_rep で生成する
		__sx_str_zr Q_zr "${Q_dp}"

		# 小数部 = 余剰 × 10^dp ÷ den の整数商（この除算の余りは不要）
		__sx_num_divmod_nat0 "Q_dec:" "${Q_r}${Q_zr}" "${Q_den}"

		# dec が dp 桁未満の場合のみ先頭をゼロ埋めする（len == dp なら定数参照を丸ごとスキップ）
		if M_STR_NE([|"${#Q_dec}"|], [|"${Q_dp}"|]); then
			# 前置 "0"×dp から剥ぎ取る '?'×len(dec) は SX_NUM_QM 定数（1〜37 桁）から参照する
			__sx_str_qm Q_qm "${#Q_dec}"

			# "0"×dp を前置して '?'×len(dec) を剥ぎ、末尾 dp 桁だけを採用する
			# （dec は高々 dp 桁のため、桁不足のときのみこのパスに来る）
			M_STR_PREPEND([|Q_dec|], [|"${Q_zr}"|])

			# '?'×len(dec) は ? がパターン一致として働く必要があるため、
			# 内側の展開は意図的にクォートしない（クォートすると ? がリテラル化して剥ぎ取りが失敗する）
			Q_dec="${Q_dec#${Q_qm}}"
		fi

		# 小数部の末尾 0 を除去する
		case "${Q_dec}" in *0)
			Q_dec="M_STR_RTRIM([|Q_dec|], [|[!0]|])";;
		esac
	esac

	# 小数部が空（小数が 0）なら "." を付けず整数商のまま
	case "${Q_dec:+X}" in X)
		M_STR_APPEND([|Q_q|], [|".${Q_dec}"|])
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_q}|])
	unset CLEANUP
}
|], [|num_div_nat0|])dnl
popdef([|CLEANUP|])dnl
