dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_SYS_NUM_QM SX_SYS_NUM_ZR|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_add_nat0 - 複数の絶対値をチャンク加算する（内部用）
##
## 使い方:
##   __sx_num_add_nat0 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を加算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   逐次方式でアキュムレータに各数値を順次加算する。

define([|CLEANUP|], [|Q_res Q_carry Q_out Q_rem1 Q_rem2 Q_ch1 Q_ch2 Q_tmp|])dnl

__sx_num_add_nat0() {
	Q_res="${1}"
	Q_rem1="${2-0}"

	shift "$((1 + 0${2+1}))"

	for Q_rem2 in "${@}"; do
		case "${Q_rem1}:${Q_rem2}" in
			*:0) continue;;
			${SX_SYS_NUM_QM}?*:* | *:${SX_SYS_NUM_QM}?*) ;;
			*)
				M_NUM_INCR([|Q_rem1|], [|Q_rem2|])
				continue
				;;
		esac

		# (2) 右端→左端 チャンク処理
		Q_carry=0
		Q_out=

		while
			# rem1 からチャンク抽出
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

			# rem2 からチャンク抽出
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

			Q_tmp=$((Q_ch1 + Q_ch2 + Q_carry))
			Q_carry=$((1${SX_SYS_NUM_ZR} <= Q_tmp))

			case "${Q_carry}:${Q_rem1}:${Q_rem2}" in
				?::) Q_rem1="${Q_tmp}${Q_out}" && break;;
				0:?*: | 0::?*)
					case "${Q_tmp}" in
						${SX_SYS_NUM_QM}) M_STR_APPEND([|Q_rem1|], [|"${Q_rem2}${Q_tmp}${Q_out}"|]);;
						*)
							# ゼロ埋めして前置（片方のチャンクが先頭ゼロ除去で短くなった場合の桁揃え）
							M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
							M_STR_APPEND([|Q_rem1|], [|"${Q_rem2}${Q_tmp#1}${Q_out}"|])
							;;
						esac

						break
						;;
				0:*)
					case "${Q_tmp}" in
						${SX_SYS_NUM_QM}) M_STR_PREPEND([|Q_out|], [|"${Q_tmp}"|]);;
						*)
							# ゼロ埋めして前置
							M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
							M_STR_PREPEND([|Q_out|], [|"${Q_tmp#1}"|])
							;;
					esac
					;;
				*) M_STR_PREPEND([|Q_out|], [|"${Q_tmp#1}"|]);;
			esac

			continue
		do :; done
	done

	M_VAR_SET([|${Q_res}|], [|${Q_rem1}|])

	unset CLEANUP
}
|], [|num_add_nat0|])dnl
popdef([|CLEANUP|])dnl
