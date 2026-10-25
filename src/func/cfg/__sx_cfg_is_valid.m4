M_REQUIRE([|SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SIG_ARR SX_CFG_SKIP_CHK|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_QI([|dnl
### __sx_cfg_is_valid - SX_CFG_* の値が妥当か検査する（内部用）
##
## 使い方:
##   __sx_cfg_is_valid [名前[=値] ...]
##
## 説明:
##   内部実装。引数チェックは行わない。
##   設定名・設定値の妥当性判定を行う。
##   引数がない場合は全設定の現在値を検査し、未設定と設定済みの空文字を区別する。
##
## 終了ステータス:
##    0  すべて妥当 (SX_EX_OK)
##    1  無効な設定項目、または不適切な値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_cfg_is_valid() {
	case "${#}" in 0)
		set -- patsubst(M_CFG_META_NAMES, [|\([_A-Z][_A-Z0-9]*\)|], [|"${SX_CFG_\1+\1=${SX_CFG_\1}}"|])
	esac

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			patsubst(M_CFG_META_NAMES, [| |], [| | |])) ;;
patsubst(M_CFG_META_NAMES, [|\([_A-Z][_A-Z0-9]*\)|], [|__sx_m4_gen_cfg_case(\1)|])dnl
			*)
				unset CLEANUP
				return 1
				;;
		esac
	done

	unset CLEANUP
}
|], [|cfg_is_valid|])dnl
popdef([|CLEANUP|])dnl
