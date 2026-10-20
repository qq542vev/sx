dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_rquote - 引数を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_rquote スキーマ [値 ...]
##
## 説明:
##   sx_arg_rquote の内部実装。引数チェックは行わない。
##   データ個数が算術域内なら算術、それ以外は多倍長で添字を減らす。
##   添字とバインドの終了判定には算術を使用しない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_bind Q_i Q_type|])dnl

__sx_arg_rquote() {
	__sx_var_bind_init "${1}"

	case "${1:+${2+X}}" in '')
		return
	esac

	Q_bind="${1}"
	shift
	Q_i="${#}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_i}"; then
		Q_type=arith
	else
		Q_type=nat0
	fi

	while
		eval __sx_var_bind Q_bind '"${Q_bind}"' "\"\${${Q_i}}\""

		case "${Q_bind:+${Q_i}}" in '' | 1)
			break
		esac

		"__sx_num_sub1_${Q_type}" Q_i "${Q_i}"
		continue
	do :; done

	unset CLEANUP
}
|], [|arg_rquote|])dnl
popdef([|CLEANUP|])dnl
