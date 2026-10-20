dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|__sx_arr_bind __sx_arr_bind_commit __sx_num_sub1_nat0 __sx_var_to_ebind __sx_var_unset|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_pop_raw - 元配列のリビジョンを更新せず末尾から取り出す（内部用）
##
## 使い方:
##   __sx_arr_pop_raw bind 配列名
##
## 説明:
##   内部実装。引数チェックは行わない。
##   取り出し（chain 構築）とコミットを行い、元配列の要素と長さだけを変更する。
##   分配先に新しく作る配列のリビジョンは通常どおり発行する。
##   合計スロット数が要素数を超える場合は 1 を返し、何も書き込まない。
##
## 終了ステータス:
##    0  成功
##    1  要素不足（無変更）

define([|CLEANUP|], [|Q_bind Q_borg Q_chain Q_unset Q_len Q_tmp|])dnl

__sx_arr_pop_raw() {
	__sx_var_to_ebind Q_bind "${1}"
	Q_borg="${Q_bind}"
	Q_chain=
	Q_unset=
	eval "Q_len=\"\${${2}_len}\""

	# 1) 要素ストリームを末尾から1つずつ __sx_arr_bind で処理し、chain を構築する（読み取りのみ）
	while M_STR_NE([|0|], [|"${Q_len}"|]); do
		__sx_num_sub1_nat0 Q_tmp "${Q_len}"
		__sx_arr_bind Q_bind Q_chain "${Q_bind}" "${2}_${Q_tmp}" || break

		Q_len="${Q_tmp}"

		M_STR_APPEND([|Q_unset|], [|" ${2}_${Q_len}"|])
	done

	# 2) 要素不足: 全要素を消費しても bind に残スロットがある → 無変更で失敗
	case "${Q_len}:${Q_bind}" in 0:?*)
		unset CLEANUP
		return 1
	esac

	# 3) chain 適用（一括書き込み）
	eval __sx_arr_bind_commit '"${Q_borg}"' '"${Q_bind}"' "${Q_chain}"

	eval __sx_var_unset "${Q_unset}"
	eval "${2}_len=${Q_len}"

	unset CLEANUP
}
|], [|arr_pop_raw|])dnl
popdef([|CLEANUP|])dnl
