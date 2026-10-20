dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_STR_SWORD __sx_arr_gen __sx_var_copy __sx_var_is_set|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arr_bind_commit - 一括書き込みと bind 比較（コミット）を実行する（内部用）
##
## 使い方:
##   __sx_arr_bind_commit bind_org bind_left [chain ...]
##
## 説明:
##   sx_arr_cat / sx_arr_pop から共用される統合書き込み処理。bind_org・bind_left は
##   ともに拡張バインド形式（__sx_var_to_ebind の出力）であること。まず chain（連鎖式の
##   スペース区切りリスト）を __sx_var_copy で一括適用して書き込みを確定し、
##   続いて bind_org（元のバインド形式。先頭の ':' は関数内で付加）と要素消費後の
##   残りバインド bind_left を末尾セグメントから順に取り出して比較する。
##   配列セグメント（M/Nvn・M/vn）は __sx_arr_gen で確定して _len を実割当数に設定する。
##   実割当数は fseg の進行度（cnt/...）から求め、同名セグメント（合算）が複数ある
##   場合は先頭側の値で上書きし、剥離済み（fseg 空）は未記録のときに限り N を用いる。
##   既視管理は Q_v マークで行う。割当の無いスカラーセグメントは unset する。
##   M/N・M/・空セグメントはスキップする。
##   bind は値渡しのため、呼び出し側の変数は変更されない。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_borg Q_bind Q_mark Q_oseg Q_fseg Q_frac Q_vn|])dnl

__sx_arr_bind_commit() {
	Q_borg=":${1}"
	Q_bind="${2}"
	Q_mark=

	shift 2
	__sx_var_copy "${@}"

	while M_STR_HAS([|"${Q_borg}"|], [|:|]); do
		# bind_org の末尾セグメントを pop
		Q_oseg="${Q_borg##*:}"
		Q_borg="${Q_borg%:*}"

		case "${Q_bind}" in
			*:*)
				Q_fseg="${Q_bind##*:}"
				Q_bind="${Q_bind%:*}"
				;;
			*)
				Q_fseg="${Q_bind}"
				Q_bind=
				;;
		esac

		case "${Q_oseg}" in
			*/*["${SX_STR_SWORD}"]*)
				Q_frac="${Q_oseg%%[!/0-9]*}"
				Q_vn="${Q_oseg#"${Q_frac}"}"

				case "${Q_fseg:+X}" in
					'')
						if ! __sx_var_is_set "Q_v${Q_vn}_"; then
							__sx_arr_gen "${Q_vn}"
							M_VAR_SET([|${Q_vn}_len|], [|${Q_frac#*/}|], [|Q_v${Q_vn}_|], [|1|])
							M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])
						fi
						;;
					*)
						__sx_arr_gen "${Q_vn}"
						M_VAR_SET([|${Q_vn}_len|], [|${Q_fseg%%/*}|], [|Q_v${Q_vn}_|], [|1|])
						M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])
						;;
				esac
				;;
			["${SX_STR_SWORD}"]*)
				case "${Q_fseg:+X}" in X)
					unset "${Q_oseg}"
				esac
				;;
		esac
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|arr_bind_commit|])dnl
popdef([|CLEANUP|])dnl
