dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_CFG_ARR_UPDATE SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_SYS_NUM_MAX SX_SYS_NUM_MIN SX_SYS_NUM_QM SX_SYS_NUM_WLEN SX_SYS_NUM_ZR __sx_cfg_set sx_cfg_is_valid sx_var_is_rw|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_cfg_set - SX_CFG_* を設定する
##
## 使い方:
##   sx_cfg_set [名前[=値] ...]
##
## 説明:
##   sx_cfg_is_valid を用いて全引数を検査し、すべて合格した場合のみ値を設定する。
##   '名前' のみが指定された場合は、その項目をデフォルト値にリセットする。
##   引数がない場合は、全設定項目を SX_CFG_META_DEF_* の値にリセットする。
##   NUM_RANGE に対応する派生値も更新するが、SX_SYS_REV と既存の配列データは変更しない。
##   署名が変わると、変更前の署名で作成した配列は認識されなくなる。
##   検査を省略しない場合は、派生値を含む全変更対象の書込可否を変更前に確認する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  無効な設定項目、または不適切な値が含まれる (SX_EX_USAGE)
##   77  設定項目が読み取り専用 (SX_EX_NOPERM)

define([|CLEANUP|], [|Q_arg Q_chk|])dnl

sx_cfg_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_cfg_set "${@}" || return; return 0;; esac

	case "${#}" in 0)
		set -- M_CFG_META_NAMES
	esac

	sx_cfg_is_valid "${@}" || return M_EX_USAGE

	Q_chk=

	for Q_arg in "${@}"; do
		M_STR_APPEND([|Q_chk|], [|" SX_CFG_${Q_arg%%=*}"|])

		case "${Q_arg}" in
			NUM_RANGE | NUM_RANGE=*)
				M_STR_APPEND([|Q_chk|], [|" SX_SYS_NUM_WLEN SX_SYS_NUM_QM SX_SYS_NUM_ZR SX_SYS_NUM_MAX SX_SYS_NUM_MIN"|])
				;;
		esac
	done

	eval sx_var_is_rw "${Q_chk}" || {
		unset CLEANUP
		return M_EX_NOPERM
	}

	unset CLEANUP
	__sx_cfg_set "${@}"
}
|], [|cfg_set|])dnl
popdef([|CLEANUP|])dnl
