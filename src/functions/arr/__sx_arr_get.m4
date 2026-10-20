dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_NUM_RANGE __sx_arr_bind __sx_arr_bind_commit __sx_arr_to_int __sx_num_add_nat0 __sx_num_cmp_nat0 __sx_num_divmod_nat0 __sx_num_is_int_fit_dec __sx_num_sub1_nat0 __sx_num_sub_int __sx_num_sub_nat0 __sx_var_to_ebind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_get - 配列から指定要素を順序保持で切り出す（内部用）
##
## 使い方:
##   __sx_arr_get bind 配列名 [spec ...]
##
## 説明:
##   sx_arr_get の本体実装（要素ストリーム構築・一括書き込み・コミット）。
##   引数チェック（bind 形式・変数名・配列判定・書き込み権限・spec 形式）は行わない。
##   spec の順に単体・範囲を解決し、__sx_arr_bind で chain を構築した後、
##   __sx_arr_bind_commit で確定する。正確な等差数列と定義域 [0, len) の交叉を
##   列挙する（初項計算＋定義域有界ループ）。空結果でも成功する。
##
## 処理構成:
##   1. 分配 bind を ebind へ変換し、源配列の要素数を控える。
##   2. 源配列が空なら全 spec を捨て、空配列の確定に一本化する。
##   3. 各 spec をコロンの有無で 2 つに大別する。
##      単体指定 : 符号付き整数 1 個。len 基準で換算し定義域内なら 1 要素を積む。
##      範囲指定 : s:e[:t] の等差数列。終点にコロンが無ければ刻みは 1 とみなす。
##   4. 範囲指定は刻みの符号で増加方向と減少方向に分かれ、それぞれ
##      高速経路（$(( )) 演算で算術域に収まる場合）と
##      低速経路（多倍長演算 API）に分岐する。
##   5. 各経路は (a) 始点を定義域へクランプ (b) 終点上限の算出 (c) 空判定 (d) 終端調整、の順で
##      閉区間（始点から終点まで刻み間隔）を求め、その区間を __sx_arr_bind で積み上げる。
##   6. 全 spec の処理後、__sx_arr_bind_commit でチェーンをまとめて 1 度に確定する。

define([|CLEANUP|], [|Q_bind Q_borg Q_chain Q_arr Q_len Q_spec Q_s Q_e Q_t Q_c Q_tmp|])dnl

