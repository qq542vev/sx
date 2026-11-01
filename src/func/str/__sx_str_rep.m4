M_REQUIRE([|SX_SYS_NUM_QM __sx_num_divmod_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_rep - 文字列を繰り返す（内部用）
##
## 使い方:
##   __sx_str_rep 結果変数名 [元文字列 [繰り返し回数]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   繰り返し回数は、符号なし・先行する 0 のない10進整数（0 は可）を前提とする。
##   元文字列が空、または回数が0・1の場合は、作業変数を準備せず結果を返す。
##
## 終了ステータス:
##    0  成功

define([|CLEANUP|], [|Q_str Q_cnt Q_out|])dnl

__sx_str_rep() {
	case "${2:+${3:-1}}" in
		'' | 0)
			M_VAR_SET([|${1}|])
			return
			;;
		1)
			M_VAR_SET([|${1}|], [|${2}|])
			return
			;;
	esac

	Q_str="${2-}"
	Q_cnt="${3:-1}"
	Q_out=

	while
		case "${Q_cnt}" in *[13579])
			M_STR_APPEND([|Q_out|], [|"${Q_str}"|])
		esac

		case "${Q_cnt}" in
			${SX_SYS_NUM_QM}?*) __sx_num_divmod_nat0 Q_cnt: "${Q_cnt}" 2;;
			*) Q_cnt=$((Q_cnt / 2));;
		esac

		case "${Q_cnt}" in 0)
			break
		esac

		M_STR_APPEND([|Q_str|], [|"${Q_str}"|])
		continue
	do :; done

	M_VAR_SET([|${1}|], [|${Q_out}|])
	unset CLEANUP
}
|], [|str_rep|])dnl
popdef([|CLEANUP|])dnl
