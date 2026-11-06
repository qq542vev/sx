M_REQUIRE([|SX_CFG_SEP SX_EX_CANTCREAT SX_EX_CONFIG SX_EX_DATAERR SX_EX_IOERR SX_EX_NOHOST SX_EX_NOINPUT SX_EX_NOPERM SX_EX_NOUSER SX_EX_OK SX_EX_OSERR SX_EX_OSFILE SX_EX_PROTOCOL SX_EX_SOFTWARE SX_EX_TEMPFAIL SX_EX_UNAVAILABLE SX_EX_USAGE|])dnl
M_DYNAMIC_CONSTS([|SX_EX_|], [|CANTCREAT CONFIG DATAERR IOERR NOHOST NOINPUT NOPERM NOUSER OK OSERR OSFILE PROTOCOL SOFTWARE TEMPFAIL UNAVAILABLE USAGE|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_ex_remap - 終了ステータスのマッピングとコマンド実行を行う（内部用）
##
## 使い方:
##   __sx_ex_remap [置換元:置換先 ...] [:::] コマンド [引数 ...]
##
## 説明:
##   sx_ex_remap の内部実装。
##   引数のバリデーションは行わず、マッピングのパース、コマンドの実行、
##   および終了ステータスの変換を順次行う。

define([|CLEANUP|], [|Q_sts Q_map Q_arg Q_tmp|])dnl

__sx_ex_remap() {
	Q_map=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${SX_CFG_SEP}") shift; break;;
			*:*)
				M_STR_APPEND([|Q_map|], [|" '${Q_arg}'"|])
				shift
				;;
			*) break;;
		esac
	done

	eval "unset CLEANUP; \"\${@}\" && Q_sts=0 || Q_sts=\"\${?}\"; set -- ${Q_map}"

	for Q_map in "${@}"; do
		set -- "${Q_map%%:*}" "${Q_map#*:}"

		case "${1}" in
			"${Q_sts}") Q_sts="${2}"; break;;
			*-*)
				set -- "${@}" "${1%%-*}" "${1#*-}"

				case "$((${3:-0} <= Q_sts && Q_sts <= ${4:-255}))" in 1)
					Q_sts="${2}"; break
				esac
				;;
			![!0-9]*) eval set -- "\"\${SX_EX_${1#!}}\"" '"${2}"';&
			!*)
				if M_STR_NE([|"${1#!}"|], [|"${Q_sts}"|]); then
					Q_sts="${2}"; break
				fi
				;;
			[!0-9]*)
				eval "Q_tmp=\${SX_EX_${1}}"

				case "${Q_tmp}" in "${Q_sts}")
					Q_sts="${2}"; break
				esac
				;;
		esac
	done

	case "${Q_sts}" in
		[!0-9]*) eval set -- "\${SX_EX_${Q_sts}}";;
		*) set -- "${Q_sts}";;
	esac

	unset CLEANUP
	return "${1}"
}
|], [|ex_remap|])dnl
popdef([|CLEANUP|])dnl
