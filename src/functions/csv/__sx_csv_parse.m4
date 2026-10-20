dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_STR_CR SX_STR_LF __sx_arr_gen __sx_num_add1_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_csv_parse - CSV を解析し、行ごとの確定フィールドを保存する（内部用）
##
## 使い方:
##   __sx_csv_parse res [data [errcallback [sep [quote]]]]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   data の既定値は空文字列。
##   位置パラメータに現在行の完成フィールドを保持し、行が完成してから結果へ書き込む。
##   構文エラーでは、失敗行も確定済みフィールドだけで保存する。0列の行も保存する。
##   状態は start（先頭）・plain（非引用）・quoted（引用内）・closed（引用終了）。
##   start からは通常文字で plain、quote 内のいずれかの文字で quoted に移る。
##   開始に使った一文字を保持し、quoted ではその文字の二重化を一文字に戻し、単独なら closed に移る。
##   quoted 内の別の引用符は、quote に含まれていても通常文字として保持する。
##   start・plain・closed では区切り・改行・入力終了でフィールドを確定し、start に戻る。
##   空の sep は内部で LF に置き換え、行区切りを優先して判定することで列分割を無効にする。
##   plain 内の引用符、closed 後の通常文字、quoted のままの入力終了は構文エラーとする。
##   通常文字をまとめて消費し、引用内の区切り・改行をそのまま保持する。
##   CRLF の CR は、非引用フィールドを LF で確定するときだけ除く。
##   引用内の通常文字と直後の引用符を同じ反復で処理し、閉じ引用符なら続けて境界を判定する。
##   配列の生成は __sx_arr_gen に委譲する。行の生成時だけ参照・穴の解釈を無効にする。
##   生成処理で使う配列設定は保存し、成功・エラーのどちらでも通知前に復元する。
##   各行と外側の配列のリビジョンは ARR_UPDATE にかかわらず更新する。
##   既存配列の削除は行わない。再代入前の削除は呼び出し側の責任とする。
##   コールバックの前に作業変数を解放し、同関数への再入を許可する。
##   コールバックを呼んだ場合は、その終了ステータスをそのまま返す。
##
## 終了ステータス:
##   コールバックを呼んだ場合はその終了ステータス。それ以外は以下を返す。
##    0  成功
##    1  引用符が閉じないまま入力終了
##    2  非引用フィールド内に引用符が出現
##    3  閉じ引用符の後に不正な文字が出現

define([|CLEANUP|], [|Q_res Q_data Q_cb Q_sep Q_quote Q_open Q_field Q_state Q_err Q_chunk Q_kind Q_ref Q_hole|])dnl