__sx_arr_get() {
	# 分配 bind を ebind（要素名を分解して名前へ書き戻せる形式）へ変換する。
	# commit は元の bind 名を要するので控えておく。
	__sx_var_to_ebind Q_bind "${1}"
	Q_borg="${Q_bind}"
	# 要素の蓄積先（bind チェーン）。まだ空なので空文字で初期化する。
	Q_chain=
	# 源配列名と、その要素数（配列長変数）を控えてから spec だけを残す。
	Q_arr="${2}"
	eval "Q_len=\"\${${2}_len}\""
	shift 2

	# 源配列が空ならどの spec も 1 要素も作れない。
	# spec を全て捨てて空チェーンの確定に一本化する（定義域の判定が不要になる）。
	case "${Q_len}" in 0)
		set --
	esac

	# spec を順に処理する。各 spec は独立で、蓄積は spec 順に連結される。
	for Q_spec in "${@}"; do
		case "${Q_spec}" in
			*:*)
				# 範囲指定: コロンを含むので終点以降を切り出して解析する。
				Q_e="${Q_spec#*:}"

				# 終点にもコロンがあれば刻み指定（s:e:t）、無ければ刻みは 1（s:e）。
				case "${Q_e}" in
					*:*) Q_t="${Q_e#*:}" Q_e="${Q_e%:*}";;
					*) Q_t=1;;
				esac

				# 始点: 省略（先頭がコロン）なら減少方向は末尾から、増加方向は先頭から。
				# 明示された場合は負値を len 基準で換算する。丸めはしないので負値・len 超過が残り得る。
				case "${Q_spec%%:*}:${Q_t}" in
					:-*) __sx_num_sub1_nat0 Q_s "${Q_len}";;
					:*) Q_s=0;;
					*) __sx_arr_to_int Q_s "${Q_spec%%:*}" "${Q_len}";;
				esac

				# 終点: 省略（末尾がコロン）なら減少方向は 0 まで、増加方向は len まで。
				# 明示された場合は始点と同じく len 基準で換算する。
				case "${Q_e}:${Q_t}" in
					:-*) Q_e=0;;
					:*) Q_e="${Q_len}";;
					*) __sx_arr_to_int Q_e "${Q_e}" "${Q_len}";;
				esac

				# 刻みの符号で方向を決める。負なら減少方向（t<0）として扱う。
				case "${Q_t}" in
					-*)
						# 始点が負（定義域より手前）なら空。
						case "${Q_s}" in -*)
							continue
						esac

						# 終点が負なら 0（先頭）へクランプする。
						# 減少方向では終点まで取り出す（逆半開区間）ため、上限は 0 になる。
						case "${Q_e}" in -*)
							Q_e=0
						esac

						# 絶対刻みを求める。以後は絶対刻みで統一する。
						# 文字列除去のため MIN でも算術溢れしない。
						Q_t="${Q_t#-}"

					# 高速経路は「始点・終点・刻みの 3 値がすべて算術域に収まる」場合だけ使える。
					# MIN の絶対値は算術域外のため fit 不適合で低速へ回る。
					if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_s}" "${Q_e}" "${Q_t}"; then
						# 始点が len-1 より大きい（定義域より手前）なら、定義域内で
						# 始点と等しい剰余を持つ最大の値へ引き戻す。
						# 差分・剰余・加算はいずれも算術域内に収まる。
						case "$((Q_len <= Q_s))" in 1)
							Q_s=$((Q_len - Q_t + ((Q_s - Q_len) % Q_t)))
						esac

						# 始点が終点より小さい（終端を先に過ぎる）なら区間は空。
						# s==e は単要素で残す。前段で負始点・負終点は解消済みで、引き戻し後の負化もここで空になる。
						case "$((Q_s < Q_e))" in 1)
							continue
						esac
						# 終端 = 始点以下・終点以上で、始点と等しい剰余を持つ最小の値。
						# 0 <= 終点 <= 始点なので差分は算術域内に収まり、加算結果も始点以下になる。
						Q_e=$((Q_e + ((Q_s - Q_e) % Q_t)))

						# 始点から終端まで刻み刻みに積む。終端に到達したら停止。
						# bind が枯渇（1）したらこの while と外側の for を同時に抜ける。
						while
							__sx_arr_bind Q_bind Q_chain "${Q_bind}" "${Q_arr}_${Q_s}" || break 2

							case "${Q_s}" in "${Q_e}")
								break
							esac

							Q_s=$((Q_s - Q_t))
							continue
						do :; done
					else
						# 低速経路: 算術域に収まらないため多倍長演算 API で同じ結果を出す。
						# 始点が定義域を超える（len 以上）なら、定義域内で始点と等しい剰余を
						# 持つ最大の値へ引き戻す。剰余は「始点と len-1 の距離」から求め、
						# 余り 0 ならそのまま len-1、そうでなければ len-1 から
						# 「絶対刻み − 余り」だけ戻す。
						__sx_num_cmp_nat0 "${Q_s}" "${Q_len}" || case "${?}" in [23])
							__sx_num_sub1_nat0 Q_c "${Q_len}"
							__sx_num_sub_nat0 Q_tmp "${Q_s}" "${Q_c}"
							__sx_num_divmod_nat0 :Q_tmp: "${Q_tmp}" "${Q_t}"

							case "${Q_tmp}" in
								0) Q_s="${Q_c}";;
								*)
									__sx_num_sub_nat0 Q_tmp "${Q_t}" "${Q_tmp}"
									__sx_num_sub_int Q_s "${Q_c}" "${Q_tmp}"
									;;
							esac
						esac

						# 引き戻しで負に振れた（定義域より手前）なら空。
						# 負値を cmp_nat0 に渡さないための guard。
						case "${Q_s}" in -*) continue;; esac

						__sx_num_cmp_nat0 "${Q_s}" "${Q_e}" || case "${?}" in 1)
							continue
						esac

						# 終端 = 始点以下・終点以上で、始点と等しい剰余を持つ最小の値。
						# 前段で終点の負は 0 に寄せ済みのため直接差分で求める。
						__sx_num_sub_nat0 Q_tmp "${Q_s}" "${Q_e}"
						__sx_num_divmod_nat0 :Q_tmp: "${Q_tmp}" "${Q_t}"
						__sx_num_add_nat0 Q_e "${Q_e}" "${Q_tmp}"

						# 始点から終端まで刻み刻みに積む。終端に到達したら停止。
						while
							__sx_arr_bind Q_bind Q_chain "${Q_bind}" "${Q_arr}_${Q_s}" || break 2

							case "${Q_s}" in "${Q_e}")
								break
							esac

							__sx_num_sub_nat0 Q_s "${Q_s}" "${Q_t}"
							continue
						do :; done
					fi
					;;
				*)
					# 増加方向では終点を含まない（exclusive）ため、終点が 0（-0 も含む）なら区間が空。
					# 要素を取り出すものは無いので次の spec へ進む。
					case "${Q_e}" in [-0]*)
						continue
					esac

					# 増加方向（t>0）。3 値が算術域に収まる場合だけ高速経路を使う。
					if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_s}" "${Q_e}" "${Q_t}"; then
						# 始点が負なら、0 以上で始点と等しい剰余を持つ最小の値へ引き戻す。
						# クランプは始点の絶対値が MIN で反転できないよう、先に 1 を足してから
						# 負剰余を加算する（中間溢れ防止）。
						case "${Q_s}" in -*)
							Q_s=$((Q_t - 1 + ((Q_s + 1) % Q_t)))
						esac

						# 終点の上限を min(終点, len)-1（取り出せる上限）へ丸める。
						Q_e=$(((Q_e < Q_len ? Q_e : Q_len) - 1))

						# 始点が上限より大きい（終端を先に越える、もしくは定義域外）なら区間は空。
						case "$((Q_e < Q_s))" in 1)
							continue
						esac

						# 上限から刻みで割り切れる最大値（終端）まで戻す。
						Q_e=$((Q_e - ((Q_e - Q_s) % Q_t)))

						# 始点から終端まで刻み刻みに積む。終端に到達したら停止。
						while
							__sx_arr_bind Q_bind Q_chain "${Q_bind}" "${Q_arr}_${Q_s}" || break 2

							case "${Q_s}" in "${Q_e}")
								break
							esac

							Q_s=$((Q_s + Q_t))
							continue
						do :; done
					else
						# 低速経路: 始点が負なら、0 以上で始点と等しい剰余を持つ最小の値へ引き戻す。
						# 絶対値の剰余から逆算するので、始点の絶対値が MIN でも反転しない。
						Q_t="${Q_t#+}"
						case "${Q_s}" in -*)
							__sx_num_divmod_nat0 :Q_tmp: "${Q_s#-}" "${Q_t}"

							case "${Q_tmp}" in
								0) Q_s=0;;
								*) __sx_num_sub_nat0 Q_s "${Q_t}" "${Q_tmp}";;
							esac
						esac

						# 終点の上限を min(終点, len)-1（取り出せる上限）へ丸める。
						__sx_num_cmp_nat0 "${Q_e}" "${Q_len}" || case "${?}" in
							1) __sx_num_sub1_nat0 Q_e "${Q_e}";;
							*) __sx_num_sub1_nat0 Q_e "${Q_len}";;
						esac

						# 始点が上限より大きい（終端を先に越える、もしくは定義域外）なら区間は空。
						__sx_num_cmp_nat0 "${Q_s}" "${Q_e}" || case "${?}" in 3)
							continue
						esac

						# 上限から刻みで割り切れる最大値（終端）まで戻す。
						__sx_num_sub_nat0 Q_tmp "${Q_e}" "${Q_s}"
						__sx_num_divmod_nat0 :Q_tmp: "${Q_tmp}" "${Q_t}"
						__sx_num_sub_nat0 Q_e "${Q_e}" "${Q_tmp}"

						# 始点から終端まで刻み刻みに積む。終端に到達したら停止。
						while
							__sx_arr_bind Q_bind Q_chain "${Q_bind}" "${Q_arr}_${Q_s}" || break 2

							case "${Q_s}" in "${Q_e}")
								break
							esac

							__sx_num_add_nat0 Q_s "${Q_s}" "${Q_t}"
							continue
						do :; done
					fi
					;;
				esac
				;;
			*)
				# 単体指定: 絶対値が len 未満、または絶対値が len ちょうどで符号が負
				# （len 基準の換算で 0 に落ちる）なら 1 要素として積む。
				# 絶対値が len 以上の非負値は定義域外なので取り出さない。
				__sx_num_cmp_nat0 "${Q_spec#[+-]}" "${Q_len}" || case "${?}${Q_spec}" in 1* | 2-*)
					__sx_arr_to_int Q_s "${Q_spec}" "${Q_len}"

					__sx_arr_bind Q_bind Q_chain "${Q_bind}" "${Q_arr}_${Q_s}" || break;;
				esac
				;;
		esac
	done

	# 全 spec の処理で積んだチェーンを、元の bind 名へまとめて確定する。
	eval __sx_arr_bind_commit '"${Q_borg}"' '"${Q_bind}"' "${Q_chain}"

	unset CLEANUP
}
|], [|arr_get|])dnl
popdef([|CLEANUP|])dnl
