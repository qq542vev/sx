dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_SEP SX_CFG_SKIP_CHK __sx_ex_remap sx_ex_is_status sx_ex_is_valid|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_ex_remap - 終了ステータスをマッピングしてコマンドを実行する
##
## 使い方:
##   sx_ex_remap [置換元:置換先 ...] [:::] コマンド [引数 ...]
##
## 説明:
##   コマンドを実行し、その終了ステータスをマッピングに従って変換する。
##   マッピングは '置換元:置換先' の形式で指定し、最初に見つかった一致項目が適用される。
##   置換元の形式:
##     N      : 特定のステータスに一致 (例: 1:64)
##     N-M    : N 以上 M 以下の範囲に一致 (例: 1-125:1)
##     N-     : N 以上のすべてのステータスに一致 (例: 126-:2)
##     -M     : M 以下のすべてのステータスに一致 (例: -125:1)
##     !N     : N 以外のすべてのステータスに一致 (例: !0:1)
##     -      : デフォルト。他のどの条件にも一致しない場合に適用される (例: -:99)
##   マッピングに一致しない場合は、元の終了ステータスが維持される。
##
## 終了ステータス:
##   実行したコマンドの（マッピング後の）終了ステータスを返す。
##   コマンドが指定されていない場合は 0 (SX_EX_OK) を返す。
##   マッピングの引数形式またはステータス値が不正な場合は SX_EX_USAGE (64) を返す。

define([|CLEANUP|], [|Q_arg Q_src|])dnl

sx_ex_remap() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_ex_remap "${@}" || return; return 0;; esac

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${SX_CFG_SEP}") break;;
			*:*) ;;
			*) break;;
		esac

		Q_src="${Q_arg%%:*}"

		case "${Q_src}" in
			-) ;;
			*?-) sx_ex_is_status "${Q_src%-}";;
			-?*) sx_ex_is_status "${Q_src#-}";;
			*-*) sx_ex_is_status "${Q_src#*-}" "${Q_src%%-*}";;
			*) sx_ex_is_valid "${Q_src#!}";;
		esac && sx_ex_is_valid "${Q_arg#*:}" || {
			unset CLEANUP
			return M_EX_USAGE
		}
	done

	unset CLEANUP

	__sx_ex_remap "${@}" || return
}
|], [|ex_remap|])dnl
popdef([|CLEANUP|])dnl
