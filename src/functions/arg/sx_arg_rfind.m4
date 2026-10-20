dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_RFIND_CB SX_ARG_RFIND_GLOB SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_rfind __sx_num_is_nat0_safe __sx_var_is_bind __sx_var_is_bindable sx_cfg_is_valid|])dnl
pushdef([|CLEANUP|])dnl
### sx_arg_rfind - 引数リストから指定された値を末尾から探し、そのインデックスまたは値を取得する
##
## 使い方:
##   sx_arg_rfind bind [検索対象 [フラグ]] ::: [値 ...]
##   sx_arg_rfind bind [検索対象 [値 ...]]
##
## 説明:
##   sx_arg_find と同じだが、末尾から前方向に検索する。
##   一致した項目のインデックスを発見順（末尾から）にスペース区切りで結果変数に格納する。
##   フラグに SX_ARG_RFIND_TEXT (4) を指定すると、インデックスの代わりにマッチした値を出力する。
##   フラグに SX_ARG_RFIND_CB (2) を指定すると、検索対象をコールバック関数として扱う。
##   コールバックシグネチャ: callback value index count
##     0 を返すと一致、非0 は不一致としてスキップ。
##     count は現在の要素より右側で一致した件数（0開始）。
##   取得件数はバインド形式によって決まる。
##   呼び出し形式は sx_arg_find に準ずる。bind は必須（空文字列可）。
##   ::: なしでは第2引数が検索対象、第3引数以降がデータとなり、フラグは 0。
##   空 bind では検索せず 1 を返す。
##   引数個数・インデックス・一致数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった (不一致)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_rfind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rfind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_num_is_nat0_safe "${3}" || return M_EX_USAGE

			case "$(((${3} & SX_ARG_RFIND_GLOB) * (${3} & SX_ARG_RFIND_CB)))" in [!0])
				return M_EX_USAGE
			esac
			;;
	esac

	__sx_arg_rfind "${@}" || return
}

popdef([|CLEANUP|])dnl
