M_REQUIRE([|SX_STR_ALNUM __sx_var_bind_init __sx_var_ubind|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_uri_enc - バイト列をパーセントエンコードする（内部用）
##
## 使い方:
##   __sx_uri_enc バインド形式 [入力文字列 ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   C (POSIX) ロケールで、保持区間を一括コピーし変換対象区間だけを走査する。
##   バイトと %HH の対応はビルド時に生成し、実行時の数値変換は行わない。
##   バインド先を初期化し、各入力を変換してから __sx_var_ubind で分配する。
##   バインド先が枯渇したら残りの入力の変換を打ち切る。
##
## 終了ステータス:
##    0  成功（バインド枯渇による早期終了を含む）
define([|CLEANUP|], [|Q_bind Q_rest Q_out Q_safe Q_chunk|])dnl

__sx_uri_enc() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}" Q_safe="${SX_STR_ALNUM}-._~"
	shift

	for Q_rest in "${@}"; do
		case "${Q_bind}" in '')
			break
		esac

		Q_out=

		while M_STR_NE([|"${Q_rest}"|], [|''|]); do
			# 最初の非予約文字より前にある変換対象区間を切り出す。
			Q_chunk="${Q_rest%%["${Q_safe}"]*}"
			Q_rest="${Q_rest#"${Q_chunk}"}"

			while M_STR_NE([|"${Q_chunk}"|], [|''|]); do
				case "${Q_chunk%"${Q_chunk#?}"}" in
__sx_m4_gen_uri_enc_case(1)
				esac

				Q_chunk="${Q_chunk#?}"
			done

			# 後続の非予約文字は一文字ずつ調べず、まとめて結果へ追加する。
			Q_chunk="${Q_rest%%[!"${Q_safe}"]*}"
			M_STR_APPEND([|Q_out|], [|"${Q_chunk}"|])
			Q_rest="${Q_rest#"${Q_chunk}"}"
		done

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_out}"
	done

	unset CLEANUP
}
|], [|uri_enc|])dnl
popdef([|CLEANUP|])dnl
