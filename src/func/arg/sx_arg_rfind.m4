M_REQUIRE([|SX_CFG_SEP SX_CFG_SKIP_CHK __sx_arg_rfind __sx_num_is_nat0_safe __sx_var_is_bind __sx_var_is_bindable|])dnl
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
##   フラグに SX_ARG_RFIND_GLOB (1) を指定すると、検索対象を glob パターンとして扱う。
##   フラグに SX_ARG_RFIND_TEXT (4) を指定すると、インデックスの代わりにマッチした値を出力する。
##   フラグに SX_ARG_RFIND_CB (2) を指定すると、検索対象をコールバック関数として扱う。
##   フラグに SX_ARG_RFIND_NOT (8) を指定すると、一致しない要素を対象にする。
##   フラグに SX_ARG_RFIND_POS (16) を指定すると、インデックスを明示的に出力する。
##   フラグに SX_ARG_RFIND_ICASE (32) を指定すると、英字の大小を区別せずに照合する。
##   フラグに SX_ARG_RFIND_EQC (64) を指定すると、全文字を等価クラスとして照合する。
##   ICASE / EQC は検索対象をリテラルとして扱い、glob パターンとしては解釈しない。
##   GLOB・CB・ICASE・EQC は相互排他で、2つ以上を同時に指定すると 64 を返す。
##   NOT は GLOB・CB・TEXT・POS・ICASE・EQC のいずれとでも併用できる。
##   EQC は全文字を変換するため、長い検索対象ではパターンが大きくなる。
##   出力形式は POS と TEXT で指定し、指定されたフィールドだけを
##   POS:TEXT の固定順で ':' 連結する。指定順は結果に影響しない。
##   出力形式フラグを1つも指定しない場合は POS とみなし、従来どおりインデックスを返す。
##   例: POS なら "2"、TEXT なら "'b'"、POS|TEXT なら "2:'b'"。
##   値はクォートされるため、空白を含む場合は eval 等で復元する。
##   コールバックシグネチャ: callback value index count
##     0 を返すと一致、非0 は不一致としてスキップ。
##     count は現在の要素より右側で一致した件数（0開始）。
##     NOT 指定時は、count はそれまでに採用された不一致要素の件数となる。
##   取得件数はバインド形式によって決まる。
##   呼び出し形式は sx_arg_find に準ずる。bind は必須（空文字列可）。
##   ::: なしでは第2引数が検索対象、第3引数以降がデータとなり、フラグは 0。
##   空 bind では検索せず 1 を返す。
##   引数個数・インデックス・一致数に SX_CFG_NUM_RANGE による上限は設けない。
##
## 終了ステータス:
##    0  1つ以上の対象項目が見つかった (SX_EX_OK)
##    1  対象項目が見つからなかった (不一致)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  参照する設定値が不正または未設定 (SX_EX_CONFIG)
sx_arg_rfind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rfind "${@}" || return; return;; esac

	M_CFG_CHECK([|sx_arg_rfind|])

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_num_is_nat0_safe "${3}" || return M_EX_USAGE

			case "$((1 < ((${3} & M_ARG_RFIND_GLOB) != 0) + ((${3} & M_ARG_RFIND_CB) != 0) + ((${3} & M_ARG_RFIND_ICASE) != 0) + ((${3} & M_ARG_RFIND_EQC) != 0)))" in 1)
				return M_EX_USAGE
			esac
			;;
	esac

	__sx_arg_rfind "${@}" || return
}

popdef([|CLEANUP|])dnl
