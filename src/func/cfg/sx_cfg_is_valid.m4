M_REQUIRE([|SX_CFG_ARR_HOLE SX_CFG_ARR_REF SX_CFG_ARR_UPDATE SX_CFG_NUM_RANGE SX_CFG_SEP SX_CFG_SIG_ARR SX_CFG_SKIP_CHK|])dnl
pushdef([|CLEANUP|])dnl
M_RENAME_Q([|dnl
### sx_cfg_is_valid - SX_CFG_* の値が妥当か検査する
##
## 使い方:
##   sx_cfg_is_valid [名前[=値] ...]
##
## 説明:
##   引数が '名前=値' の形式の場合は、その設定値が妥当か検査する。
##   引数が '名前' のみの場合は、その名前が設定項目として有効か検査する。
##   引数がない場合は、現在の SX_CFG_* 変数の値をすべて検査する。
##   未設定の項目は不正とする。設定済みの空文字は項目ごとの規則に従って検査する。
##   設定項目名は SX_CFG_META_NAMES に列挙する。META_ で始まる名前は設定項目として認めない。
##   各設定値の受理パターンは SX_CFG_META_PATTERN_* に公開する。
##
## 終了ステータス:
##    0  すべて妥当 (SX_EX_OK)
##    1  無効な設定項目、または不適切な値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_cfg_is_valid() {
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
