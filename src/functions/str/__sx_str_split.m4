dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_STR_SPLIT_GLOB SX_STR_SPLIT_INC __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_str_split_empty __sx_var_bind __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_split - 方向・回数を準備して文字列を分割する（内部用）
##
## 使い方:
##   __sx_str_split バインド形式 [文字列 [区切り文字 [分割回数 [フラグ]]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   回数は符号付き10進整数、または無制限を表す空文字列を前提とする。
##   符号部分から方向を求め、絶対値を残り回数として扱う。空区切りは専用実装へ委譲する。
##   非空区切りでは、残り回数の範囲から通常の算術または多倍長の減算を選ぶ。
##   有限の残り回数は一回の分割ごとに1を減らし、無制限の空文字列は更新しない。
##   方向とリテラル/globの組み合わせでループを分け、ループ内でのglob判定を省く。
##   前方は直接バインドし、後方は位置パラメータに蓄積して前方順にバインドする。
##   INCの区切りは要素とまとめて渡す。割当途中の枯渇もバインドの終了ステータスで検出する。
##   バインドの初期化はここで一度だけ行い、空区切りの専用実装にも初期化済みの形式を渡す。
##
## 終了ステータス:
##    0  成功（バインド枯渇による早期終了を含む）

define([|CLEANUP|], [|Q_bind Q_str Q_sep Q_lim Q_dir Q_flg Q_glob Q_inc Q_type Q_rem Q_mid Q_val|])dnl

