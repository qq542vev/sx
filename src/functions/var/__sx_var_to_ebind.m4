dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_num_add_nat0|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_var_to_ebind - bind形式を拡張bind形式に変換する（内部用）
##
## 使い方:
##   __sx_var_to_ebind 結果変数名 bind形式
##
## 説明:
##   sx_var_to_ebind の内部実装。
##   内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_bind Q_out Q_mark Q_seg Q_n Q_vn Q_prior Q_e|])dnl

__sx_var_to_ebind() {
	# 残り入力・出力バッファ・動的合算値の後始末リストを初期化する。
	# 動的合算値は変数ごとに作る（初出0、2回目以降は前回までの合計）。
	Q_res="${1}"
	Q_bind="${2-}"
	Q_out=
	Q_mark=

	# bindを先頭から1セグメントずつ切り出してebind片へ直す。
	# コロンの数を保存するため、空セグメントも1件として扱う。
	while
		# セグメント分割: コロンが残っていれば中間、なければ末尾。
		Q_seg="${Q_bind%%:*}"

		# セグメント別の変換則:
		#   空     -> 空のまま（1件スキップ）
		#   N      -> 0/N（N件スキップ）
		#   Nvn    -> Prior/Total+vn（同名は合算、初回は 0/N+vn）
		#   N@vn   -> Prior/Total@vn（配列版の合算）
		#   @vn    -> Prior/@vn（末尾の配列rest）
		#   素vn   -> 中間はそのまま、末尾は Prior/vn のrest化
		case "${Q_seg}" in
			'') Q_e=;;
			[1-9]*)
				# 先頭数字を個数、その残りを宛先に分ける。
				Q_n="${Q_seg%%[!0-9]*}"
				Q_vn="${Q_seg#"${Q_n}"}"

				case "${Q_vn}" in
					# 素の数値は型なしスキップなので合算不要。
					'') Q_e="0/${Q_n}";;
					@*)
						# 配列の制限付き取り分。同じ配列名の合計を積み上げる。
						Q_vn="${Q_vn#@}"
						eval "Q_prior=\"\${Q_s${Q_vn}_-0}\""
						__sx_num_add_nat0 "Q_s${Q_vn}_" "${Q_prior}" "${Q_n}"
						eval "Q_e=\"\${Q_prior}/\${Q_s${Q_vn}_}@\${Q_vn}\""
						M_STR_APPEND([|Q_mark|], [|"Q_s${Q_vn}_ "|])
						;;
					*)
						# 通常変数の制限付き取り分。例: 3a,2a -> 0/3a,3/5a。
						eval "Q_prior=\"\${Q_s${Q_vn}_-0}\""
						__sx_num_add_nat0 "Q_s${Q_vn}_" "${Q_prior}" "${Q_n}"
						eval "Q_e=\"\${Q_prior}/\${Q_s${Q_vn}_}\${Q_vn}\""
						M_STR_APPEND([|Q_mark|], [|"Q_s${Q_vn}_ "|])
						;;
				esac
				;;
			# 末尾の配列rest。ここまでの同名合計を分子に載せる。
			@*) eval "Q_e=\"\${Q_s${Q_seg#@}_-0}/${Q_seg}\"";;
			*)
				case "${Q_bind}" in
					# 中間の素変数は1件代入なので書き換えない。
					*:*) Q_e="${Q_seg}";;
					# 末尾の素変数は残り全部のrestなので M/vn 化する。
					*) eval "Q_e=\"\${Q_s${Q_seg}_-0}/\${Q_seg}\"";;
				esac
				;;
		esac

		# 変換片をコロン区切りで積む。末尾に毎回 : を付けておく。
		M_STR_APPEND([|Q_out|], [|"${Q_e}:"|])

		case "${Q_bind}" in *:*)
			Q_bind="${Q_bind#*:}"
			continue
		esac

		break
	do :; done

	# 積み上げ時に付けた余分な末尾 : を1つ落として確定させる。
	M_VAR_SET([|${Q_res}|], [|${Q_out%:}|])

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_to_ebind|])dnl
popdef([|CLEANUP|])dnl
