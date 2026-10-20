dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_STR_ISEP_CB SX_STR_ISEP_POST SX_STR_ISEP_PRE SX_SYS_NUM_MAX __sx_num_cmp_arith __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_str_isep_cb __sx_str_isep_lit __sx_str_qm __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_isep - 挿入方向・上限・数値経路とパターンを準備する（内部用）
##
## 使い方:
##   __sx_str_isep バインド形式 文字列 セパレータ [インターバル [リミット [フラグ]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   インターバルは非0の符号付き、リミットは符号なしの正規化済み10進整数を前提とする。
##   上限の省略は空文字列のまま保持し、回数との文字列一致で判定する。
##   回数は高々文字列長+1なので、文字列長が数値範囲の最大値なら多倍長経路へ回す。
##   内部境界がない間隔では ? パターンを生成しない。
##   コールバックへ委譲する前に準備用変数を解放する。
##
## 終了ステータス:
##    0  成功
##   非0  コールバックの終了ステータス

define([|CLEANUP|], [|Q_len Q_abs Q_type Q_qm Q_dir Q_start Q_end|])dnl

__sx_str_isep() {
	set -- "${1}" "${2-}" "${3-}" "${4:-1}" "${5-}" "${6:-0}"

	case "${5}" in 0)
		__sx_var_bind_init "${1}"
		__sx_var_bind '' "${1}" "${2}" 0 || :
		return
	esac

	Q_len="${#2}"
	Q_abs="${4#[+-]}"
	Q_dir=$((${4%%"${Q_abs}"}1 < 0))

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_len}" "${Q_abs}" && M_STR_NE([|"${Q_len}"|], [|"${SX_SYS_NUM_MAX}"|]); then
		Q_type=arith
	else
		Q_type=nat0
	fi

	case "${Q_dir}" in
		0) Q_start=$((${6} & SX_STR_ISEP_PRE)) Q_end=$(((${6} & SX_STR_ISEP_POST) && 0${2:+1}));;
		1) Q_start=$((${6} & SX_STR_ISEP_POST)) Q_end=$(((${6} & SX_STR_ISEP_PRE) && 0${2:+1}));;
	esac

	"__sx_num_cmp_${Q_type}" "${Q_abs}" "${Q_len}" || case "${?}" in 1)
		__sx_str_qm Q_qm "${Q_abs}"
	esac

	set -- "${1}" "${2}" "${3}" "${Q_abs}" "${5}" "${Q_type}" "${Q_qm-}" "${Q_dir}" "${Q_start}" "${Q_end}" "$((${6} & SX_STR_ISEP_CB))"
	unset CLEANUP

	case "${11}" in
		0) __sx_str_isep_lit "${@}";;
		*) __sx_str_isep_cb "${@}";;
	esac || return
}
|], [|str_isep|])dnl
popdef([|CLEANUP|])dnl
