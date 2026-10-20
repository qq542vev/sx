dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_arith __sx_num_sub1_nat0 __sx_num_sub_nat0 __sx_str_qm __sx_var_bind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_str_split_empty - 空区切りの境界を前方順に直接バインドする（内部用）
##
## 使い方:
##   __sx_str_split_empty バインド形式 元文字列 上限絶対値 方向 INC
##
## 説明:
##   内部実装。引数チェックは行わない。バインド形式は初期化済みを前提とする。
##   上限は正の10進整数または無制限を表す空文字列、方向は1/-1、INCは0/1。
##   後方分割は上限指定を必須とし、無制限は前方分割として扱う。
##   後方分割は先頭部分を確定した後、残りを前方順にバインドする。
##   先頭部分の切り出しは短い側の ? パターンを使い、空側では生成しない。
##   文頭と文末が重なる空入力の境界は一つだけ処理する。
##   前方の上限が元文字列長を超える場合は、残り回数を更新せず全境界を処理する。
##   残り回数を減らすのは、前方の上限が元文字列長以下の場合だけ。文字列長から数値経路を選ぶ。
##   INCの空区切りは要素と一度にバインドする。
##   バインドの終了ステータスで枯渇を検出する。枯渇後の一回の切り取り・回数更新は許容する。
##
## 終了ステータス:
##    0  成功（バインド枯渇による早期終了を含む）

define([|CLEANUP|], [|Q_bind Q_str Q_lim Q_sep Q_len Q_type Q_tail Q_head Q_qm Q_rem Q_val|])dnl

__sx_str_split_empty() {
	# Q_val は次に渡す要素、Q_str はまだ渡していない残り。
	# 前方分割の最初の要素は文頭の空文字列なので、Q_val を空で開始する。
	Q_bind="${1}" Q_str="${2}" Q_lim="${3}"
	# 既定では回数を更新しない。必要な前方分割だけ、後で減算関数へ切り替える。
	Q_len="${#2}" Q_val= Q_type=:

	# INCありの場合だけ空の区切りを設定する。未設定ならbindの追加引数を省略できる。
	case "${5}" in 1)
		Q_sep=
	esac

	case "${4}" in -1)
		# 後方指定ではQ_limは必ず正の回数。無制限の空指定は方向1で渡される。
		# 後方から k 回切ると、文末境界に一回使い、末尾 k-1 文字が一文字ずつになる。
		# n=5, k=3 の例: 'abc' 'd' 'e' ''。先頭 'abc' をまず Q_val に確定する。
		# k-1 >= n なら全境界を切れるため、前方無制限と同じ初期状態でよい。
		__sx_num_sub1_nat0 Q_tail "${Q_lim}"
		# 比較の終了状態は 1:左が小、2:等しい、3:左が大。ここでは末尾長 < n のみ処理する。
		__sx_num_cmp_nat0 "${Q_tail}" "${Q_len}" || case "${?}" in 1)
			case "${Q_tail}" in
				# k=1 では文末だけを切るので、先頭要素は元文字列全体になる。
				0) Q_val="${Q_str}" Q_str=;;
				*)
					__sx_num_sub_nat0 Q_head "${Q_len}" "${Q_tail}"
					# 切り出すための ? 列は、先頭長と末尾長の短い側だけ生成する。
					__sx_num_cmp_nat0 "${Q_head}" "${Q_tail}" || case "${?}" in
						1)
							# 先頭長 < 末尾長: 先頭を除いて残りを得てから、先頭要素を復元する。
							__sx_str_qm Q_qm "${Q_head}"
							Q_rem="${Q_str#${Q_qm}}"
							Q_val="${Q_str%"${Q_rem}"}"
							Q_str="${Q_rem}"
							;;
						*)
							# 末尾長 <= 先頭長: 末尾を除いて先頭要素を得てから、残りを求める。
							__sx_str_qm Q_qm "${Q_tail}"
							Q_val="${Q_str%${Q_qm}}"
							Q_str="${Q_str#"${Q_val}"}"
							;;
					esac
					;;
			esac
		esac
		# 後方の上限は先頭要素の切り出しに反映済み。残りは前方へ最後まで走査する。
		Q_lim=
	esac

	# n文字にはn+1個の境界がある。前方の上限 > nなら、回数を更新せず残りが空になるまで進める。
	# Q_limが空なら、比較左辺にはQ_lenの十進表記の先頭へ1を付けた、一桁長い値を使う。
	# 後方・無制限でもこの値は必ずQ_lenより大きくなり、減算関数の選択を省ける。
	__sx_num_cmp_nat0 "${Q_lim:-1${Q_len}}" "${Q_len}" || case "${?}" in [12])
		# この分岐では0 < Q_lim <= Q_len。文字数が算術域内なら、減算対象も安全に扱える。
		if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_len}"; then
			Q_type=__sx_num_sub1_arith
		else
			Q_type=__sx_num_sub1_nat0
		fi
	esac

	# 一周で要素と、INC指定時はその直後の空区切りを渡す。残りが空でも最初の一周は必要。
	# 空入力も一つの境界を切り、最後の残りと合わせて空要素二つ（INC なら三つ）になる。
	# 走査はwhileの条件部で行う。bind枯渇はreturn、残りが空・残り回数0はbreakで終了する。
	while
		# 要素とINCの空区切りを順に割り当て、途中で枯渇すればそのまま成功終了する。
		__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" ${Q_sep+"${Q_sep}"} || {
			unset CLEANUP
			return
		}

		# この境界で使った一回を減らす。Q_typeが : の場合、空または文字数を超える上限を保つ。
		"${Q_type}" Q_lim "${Q_lim}"

		# 残りが空、または残り回数が0なら終了する。
		# 無制限を表す空のQ_limはXに置き換え、残りがある間は走査を続ける。
		case "${Q_str:+${Q_lim:-X}}" in '' | 0)
			break
		esac

		# 次の要素を一文字だけ取り出す。バインド先が尽きた直後も一回だけ進むことがある。
		Q_rem="${Q_str#?}"
		Q_val="${Q_str%"${Q_rem}"}"
		Q_str="${Q_rem}"

		# 条件部の走査処理を繰り返す。do節へは進まず、次の要素のbindへ戻る。
		continue
	do :; done

	# 回数を使い切った場合は未分割の残り、全境界を処理した場合は文末の空要素を渡す。
	# 最後の割当でバインド先を使い切っていた場合も、ここで返る1は正常扱いとする。
	__sx_var_bind '' "${Q_bind}" "${Q_str}" || :
	unset CLEANUP
}
|], [|str_split_empty|])dnl
popdef([|CLEANUP|])dnl