__sx_str_split() {
	# 空区切りの専用処理へ渡す場合も含め、バインド先の初期化はここで一度だけ行う。
	__sx_var_bind_init "${1}"

	# 符号付きゼロも分割なし。文字列全体を一要素として渡して終了する。
	case "${4-}" in 0 | [+-]0)
		__sx_var_bind '' "${1}" "${2-}" || :
		return
	esac

	Q_bind="${1}"
	Q_str="${2-}"
	Q_sep="${3-}"
	# 数字以降を除いた符号部分に1を付けて方向を求め、回数本体からは符号だけを除く。
	# 巨大な回数全体を算術展開に入れず、Q_limには正の残り回数または無制限の空を保持する。
	Q_lim="${4-}"
	Q_dir=$((${Q_lim%%[0-9]*}1))
	Q_lim="${Q_lim#[+-]}"
	Q_flg="${5-0}"
	Q_glob=$((Q_flg & SX_STR_SPLIT_GLOB))
	Q_inc=$(((Q_flg & SX_STR_SPLIT_INC) != 0))

	# 空区切り、および GLOB で * だけからなる区切りは、文字間と両端の境界を扱う。
	if
		M_STR_EQ([|"${Q_sep}"|], [|''|]) ||
		{ M_NUM_BOOL([|Q_glob|]) && ! M_STR_HAS([|"${Q_sep}"|], [|*[!*]*|]); }
	then
		# 初期化済みのバインドを渡し、専用実装から戻った後にこの関数の作業変数を破棄する。
		__sx_str_split_empty "${Q_bind}" "${Q_str}" "${Q_lim}" "${Q_dir}" "${Q_inc}"
		unset CLEANUP
		return
	fi

	# 減算対象は残り回数そのもの。文字数が少なくても上限は巨大になり得るので、上限を検査する。
	# 無制限では : を選び、空のQ_limを更新せずに区切りの有無だけで走査を終える。
	case "${Q_lim:+X}" in
		X)
			if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_lim}"; then
				Q_type=__sx_num_sub1_arith
			else
				Q_type=__sx_num_sub1_nat0
			fi
			;;
		*) Q_type=:;;
	esac

	# リテラルのINCでは区切り文字が常に同じなので一度だけ設定する。
	# INCなしではQ_midを未設定に保ち、後続の ${Q_mid+...} で区切りの引数を省略する。
	case "${Q_glob}${Q_inc}" in 01)
		Q_mid="${Q_sep}"
	esac

	# Q_bindは、各bind呼び出し後に残りのバインド形式へ更新される。
	# 要素と区切りの割当途中で枯渇すれば同じ呼び出しが1を返す。
	# 成功してちょうど使い切った場合も、次のbindで枯渇を検出したら正常終了する。
	case "${Q_dir}${Q_glob}" in
		# リテラルの前方分割。左端の区切りより前を、INCの区切りとともに順次渡す。
		10)
			while M_STR_NE([|"${Q_lim}"|], [|0|]) && M_STR_HAS([|"${Q_str}"|], [|"${Q_sep}"|]); do
				__sx_var_bind Q_bind "${Q_bind}" "${Q_str%%"${Q_sep}"*}" ${Q_mid+"${Q_mid}"} || {
					unset CLEANUP
					return
				}

				# 割当できた分割の区切りを消費し、選択済みの関数で残り回数を更新する。
				Q_str="${Q_str#*"${Q_sep}"}"
				"${Q_type}" Q_lim "${Q_lim}"
			done

			# 残り回数が0、または区切りなしで終わったら、未分割の残りを最後の要素にする。
			__sx_var_bind '' "${Q_bind}" "${Q_str}"
			;;
		# globの前方分割。左端の一致の前後を取り出し、INCなら実際の一致文字列も渡す。
		1*)
			while M_STR_NE([|"${Q_lim}"|], [|0|]) && M_STR_MATCH([|"${Q_str}"|], [|*${Q_sep}*|]); do
				Q_val="${Q_str%%${Q_sep}*}" Q_rem="${Q_str#*${Q_sep}}"

				# INC用に、前の要素を文字列として除いた部分を保持する。
				# bind時に後ろの残りも除く。データ側はクォートし、glob文字を再解釈させない。
				case "${Q_inc}" in 1)
					Q_mid="${Q_str#"${Q_val}"}"
				esac

				__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" ${Q_mid+"${Q_mid%"${Q_rem}"}"} || {
					unset CLEANUP
					return
				}

				Q_str="${Q_rem}"
				"${Q_type}" Q_lim "${Q_lim}"
			done

			__sx_var_bind '' "${Q_bind}" "${Q_str}"
			;;
		# リテラルの後方分割。右端から見つけた要素を前方順に戻すため、位置パラメータを空にする。
		-10)
			set --

			while M_STR_NE([|"${Q_lim}"|], [|0|]) && M_STR_MATCH([|"${Q_str}"|], [|*"${Q_sep}"*|]); do
				# 右端の要素を取り出し、INCの区切り・要素の順で位置パラメータの先頭へ積む。
				set -- ${Q_mid+"${Q_mid}"} "${Q_str##*"${Q_sep}"}" "${@}"

				Q_str="${Q_str%"${Q_sep}"*}"
				"${Q_type}" Q_lim "${Q_lim}"
			done

			# 未分割の先頭部分が確定したので、蓄積済みの要素とまとめて前方順に渡す。
			__sx_var_bind '' "${Q_bind}" "${Q_str}" "${@}"
			;;
		# globの後方分割。右端の一致を切り出し、区切り・要素の順で先頭へ積む。
		-1*)
			set --

			while M_STR_NE([|"${Q_lim}"|], [|0|]) && M_STR_MATCH([|"${Q_str}"|], [|*${Q_sep}*|]); do
				Q_val="${Q_str##*${Q_sep}}" Q_rem="${Q_str%${Q_sep}*}"

				# INC用に、右端の要素を文字列として除いた部分を保持する。
				# 先頭の残りも文字列として除き、一致した区切りだけを位置パラメータへ積む。
				case "${Q_inc}" in 1)
					Q_mid="${Q_str%"${Q_val}"}"
				esac

				set -- ${Q_mid+"${Q_mid#"${Q_rem}"}"} "${Q_val}" "${@}"

				Q_str="${Q_rem}"
				"${Q_type}" Q_lim "${Q_lim}"
			done

			__sx_var_bind '' "${Q_bind}" "${Q_str}" "${@}"
		;;
	# 最後のbindでの枯渇も成功扱いにし、作業変数の破棄へ進む。
	esac || :

	unset CLEANUP
}
|], [|str_split|])dnl
popdef([|CLEANUP|])dnl
