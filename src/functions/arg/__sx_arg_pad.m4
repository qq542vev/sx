dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_ARG_PAD_CB SX_CFG_SEP __sx_arg_pad_cb __sx_arg_pad_lit __sx_var_bind_init|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_arg_pad - 引数リストをパディングスキーマで整形する（内部用）
##
## 使い方:
##   __sx_arg_pad bind [len [val [flg]]] ::: [arg ...]
##   __sx_arg_pad bind [len [arg ...]]
##
## 説明:
##   sx_arg_pad の内部実装。
##   引数チェックは行わない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   非0  コールバックの終了ステータス

define([|CLEANUP|], [|Q_bind Q_len Q_val Q_flg|])dnl

__sx_arg_pad() {
	Q_bind="${1}"

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}") shift 2;;
		"${3+X${3}}")
			Q_len="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_len="${2}" Q_val="${3}"
			shift 4
			;;
		"${5+X${5}}")
			Q_len="${2}" Q_val="${3}" Q_flg="${4}"
			shift 5
			;;
		*)
			Q_len="${2-}"
			shift ${2+'2'}
			;;
	esac

	set -- "${Q_bind-}" "${Q_len:-0}" "${Q_val-}" "${Q_flg:-0}" "${@}"
	unset CLEANUP

	__sx_var_bind_init "${1}"

	case "${1:+X}" in '')
		return
	esac

	case "$((${4} & SX_ARG_PAD_CB))" in
		0) __sx_arg_pad_lit "${@}";;
		*) __sx_arg_pad_cb "${@}";;
	esac || return
}
|], [|arg_pad|])dnl
popdef([|CLEANUP|])dnl
