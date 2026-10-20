dnl 定義と依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE SX_NUM_QM_1 SX_NUM_QM_10 SX_NUM_QM_11 SX_NUM_QM_12 SX_NUM_QM_13 SX_NUM_QM_14 SX_NUM_QM_15 SX_NUM_QM_16 SX_NUM_QM_17 SX_NUM_QM_18 SX_NUM_QM_19 SX_NUM_QM_2 SX_NUM_QM_20 SX_NUM_QM_21 SX_NUM_QM_22 SX_NUM_QM_23 SX_NUM_QM_24 SX_NUM_QM_25 SX_NUM_QM_26 SX_NUM_QM_27 SX_NUM_QM_28 SX_NUM_QM_29 SX_NUM_QM_3 SX_NUM_QM_30 SX_NUM_QM_31 SX_NUM_QM_32 SX_NUM_QM_33 SX_NUM_QM_34 SX_NUM_QM_35 SX_NUM_QM_36 SX_NUM_QM_37 SX_NUM_QM_4 SX_NUM_QM_5 SX_NUM_QM_6 SX_NUM_QM_7 SX_NUM_QM_8 SX_NUM_QM_9 SX_NUM_ZR_1 SX_NUM_ZR_10 SX_NUM_ZR_11 SX_NUM_ZR_12 SX_NUM_ZR_13 SX_NUM_ZR_14 SX_NUM_ZR_15 SX_NUM_ZR_16 SX_NUM_ZR_17 SX_NUM_ZR_18 SX_NUM_ZR_19 SX_NUM_ZR_2 SX_NUM_ZR_20 SX_NUM_ZR_21 SX_NUM_ZR_22 SX_NUM_ZR_23 SX_NUM_ZR_24 SX_NUM_ZR_25 SX_NUM_ZR_26 SX_NUM_ZR_27 SX_NUM_ZR_28 SX_NUM_ZR_29 SX_NUM_ZR_3 SX_NUM_ZR_30 SX_NUM_ZR_31 SX_NUM_ZR_32 SX_NUM_ZR_33 SX_NUM_ZR_34 SX_NUM_ZR_35 SX_NUM_ZR_36 SX_NUM_ZR_37 SX_NUM_ZR_4 SX_NUM_ZR_5 SX_NUM_ZR_6 SX_NUM_ZR_7 SX_NUM_ZR_8 SX_NUM_ZR_9 SX_SYS_NUM_WLEN SX_SYS_NUM_ZR __sx_num_add1_nat0 __sx_num_cmp_nat0 __sx_num_is_int_fit_dec __sx_str_qm __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_num_divmod_nat0 - 絶対値の除算で整数商と余剰を同時に求める（内部用）
##
## 使い方:
##   __sx_num_divmod_nat0 バインド形式 被除数 [除数]
##
## 説明:
##   符号なし10進整数の絶対値の除算を行う。
##   第一引数は商・余剰の割り当て先を指定する分配代入バインド形式（例: "q:r:"）。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   除数が 0 でないことが保証されていること。
##   被除数・除数は省略時、それぞれ 0、1 として扱われる。
##
##   アルゴリズム: 語サイズ c = WLEN/2 桁で語分割する融合 Knuth D 法。
##   語の並びは常に「最上位語が先頭」で、v_1 が最上位語、v_n が最下位語。
##   u は先頭にゼロ語 u_1 = 0 を 1 語追加して合計 K 語で持ち、実データは u_2..u_K
##   （u_1 は主ループの最初の窓が参照するために確保するセンチネル語）。
##
##   実行フロー（ステップ 1〜9）:
##   1) 引数の取得（商・余剰の結果変数名、被除数 u、除数 v）。
##   2) 高速パス 1〜3: 自明なケースを確定する。
##      v = 1 → 商 = u、余り = 0 ／ u = v → 商 = 1、余り = 0
##      u < v → 商 = 0、余り = u（同桁数は最上位桁から 1 桁ずつ比較する）。
##   3) 語サイズ c の決定（c = WLEN/2。語積 10^(2c) は RANGE の算術幅に収まる）。
##   4) 末尾ゼロ分解: v = m × 10^k に分解し、u も 10^k で縮小する
##      （商は不変、余りは最後に u の下位 k 桁を復元する）。
##   5) 高速パス 4: 被除数全体が RANGE の算術幅（WLEN 桁）以内なら
##      ネイティブ除算で確定する。
##   6) 高速パス 5: 除数が (WLEN-1)*9/10 桁以内なら語幅 c = WLEN - len(v)（約 WLEN/10 + 1）の
##      語単位ネイティブ筆算で O(語数) に確定する。
##   7) 一般パス: 融合 Knuth D 法（u > v、u は 19 桁以上、v は 2 語以上）。
##      7.1 正規化: u、v を 10^d 倍して v の先頭語をちょうど c 桁に揃える。
##      7.2 語分割: v を n 語（v_1..v_n）、u を K 語に分解する。u 語は変数ではなく
##          位置パラメータ上で保持する（MS-first: $1 = u_1 = センチネル 0、$2..$# = u_2..u_K）。
##          （7.1 の v 左切り出しと正規化は 1 ループで同時に行い、u も右剥ぎ 1 ループで
##          語の中身を取りながら分割する。v の正規化は最下位語 v_n への 0^d 付加のみ）。
##      7.3 主ループ: 窓（$1..$(n+1) = u_{W-n}..u_W）を 1 語ずつ左へずらしながら商を 1 語ずつ確定する。
##          D2 商の見積り → D3 精緻化 → D4 融合 multiply-subtract → D5 加算復帰。
##          各反復末尾で shift n+1 → set -- ${new_} "$@" → shift 1 により窓を更新する。
##      7.4 余り抽出: ループ終了後に位置パラメータへ残る末尾 n 語（u_{K-n+1}..u_K）を連結する。
##      7.5 逆正規化: 余りの末尾 d 桁を除去して 10^d 倍を戻す。
##   8) 商・余剰を結果変数に格納し、内部変数を全て解放する。
##   ネイティブ演算の語積は必ず qhat*v_j < b^2 = 10^(2c) に収まり、
##   c = WLEN/2 より 10^(2c) は SX_CFG_NUM_RANGE の算術幅内に収まる。