__sx_csv_parse() {
	Q_res="${1}" Q_data="${2-}" Q_cb="${3-}" Q_sep="${4:-${4-,}${4+${SX_STR_LF}}}" Q_quote="${5-\"}"
	Q_ref="${SX_CFG_ARR_REF}" Q_hole="${SX_CFG_ARR_HOLE}"

	# Q_data は未消費の入力、Q_field は現在組み立てているフィールド。
	# 結果配列の長さを保存済み行数と次の行の0始まりの添字に使う。
	Q_field='' Q_state=start Q_err=0
	__sx_arr_gen "${Q_res}"
	# 元の引数を退避したので、位置パラメータを現在行の完成フィールド一覧に使い直す。
	# 未完成の Q_field はここへ含めず、区切り・改行・入力終了を確認してから追加する。
	set --

	while
		# 引用内の通常文字と引用符を一度に消費する。
		case "${Q_state}" in quoted)
			Q_chunk="${Q_data%%"${Q_open}"*}"
			M_STR_APPEND([|Q_field|], [|"${Q_chunk}"|])
			Q_data="${Q_data#"${Q_chunk}"}"

			case "${Q_data}" in
				'') Q_err=1; break;;
				?"${Q_open}"*)
					M_STR_APPEND([|Q_field|], [|"${Q_open}"|])
					Q_data="${Q_data#??}"
					continue
					;;
				*) Q_data="${Q_data#?}" Q_state=closed;;
			esac
		esac

		# 引用外では、文字を追加する前にフィールド・行の境界を判定する。
		# Q_kind は field（列区切り）・row（行区切り）・eof（入力終了）の確定理由。
		# 行区切りを先に判定するため、空の sep を置き換えた LF は列区切りにならない。
		case "${Q_data}" in
			'')
				# フィールドを開始しておらず完成フィールドもなければ、保存すべき行はない。
				# 空入力と末尾改行後が該当する。末尾の列区切り後は完成フィールドがあるため、
				# この分岐では終了せず、後段で最後の空フィールドを確定する。
				case "${Q_state}:${#}" in start:0)
					break
				esac

				Q_kind=eof
				;;
			"${SX_STR_CR}${SX_STR_LF}"*) Q_data="${Q_data#??}" Q_kind=row;;
			"${SX_STR_LF}"*)
				# 非引用フィールドだけ、行区切りに属する末尾の CR を除く。
				case "${Q_state}" in plain)
					Q_field="${Q_field%"${SX_STR_CR}"}"
				esac

				Q_data="${Q_data#?}" Q_kind=row
				;;
			"${Q_sep}"*) Q_data="${Q_data#"${Q_sep}"}" Q_kind=field;;
			*)
				# 境界に一致しなかったため、closed の後なら許可されない文字が続いている。
				case "${Q_state}" in closed)
					Q_err=3
					break
				esac

				case "${Q_quote:+${Q_data}}" in ["${Q_quote}"]*)
					# 引用を開始できるのは start だけ。非引用フィールドの途中では拒否する。
					case "${Q_state}" in plain)
						Q_err=2
						break
					esac

					# Q_quote は候補の集合、Q_open は今回のフィールドを開始した一文字。
					# quoted の間は Q_open だけを閉じ引用符・エスケープとして認識する。
					Q_open="${Q_data%"${Q_data#?}"}"
					Q_state=quoted Q_data="${Q_data#?}"
					continue
				esac

				# 境界と引用符の直前までを通常文字として消費し、plain に移る。
				# 境界自体は残し、次の反復で上の判定に処理させる。
				# 通常文字の切り出しは一度だけなので、空の Q_field へ直接格納する。
				Q_field="${Q_data%%"${Q_sep}"*}"
				Q_field="${Q_field%%["${SX_STR_LF}${Q_quote}"]*}"
				Q_state=plain Q_data="${Q_data#"${Q_field}"}"
				continue
				;;
		esac

		# 境界を検出した経路だけがここへ来る。空でも一つのフィールドとして確定する。
		# 次のフィールドに備えて Q_field と Q_state を戻すが、完成フィールド一覧は保持する。
		set -- "${@}" "${Q_field}"
		Q_field='' Q_state=start

		# 列区切りなら同じ行を解析し続ける。改行または入力終了なら行全体を保存する。
		case "${Q_kind}" in field)
			continue
		esac

		# 完成フィールド一覧を一行の配列にし、その行が保存できてから外側の長さを増やす。
		# 構文エラーによる未完成行はループ終了後に確定済みフィールドだけを保存する。
		# フィールドを文字列のまま保存するため、行生成時だけ参照・穴の解釈を無効にする。
		eval SX_CFG_ARR_REF= SX_CFG_ARR_HOLE= __sx_arr_gen "${Q_res}_\${${Q_res}_len}" '"${@}"' ';' __sx_num_add1_nat0 "${Q_res}_len" "\"\${${Q_res}_len}\""
		# 現在行の一覧を空にして次の行へ。入力終了の場合は、この行を保存してから抜ける。
		set --

		case "${Q_kind}" in eof)
			break
		esac

		continue
	do :; done

	# 失敗したフィールドは Q_field に残したまま、確定済みの列だけで失敗行を保存する。
	# 第1列で失敗した場合も0列の行を作り、失敗行も結果配列の長さに含める。
	case "${Q_err}" in [1-9]*)
		eval SX_CFG_ARR_REF= SX_CFG_ARR_HOLE= __sx_arr_gen "${Q_res}_\${${Q_res}_len}" '"${@}"' ';' __sx_num_add1_nat0 "${Q_res}_len" "\"\${${Q_res}_len}\""
	esac

	# 成功・エラーとも元の設定に戻し、コールバックにも呼び出し時の設定を見せる。
	SX_CFG_ARR_REF="${Q_ref}" SX_CFG_ARR_HOLE="${Q_hole}"

	# 解析は完了したので、位置パラメータを完成フィールド一覧から最後に実行するコマンドへ変える。
	# エラーかつコールバック指定ありの場合だけ通知し、それ以外は解析ステータスを返す。
	case "${Q_cb:+${Q_err}}" in
		[1-9]*)
			# 失敗行を含む保存済み行数が1始まりの行番号。
			# ダミー引数を一つ加え、引数個数を1始まりの列番号にする。
			set -- "${@}" 0
			eval set -- '"${Q_cb}"' "${Q_err}" "\"\${${Q_res}_len}\"" "${#}"
			;;
		*) set -- return "${Q_err}";;
	esac

	# 通知引数と終了ステータスは位置パラメータへ移したので、作業変数を先に解放できる。
	# コールバックから同じ関数へ再入しても干渉せず、コールバックの終了ステータスをそのまま返す。
	unset CLEANUP
	"${@}"
}
|], [|csv_parse|])dnl
popdef([|CLEANUP|])dnl
