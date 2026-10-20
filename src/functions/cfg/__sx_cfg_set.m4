dnl 本体は sx.m4 から生成。依存宣言はこのファイルで管理する。
M_REQUIRE([|SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_CFG_ARR_UPDATE SX_CFG_META_DEF_ARR_HOLE SX_CFG_META_DEF_ARR_REF SX_CFG_META_DEF_ARR_UPDATE SX_CFG_META_DEF_NUM_RANGE SX_CFG_META_DEF_SEP SX_CFG_META_DEF_SIG_ARR SX_CFG_META_DEF_SKIP_CHK SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SIG_ARR SX_CFG_SKIP_CHK SX_NUM_I128_MAX SX_NUM_I128_MIN SX_NUM_I128_QM SX_NUM_I128_WLEN SX_NUM_I128_ZR SX_NUM_I32_MAX SX_NUM_I32_MIN SX_NUM_I32_QM SX_NUM_I32_WLEN SX_NUM_I32_ZR SX_NUM_I64_MAX SX_NUM_I64_MIN SX_NUM_I64_QM SX_NUM_I64_WLEN SX_NUM_I64_ZR SX_SYS_NUM_MAX SX_SYS_NUM_MIN SX_SYS_NUM_QM SX_SYS_NUM_WLEN SX_SYS_NUM_ZR|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_cfg_set - SX_CFG_* の値を実際に設定する（内部用）
##
## 使い方:
##   __sx_cfg_set [名前[=値] ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   '名前' のみが指定された場合は、対応する SX_CFG_META_DEF_* の値でリセットする。
##   引数がない場合は、全設定項目を SX_CFG_META_DEF_* の値にリセットする。
##   NUM_RANGE の派生値も更新する。SX_SYS_REV と既存の配列データは変更しない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)

define([|CLEANUP|], [|Q_arg|])dnl

__sx_cfg_set() {
	case "${#}" in 0)
		set -- M_CFG_META_NAMES
	esac

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) eval "SX_CFG_${Q_arg%%=*}=\"\${Q_arg#*=}\"";;
			*) eval "SX_CFG_${Q_arg}=\"\${SX_CFG_META_DEF_${Q_arg}}\"";;
		esac

		case "${Q_arg}" in NUM_RANGE | NUM_RANGE=*)
			eval SX_SYS_NUM_WLEN="\${SX_NUM_I${SX_CFG_NUM_RANGE}_WLEN}" SX_SYS_NUM_QM="\${SX_NUM_I${SX_CFG_NUM_RANGE}_QM}" SX_SYS_NUM_ZR="\${SX_NUM_I${SX_CFG_NUM_RANGE}_ZR}" SX_SYS_NUM_MAX="\${SX_NUM_I${SX_CFG_NUM_RANGE}_MAX}" SX_SYS_NUM_MIN="\${SX_NUM_I${SX_CFG_NUM_RANGE}_MIN}"
		esac
	done

	unset CLEANUP
}
|], [|cfg_set|])dnl
popdef([|CLEANUP|])dnl