define([|CLEANUP|], [|Q_tmp Q_bind Q_u Q_v Q_c Q_b Q_qm Q_zr Q_d Q_qmd Q_n Q_chunk Q_q Q_r Q_t Q_top2 Q_qhat Q_rhat Q_uw Q_p Q_carry Q_ck Q_ut Q_new Q_zv Q_btail Q_vstr Q_v1 Q_v2|])dnl

__sx_num_divmod_nat0() {
	# ステップ 1: 引数の取得（バインド形式と、被除数 u・除数 v の値）
	#   q_/r_ は直前のフレーム（再帰呼び出し元）から値が残っている場合があるため、
	#   計算前に必ずクリアする（6505 の分岐が q_ の残存値に誤導されるのを防ぐ）。
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_u="${2:-0}"
	Q_v="${3:-1}"
	Q_q=
	Q_r=

	# ステップ 2: 高速パス 1〜3（自明なケースを即座に確定する）
	#   高速パス 1: 除数が 1 なら商 = 被除数、余り = 0

	if M_STR_EQ([|"${Q_v}"|], [|1|]); then
		Q_q="${Q_u}"
		Q_r=0

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}
	elif
		# 高速パス 3: 被除数 < 除数なら商 = 0、余り = 被除数
		__sx_num_cmp_nat0 "${Q_u}" "${Q_v}" || case "${?}" in
			1) Q_q=0 Q_r="${Q_u}";;
			2) Q_q=1 Q_r=0;;
			*) ! :
		esac
	then
		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}
	else
		# ステップ 4: 末尾ゼロ分解（v = m × 10^k に分解して両者を 10^k で縮小する）
		#   数式: q = (u ÷ 10^k) ÷ m、r = ((u ÷ 10^k) mod m) × 10^k + (u mod 10^k)
		#   商は変化せず、余りには縮小で取り除いた u の下位 k 桁（btail）を最後に復元する。
		#   例: 1234500 ÷ 1200 → m = 12、k = 2、12345 ÷ 12 = 商 1028 余り 9
		#      → 余り = 9 × 100 + 00 = 900（商は縮小の影響を受けない）
		#   適用条件:
		#     kz > WLEN（末尾ゼロが 1 語幅を超える）場合のみ縮小する。
		#     kz は fit_dec によりネイティブ演算の桁数上限に制限される。
		Q_btail=

		case "${Q_v}" in *0${SX_SYS_NUM_ZR})
			Q_zv="${Q_v##*[!0]}"
			Q_tmp="${#Q_zv}"

			if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_tmp}"; then
				__sx_str_qm Q_qm "${Q_tmp}"

				Q_tmp="${Q_u%${Q_qm}}"
				Q_btail="${Q_u#"${Q_tmp}"}"
				Q_v="${Q_v%"${Q_zv}"}"
				Q_u="${Q_tmp}"
			fi
		esac
	fi

	if M_STR_NE([|"${Q_q-}"|], [|''|]); then
		:
	# ステップ 5: 高速パス 4 — 被除数全体がネイティブ除算で確定できる場合
	elif __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_u}"; then
		Q_q=$((Q_u / Q_v))

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}

		Q_r="$((Q_u % Q_v))${Q_btail}"

		# 末尾ゼロ分解で縮小した被除数の下位 k 桁（btail）を余りに復元する
		case "${Q_r}" in 0*)
			Q_r="M_STR_LTRIM([|Q_r|], [|[!0]|])"
		esac
	elif
		# ステップ 6: 高速パス 5 — 除数が (WLEN-1)*9/10 桁以内なら語単位のネイティブ筆算
		#   語幅 c = WLEN - len(v) は約 WLEN/10 + 1 以上に保たれる。c が小さいと反復回数と
		#   商文字列の連結コスト（O(len(q)^2)）が増え、被除数が長い場合は Knuth D 法に
		#   逆転される（実測では c = 2 で ulen ~ 500 付近から逆転）ため安全マージンを確保する。
		__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_v}" &&
		M_NUM_LE([|${#Q_v}|], [|(SX_SYS_NUM_WLEN - 1) * 9 / 10|])
	then
		# v の桁数 s に応じて語幅を c = WLEN - s へ拡大する。
		# 余り r は常に r < v なので、1 反復で取る u の桁を s のぶんだけ増やしても
		# nv = r * 10^c + chunk < 10^WLEN が保たれ、ネイティブ演算に収まる。
		Q_q=
		Q_r=0
		Q_c=$((SX_SYS_NUM_WLEN - ${#Q_v}))

		eval "Q_qm=\"\${SX_NUM_QM_${Q_c}}\" Q_b=\"1\${SX_NUM_ZR_${Q_c}}\""

		# 筆算の1語分: 前語までの余りを基数倍して次の語を結合し、ネイティブ除算で商1語を確定する
		while
			case "${Q_u}" in
				'') break;;
				${Q_qm}?*)
					Q_tmp="${Q_u#${Q_qm}}"
					Q_chunk="${Q_u%"${Q_tmp}"}"
					Q_u="${Q_tmp}"
					;;
				*)
					Q_c="${#Q_u}"
					eval "Q_qm=\"\${SX_NUM_QM_${Q_c}}\" Q_b=\"1\${SX_NUM_ZR_${Q_c}}\""
					Q_chunk="${Q_u}"
					Q_u=
					;;
			esac

			case "${Q_chunk}" in
				0*[1-9]*) Q_chunk=$((1${Q_chunk} - Q_b));;
				0*)
					case "${Q_r}" in 0)
						M_STR_APPEND([|Q_q|], [|"${Q_b#1}"|])
						continue
					esac

					Q_chunk=0
					;;
			esac

			# chunk を nv（r * 10^c + chunk）として再利用する
			M_NUM_INCR([|Q_chunk|], [|Q_r * Q_b|])
			Q_r=$((Q_chunk % Q_v))
				# 商1語がちょうど c 桁ならゼロ埋め・切り出しを省略し、それ以外は c 桁に整形する
			Q_tmp=$((Q_chunk / Q_v))

			case "${Q_tmp}" in
				${Q_qm}) M_STR_APPEND([|Q_q|], [|"${Q_tmp}"|]);;
				*)
					M_NUM_INCR([|Q_tmp|], [|Q_b|])
					M_STR_APPEND([|Q_q|], [|"${Q_tmp#1}"|])
					;;
			esac

			continue
		do :; done

		case "${Q_q}" in 0*)
			Q_q="M_STR_LTRIM([|Q_q|], [|[!0]|])"
		esac

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}

			# 末尾ゼロ分解で縮小した被除数の下位 k 桁（btail）を余りに復元する
			M_STR_APPEND([|Q_r|], [|"${Q_btail}"|])

			case "${Q_r}" in 0*)
				Q_r="M_STR_LTRIM([|Q_r|], [|[!0]|])";;
			esac
	else
		# 語サイズ c の決定
		Q_c=$((SX_SYS_NUM_WLEN / 2))
		eval "Q_qm=\"\${SX_NUM_QM_${Q_c}}\" Q_zr=\"\${SX_NUM_ZR_${Q_c}}\""
		Q_b="1${Q_zr}"
		# ステップ 7: 一般パス — 融合 Knuth D 法（u > v、u は 19 桁以上、v は 2 語以上）
		# ステップ 7.1: 正規化 — u・v を 10^d 倍し、v の先頭語をちょうど c 桁に揃える
		#   d = c - s（s は v の先頭語の桁数、s = (len(v) mod c) の剰余。s がちょうど c なら d = 0）
		#
		#   古典 Knuth D 法の正規化（v1 の値から d = floor(b / (v1 + 1)) を求め、u・v を d 倍して
		#   v1 >= b/2 を保証する方式）とは異なり、ここでは値に依存せず 10^d 倍（末尾へのゼロ付加）
		#   だけで先頭語を c 桁に揃える。保証されるのは v1 >= 10^(c-1) = b/10 であり b/2 には届かない。
		#
		#   正しさの根拠:
		#   - 10^d 倍は文字列連結で実現でき、多倍長乗算を要求しない（u*d、v*d の乗算は
		#     この除数自体を多倍長で扱うことになり、高速除算の利点を失う）。
		#   - D2 の見積りは窓の不変条件 u_{W-n} < v1 より q <= top2/v1 が常に成立し、
		#     過小見積り（qhat < q）は起きない。
		#   - D3 の精緻化テスト（qhat*v2 <= b*rhat + u3）は v1 の大きさに依存せず成立し、
		#     その後は v の最下位 n-2 語の寄与のみが誤差の源泉となる。v1 >= b/10 より
		#     qhat - q < qhat*Lv/v <= b^(n-2)/v <= 1/v1 <= 1 となり（整数性から高々 1）、
		#     D5 加算復帰は実質 1 回で収束する（古典の最悪 2 回と同等以下）。
		#   - D3 が rhat >= b で脱出する場合（先頭語が b/2 より小さいと頻発する）も
		#     qhat*v <= 窓値 が成立し、過大見積り（D5 の反復）は発生しない。
		#   s と n は v の左切り出し（先頭から c 文字ずつ除去して数える）で同時に求まる。
		#   切出しチャンクは語境界に一致する（右剥ぎのチャンクは (c-s) 文字の位相ずれがあり語にならない）。
		#   残余（高々 c 桁）が最下位語 v_n で、先頭語の桁数 s = ${#残余} から
		#   正規化量 d = c - s を確定し、v_n に 0^d を末尾付加して正規化する。
		#   文字列の全長を算術式に入れず、残余は高々 c 桁なので ${#残余} のみ算術に使う。
		#   v_ は分割中に消費される（分割後は使用しない）。
		Q_vstr=
		Q_n=1
		while
			case "${Q_v}" in
				${Q_qm}?*)
					Q_tmp="${Q_v#${Q_qm}}"
					Q_chunk="${Q_v%"${Q_tmp}"}"
					Q_v="${Q_tmp}"
					;;
				*)
					# 残余が 1..c 文字 = 最下位語 v_n。ここで s → d が確定する
					# （残余がちょうど c 文字のときもこの分岐に入り d = 0 になる）。
					# 残余は v_ に残っている（chunk_ は直前の c 文字チャンクのため使用しない）。
					Q_d=$((Q_c - ${#Q_v}))

					case "${Q_d}" in [!0]*)
						eval "Q_tmp=\"\${SX_NUM_ZR_${Q_d}}\" Q_qmd=\"\${SX_NUM_QM_${Q_d}}\""
						M_STR_APPEND([|Q_v|], [|"${Q_tmp}"|])
						M_STR_APPEND([|Q_u|], [|"${Q_tmp}"|])
					esac

					Q_chunk="${Q_v}"
					Q_v=
					;;
			esac

			case "${Q_chunk}" in 0*)
				Q_chunk=$((1${Q_chunk} - Q_b))
			esac

			M_STR_PREPEND([|Q_vstr|], [|"${Q_chunk} \"\${${Q_n}}\" "|])

			case "${Q_n}" in
				1) Q_v1="${Q_chunk}";;
				2) Q_v2="${Q_chunk}";;
			esac

			case "${Q_v:+X}" in '')
				break
			esac

			M_NUM_INCRM1([|Q_n|])

			continue
		do :; done

		# ステップ 7.2 の u 側: u' を K 語に分割する。語は変数ではなく位置パラメータ上で保持する
		# （MS-first: $1 = u_1 = センチネル 0、$2..$# = u_2..u_K の語値。主ループの窓を
		# $1..$(n+1) 固定で扱えるようにした D1 の改良。u_1 は主ループの最初の窓（D2）が
		# 参照するために先頭に確保するゼロ語）。
		# up_（= u_ + 0^d）の右剥ぎチャンクは語境界ちょうどで語になる（正規化ゼロは末尾に付加され、
		# パディング padz は先頭にのみ挿入されるため。v と違い位相ずれが起きない）。
		# 右剥ぎチャンクは下位の語から得られるため、位置パラメータへの前置（set -- "${tail_}" "${@}"）
		# により逆順（MS-first）に整列する。ループ前に位置パラメータを空クリア（set --）してから
		# 蓄積を開始する（関数の元引数が語列の末尾に混入しないようにするため）。
		# 残余（高々 c 桁 = 先頭語 u_2 の元）はそのまま末尾に連結する（正規入力では先頭桁が非ゼロで
		# ありゼロストリップ不要。ゼロストリップは分割済みチャンクに対してのみ行う）。
		#   up_ は分割中に消費される（分割後は使用しない）。
		set --

		while
			case "${Q_u}" in
				'') break;;
				${Q_qm}?*)
					Q_tmp="${Q_u%${Q_qm}}"
					Q_chunk="${Q_u#${Q_tmp}}"
					Q_u="${Q_tmp}"

					case "${Q_chunk}" in 0*)
						Q_chunk=$((1${Q_chunk} - Q_b))
					esac
					;;
				*)
					Q_chunk="${Q_u}"
					Q_u=
					;;
			esac

			set -- "${Q_chunk}" "${@}"

			continue
		do :; done

		set -- 0 "${@}"
		# ステップ 7.3: 主ループ — 位置パラメータを窓として扱い、1 語ずつ左へずらしながら商を 1 語ずつ確定する
		#   窓 = $1..$(n+1) = u_{W-n}..u_W。D2/D3 は窓先頭 2〜3 語を $1..$3 から直接参照する
		#   （eval 不要）。D4（稀に D5）の書き込みは eval を避けて new_ に前置で蓄積し、
		#   反復末尾に shift n+1 → set -- ${new_} "$@" → shift 1（退出語 u_{W-n} を破棄）で
		#   次窓 $1..$(n+1) = u_{W-n+1}..u_{W+1} を確定する。
		#   D4/D5 は下位語（窓の末尾側）から上位語へ走査するため、読み出しのみ eval を使用する。
		Q_q=

		while M_STR_NE([|"${Q_n}"|], [|"${#}"|]); do
			# D2: 商の見積り — 窓の先頭 2 語（$1, $2）を v1 で割って qhat を仮定する
			#   top2 = u_{W-n}*b + u_{W-n+1}、qhat = top2 ÷ v1（b を超えたら b-1 に丸める）
			Q_top2=$((${1} * Q_b + ${2}))
			Q_qhat=$((Q_top2 / Q_v1))

			case "$((Q_b <= Q_qhat))" in
				1)
					Q_qhat=$((Q_b - 1))
					Q_rhat=$((Q_top2 - Q_qhat * Q_v1))
					;;
				*) Q_rhat=$((Q_top2 % Q_v1));;
			esac

			# D3: 精緻化 — qhat×v2 が b×rhat + u_{W-n+2}（= $3）を超える間 qhat を 1 ずつ減らす
			#   （qhat の過大見積りを補正する。rhat が b 未満である限り繰り返す）
			while M_NUM_BOOL([|Q_rhat < Q_b && (Q_b * Q_rhat + ${3-0}) < (Q_qhat * Q_v2)|]); do
				M_NUM_DECR([|Q_qhat|])
				M_NUM_INCR([|Q_rhat|], [|Q_v1|])
			done

			# D4: 融合 multiply-subtract — 窓の語 u_{W-n+1}..u_W（= $2..$(n+1)）から qhat×v を一括減算する
			#   語積 p = qhat×v_j + carry を一度に算出し、下位語から上位語へ繰り上がりを伝搬する
			#   （vstr_ を用いて $1=v_j, $2=u_j ペアを展開し、計算結果は new_ への前置で MS-first に整列する）
			Q_carry=0
			Q_new=
			Q_ut="${1}"
			shift

			eval set -- "${Q_vstr}" - '"${@}"'

			while
				Q_p=$((Q_qhat * ${1} + Q_carry))
				Q_t=$((${2} - Q_p % Q_b))
				Q_carry=$((Q_p / Q_b))

				case "${Q_t}" in -*)
					M_NUM_INCR([|Q_t|], [|Q_b|])
					M_NUM_INCR([|Q_carry|])
				esac

				M_STR_PREPEND([|Q_new|], [|"${Q_t} "|])
				shift 2

				case "${1}" in -)
					shift
					break
				esac

				continue
			do :; done

			M_NUM_DECR([|Q_ut|], [|Q_carry|])
			shift "${Q_n}"
			eval set -- "${Q_new}" '"${@}"'

			# D5: 加算復帰 — D4 の減算結果が負（qhat が過大）だった場合に v を加算して qhat を 1 減らす
			#   （通常 0 回、最大 2 回で収束する。新窓 $1..$n に対して vstr_ で加算し、新窓を置換する）
			while M_NUM_LT([|Q_ut|], [|0|]); do
				Q_ck=0
				Q_new=

				eval set -- "${Q_vstr}" - '"${@}"'

				while
					Q_t=$((${2} + ${1} + Q_ck))
					case "$((Q_b <= Q_t))" in
						1)
							M_NUM_DECR([|Q_t|], [|Q_b|])
							Q_ck=1
							;;
						*) Q_ck=0;;
					esac

					M_STR_PREPEND([|Q_new|], [|"${Q_t} "|])
					shift 2

					case "${1}" in -)
						shift
						break
					esac

					continue
				do :; done

				shift "${Q_n}"
				eval set -- "${Q_new}" '"${@}"'

				M_NUM_DECR([|Q_qhat|])
				M_NUM_INCR([|Q_ut|], [|Q_ck|])
			done

			case "${Q_qhat}" in
				${Q_qm}) M_STR_APPEND([|Q_q|], [|"${Q_qhat}"|]);;
				*)
					# 商に qhat を c 桁ゼロ埋めで連結
					M_STR_PREPEND([|Q_qhat|], [|"${Q_zr}"|])
					M_STR_APPEND([|Q_q|], [|"${Q_qhat#"${Q_qhat%${Q_qm}}"}"|])
					;;
			esac
		done

		case "${Q_q}" in 0*)
			Q_q="M_STR_LTRIM([|Q_q|], [|[!0]|])"
		esac

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}

		# ステップ 7.4: 余り抽出 — 位置パラメータに残る末尾 n 語（u_{K-n+1}..u_K）を c 桁ゼロ埋めで連結する
		#   （主ループが各反復で 1 語ずつ破棄したため、ループ終了後の $@ がちょうど余りの n 語になる）
		Q_r=
		for Q_uw in "${@}"; do
			case "${Q_uw}" in
				${Q_qm}) M_STR_APPEND([|Q_r|], [|"${Q_uw}"|]);;
				*)
					M_STR_PREPEND([|Q_uw|], [|"${Q_zr}"|])
					M_STR_APPEND([|Q_r|], [|"${Q_uw#"${Q_uw%${Q_qm}}"}"|])
					;;
			esac
		done

		# ステップ 7.5: 逆正規化 — 余りの末尾 d 桁を除去して 10^d 倍を戻す（商は影響を受けない）
		case "${Q_d}" in [!0]*)
			Q_r="${Q_r%${Q_qmd}}"
		esac

		M_STR_APPEND([|Q_r|], [|"${Q_btail}"|])

		case "${Q_r}" in 0*)
			Q_r="M_STR_LTRIM([|Q_r|], [|[!0]|])";;
		esac
	fi

	__sx_var_ubind Q_bind "${Q_bind}" "${Q_r:-0}" || :

	unset CLEANUP
}
|], [|num_divmod_nat0|])dnl
popdef([|CLEANUP|])dnl
