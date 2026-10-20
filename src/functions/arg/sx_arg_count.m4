dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_COUNT_CB SX_ARG_COUNT_GLOB SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_count __sx_num_is_nat0_safe __sx_var_is_rw sx_cfg_is_valid sx_var_is_name|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_count - 引数リストから指定された値の出現回数を取得する
##
## 使い方:
##   sx_arg_count 結果変数名 [検索対象 [arg ...]]
##   sx_arg_count 結果変数名 [検索対象 [フラグ]] ::: [arg ...]
##
## 説明:
##   引数リストから検索対象と一致する値の出現回数を数え、結果変数に非負整数で格納する。
##   フラグの意味は sx_arg_find と同一（SX_ARG_COUNT_GLOB, SX_ARG_COUNT_CB）。
##   SX_ARG_COUNT_CB (2) を指定すると、検索対象をコールバック関数として扱う。
##   コールバックシグネチャ: callback 値 インデックス 一致数
##     0 を返すと一致、非0 は不一致としてスキップ。
##     一致数は現在の要素より前で一致した件数（0開始）。
##   実質的に __sx_arg_find に委譲し、結果のスペース区切り件数を __sx_arg_len で取得する。
##   引数個数・インデックス・一致数に SX_CFG_NUM_RANGE による上限は設けない。
##
##   空の検索対象を指定した場合、空文字の値のみが一致とみなされる。
##   結果変数名は必須。:::（SX_CFG_SEP）なしでは第2引数が検索対象、
##   第3引数以降がデータとなり、フラグは 0 とする。
##   検索対象の省略時は空文字列とする。::: 形式では検索対象・フラグを
##   省略でき、::: より後はすべてデータとして扱う。
##   データ先頭付近に SX_CFG_SEP の値を含む場合は、::: 形式で境界を明示する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_count() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_count "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_num_is_nat0_safe "${3}" || return M_EX_USAGE

			case "$(((${3} & SX_ARG_COUNT_GLOB) * (${3} & SX_ARG_COUNT_CB)))" in [!0])
				return M_EX_USAGE
			esac
			;;
	esac

	__sx_arg_count "${@}"
}

popdef([|CLEANUP|])dnl
