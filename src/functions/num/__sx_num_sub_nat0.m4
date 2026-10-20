dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_NUM_QM SX_SYS_NUM_ZR|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_sub_nat0 - 絶対値のチャンク減算を行う（内部用）
##
## 使い方:
##   __sx_num_sub_nat0 結果変数名 被減数 減数
##
## 説明:
##   符号なし10進整数の絶対値（被減数 - 減数）を減算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   被減数 >= 減数 が保証されていること。

define([|CLEANUP|], [|Q_res Q_borrow Q_out Q_rem1 Q_rem2 Q_ch1 Q_ch2 Q_tmp|])dnl

__sx_num_sub_nat0() {
	Q_res="${1}"
	Q_rem1="${2-0}"
	Q_rem2="${3-0}"

	# 自明なケースと、両入力が語幅以内のケースを先に確定する
	case "${Q_rem1}:${Q_rem2}" in
		*:0)
			M_VAR_SET([|${Q_res}|], [|${Q_rem1}|])
			unset CLEANUP
			return
			;;
		"${Q_rem2}:${Q_rem2}")
			M_VAR_SET([|${Q_res}|], [|0|])
			unset CLEANUP
			return
			;;
		${SX_SYS_NUM_QM}?*:*) ;;
		*)
			M_VAR_SET([|${Q_res}|], [|$((Q_rem1 - Q_rem2))|])
			unset CLEANUP
			return
			;;
	esac

	Q_borrow=0
	Q_out=

	while
		case "${Q_rem1}" in
			${SX_SYS_NUM_QM}?*)
				Q_tmp="${Q_rem1%${SX_SYS_NUM_QM}}"
				Q_ch1="${Q_rem1#"${Q_tmp}"}"
				Q_rem1="${Q_tmp}"

				case "${Q_ch1}" in 0*)
					Q_ch1=$((1${Q_ch1} - 1${SX_SYS_NUM_ZR}))
				esac
				;;
			*)
				Q_ch1="${Q_rem1}"
				Q_rem1=
				;;
		esac

		case "${Q_rem2}" in
			${SX_SYS_NUM_QM}?*)
				Q_tmp="${Q_rem2%${SX_SYS_NUM_QM}}"
				Q_ch2="${Q_rem2#"${Q_tmp}"}"
				Q_rem2="${Q_tmp}"

				case "${Q_ch2}" in 0*)
					Q_ch2=$((1${Q_ch2} - 1${SX_SYS_NUM_ZR}))
				esac
				;;
			*)
				Q_ch2="${Q_rem2}"
				Q_rem2=
				;;
		esac

		Q_tmp=$((${Q_ch1:-0} - ${Q_ch2:-0} - Q_borrow))
		Q_borrow=$((Q_tmp < 0))

		case "${Q_borrow}:${Q_rem1}:${Q_rem2}" in
			0::)
				# 両方の剰余が枯渇 → 最上位チャンクはゼロ埋めせず前置する
				M_STR_PREPEND([|Q_out|], [|"${Q_tmp}"|])
				break
				;;
			0:*:)
				case "${Q_tmp}" in
					${SX_SYS_NUM_QM}*) M_STR_PREPEND([|Q_out|], [|"${Q_rem1}${Q_tmp}"|]);;
					*)
						# rem2 のみ枯渇、rem1 に未処理チャンクあり → ゼロ埋めして桁揃え
						M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
						M_STR_PREPEND([|Q_out|], [|"${Q_rem1}${Q_tmp#1}"|])
						;;
				esac

				break
				;;
			1:*) M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|]);&
			*)
				case "${Q_tmp}" in
					${SX_SYS_NUM_QM}*) M_STR_PREPEND([|Q_out|], [|"${Q_tmp}"|]);;
					*)
						M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
						M_STR_PREPEND([|Q_out|], [|"${Q_tmp#1}"|])
						;;
				esac
				;;
		esac

		continue
	do :; done

	# 最上位チャンクの0や下位チャンクの桁揃え用ゼロを除去する
	case "${Q_out}" in 0*)
		Q_out="M_STR_LTRIM([|Q_out|], [|[!0]|])"
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_out:-0}|])

	unset CLEANUP
}
|], [|num_sub_nat0|])dnl
popdef([|CLEANUP|])dnl
