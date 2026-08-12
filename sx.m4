#!/bin/sh
# shellcheck shell=sh

changequote([|, |]) dnl
changecom() dnl

define([|M_STR_NE|], [|case $1 in $2) ! :;; esac|]) dnl

define([|M_STR_EQ|], [|dnl
{ case $1 in $2);; *) ! :;; esac ifelse(eval($# > 2), 1, [|&& __M_STR_EQ_REST(shift($@))|]); }dnl
|]) dnl
define([|__M_STR_EQ_REST|], [|dnl
case $1 in $2);; *) ! :;; esac ifelse(eval($# > 2), 1, [| && __M_STR_EQ_REST(shift($@))|])dnl
|]) dnl

define([|M_STR_HAS|], [|case $1 in __M_STR_HAS_REST(shift($@)));; *) ! :;; esac|])
define([|__M_STR_HAS_REST|], [|ifelse($#, 0, , $#, 1, [|*$1*|], [|*$1* | __M_STR_HAS_REST(shift($@))|])|])

define([|M_STR_MATCH|], [|case $1 in __M_STR_MATCH_REST(shift($@)));; *) ! :;; esac|])
define([|__M_STR_MATCH_REST|], [|ifelse($#, 0, , $#, 1, [|$1|], [|$1 | __M_STR_MATCH_REST(shift($@))|])|])

define([|__M_NUM_CMP_CHAIN|], [|dnl
$2 $1 $3 ifelse(eval(3 < $#), 1, [| && __M_NUM_CMP_CHAIN($1, shift(shift($@))) |])dnl
|]) dnl
define([|M_NUM_EQ|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(==, $@)))|], 0)|]) dnl
define([|M_NUM_GE|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(>=, $@)))|], 0)|]) dnl
define([|M_NUM_GT|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(>, $@)))|], 0)|]) dnl
define([|M_NUM_LE|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(<=, $@)))|], 0)|]) dnl
define([|M_NUM_LT|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(<, $@)))|], 0)|]) dnl
define([|M_NUM_NE|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(!=, $@)))|], 0)|]) dnl
define([|M_NUM_BOOL|], [|M_STR_NE([|$(($1))|], 0)|]) dnl

define([|__M_QUOTE_PREPEND|], [|dnl
	case $3 in
		*"'"*) __sx_str_sub $1_bind_esc_ $3 "'" "'\\''";;
		*) $1_bind_esc_=$3 ;;
	esac
	$2="'${$1_bind_esc_}'${$2:+ }${$2}"|])

define([|__M_QUOTE_APPEND|], [|dnl
	case $3 in
		*"'"*) __sx_str_sub $1_bind_esc_ $3 "'" "'\\''";;
		*) $1_bind_esc_=$3 ;;
	esac
	$2="${$2}${$2:+ }'${$1_bind_esc_}'"|])

define([|M_STR_QUOTE|], [|dnl
	case $2 in
		*"'"*) __sx_str_sub $1 $2 "'" "'\\''";;
		*) $1=$2;;
	esac

	$1="'${$1}'"|])

define([|__M_BIND_QUOTE|], [|dnl
	case "${$1_bind_}" in
		:*) $1_bind_="${$1_bind_#*:}";;
		[1-9]*:*)
			$1_bind_cnt_="${$1_bind_%%[!0-9]*}"
			$1_bind_name_="${$1_bind_%%:*}"
			$1_bind_name_="${$1_bind_name_#"${$1_bind_cnt_}"}"

			case "${$1_bind_name_}" in ?*)
				M_STR_QUOTE([|$1_bind_esc_|], [|$2|])
				eval "${$1_bind_name_}=\"\${${$1_bind_name_}-}\${${$1_bind_name_}+ }\${$1_bind_esc_}\""
			esac

			case "${$1_bind_cnt_}" in
				1) $1_bind_="${$1_bind_#*:}";;
				*) $1_bind_="$((${$1_bind_cnt_} - 1))${$1_bind_name_}:${$1_bind_#*:}";;
			esac
			;;
		*:*)
			eval "${$1_bind_%%:*}=patsubst([|$2|], [|[\\"`$]|], [|\\\&|])"
			$1_bind_="${$1_bind_#*:}"
			;;
		?*) __M_QUOTE_APPEND([|$1|], [|$1_out_|], [|$2|]);;
		*) unset $3; return "${SX_EX_OK}";;
	esac|])

define([|__M_BIND_UNQUOTE|], [|dnl
	case "${$1_bind_}" in
		:*) $1_bind_="${$1_bind_#*:}";;
		[1-9]*:*)
			$1_bind_cnt_="${$1_bind_%%[!0-9]*}"
			$1_bind_name_="${$1_bind_%%:*}"
			$1_bind_name_="${$1_bind_name_#"${$1_bind_cnt_}"}"

			case "${$1_bind_name_}" in ?*)
				eval "${$1_bind_name_}=\"\${${$1_bind_name_}-}\${${$1_bind_name_}+ }\"patsubst([|$2|], [|[\\"`$]|], [|\\\&|])"
			esac

			case "${$1_bind_cnt_}" in
				1) $1_bind_="${$1_bind_#*:}";;
				*) $1_bind_="$((${$1_bind_cnt_} - 1))${$1_bind_name_}:${$1_bind_#*:}";;
			esac
			;;
		*:*)
				eval "${$1_bind_%%:*}=patsubst([|$2|], [|[\\"`$]|], [|\\\&|])"
			$1_bind_="${$1_bind_#*:}"
			;;
		?*) $1_out_="${$1_out_}${$1_out_:+ }"$2;;
		*) unset $3; return "${SX_EX_OK}";;
	esac|])
define([|__M_BIND_USEVAR|], [|V(bind_cnt) V(bind_name) V(bind_esc)|])dnl

# sysexits(3) compatible exit codes
readonly SX_EX_OK=0
readonly SX_EX_USAGE=64
readonly SX_EX_DATAERR=65
readonly SX_EX_NOINPUT=66
readonly SX_EX_NOUSER=67
readonly SX_EX_NOHOST=68
readonly SX_EX_UNAVAILABLE=69
readonly SX_EX_SOFTWARE=70
readonly SX_EX_OSERR=71
readonly SX_EX_OSFILE=72
readonly SX_EX_CANTCREAT=73
readonly SX_EX_IOERR=74
readonly SX_EX_TEMPFAIL=75
readonly SX_EX_PROTOCOL=76
readonly SX_EX_NOPERM=77
readonly SX_EX_CONFIG=78

readonly SX_EX_MSG0='EX_OK(0): successful termination'
readonly SX_EX_MSG64='EX_USAGE(64): command line usage error'
readonly SX_EX_MSG65='EX_DATAERR(65): data format error'
readonly SX_EX_MSG66='EX_NOINPUT(66): cannot open input'
readonly SX_EX_MSG67='EX_NOUSER(67): addressee unknown'
readonly SX_EX_MSG68='EX_NOHOST(68): host name unknown'
readonly SX_EX_MSG69='EX_UNAVAILABLE(69): service unavailable'
readonly SX_EX_MSG70='EX_SOFTWARE(70): internal software error'
readonly SX_EX_MSG71="EX_OSERR(71): system error (e.g., can't fork)"
readonly SX_EX_MSG72='EX_OSFILE(72): critical OS file missing'
readonly SX_EX_MSG73="EX_CANTCREAT(73): can't create (user) output file"
readonly SX_EX_MSG74='EX_IOERR(74): input/output error'
readonly SX_EX_MSG75='EX_TEMPFAIL(75): temp failure; user is invited to retry'
readonly SX_EX_MSG76='EX_PROTOCOL(76): remote error in protocol'
readonly SX_EX_MSG77='EX_NOPERM(77): permission denied'
readonly SX_EX_MSG78='EX_CONFIG(78): configuration error'

readonly SX_EX_MAP='OK:0 USAGE:64 DATAERR:65 NOINPUT:66 NOUSER:67 NOHOST:68 UNAVAILABLE:69 SOFTWARE:70 OSERR:71 OSFILE:72 CANTCREAT:73 IOERR:74 TEMPFAIL:75 PROTOCOL:76 NOPERM:77 CONFIG:78'

readonly SX_VAR_BIND_QUOTE=1

readonly SX_STR_SOH=$'\cA'
readonly SX_STR_STX=$'\cB'
readonly SX_STR_ETX=$'\cC'
readonly SX_STR_EOT=$'\cD'
readonly SX_STR_ENQ=$'\cE'
readonly SX_STR_ACK=$'\cF'
readonly SX_STR_BEL=$'\cG'
readonly SX_STR_BS=$'\cH'
readonly SX_STR_HT=$'\cI'
readonly SX_STR_LF=$'\cJ'
readonly SX_STR_VT=$'\cK'
readonly SX_STR_FF=$'\cL'
readonly SX_STR_CR=$'\cM'
readonly SX_STR_SO=$'\cN'
readonly SX_STR_SI=$'\cO'
readonly SX_STR_DLE=$'\cP'
readonly SX_STR_DC1=$'\cQ'
readonly SX_STR_DC2=$'\cR'
readonly SX_STR_DC3=$'\cS'
readonly SX_STR_DC4=$'\cT'
readonly SX_STR_NAK=$'\cU'
readonly SX_STR_SYN=$'\cV'
readonly SX_STR_ETB=$'\cW'
readonly SX_STR_CAN=$'\cX'
readonly SX_STR_EM=$'\cY'
readonly SX_STR_SUB=$'\cZ'
readonly SX_STR_ESC=$'\c['
readonly SX_STR_FS=$'\c\\'
readonly SX_STR_GS=$'\c]'
readonly SX_STR_RS=$'\c^'
readonly SX_STR_US=$'\c_'
readonly SX_STR_DEL=$'\c?'

readonly SX_STR_BLANK=$'\t '
readonly SX_STR_SPACE=$'\t\n\v\f\r '
readonly SX_STR_CNTRL=$'\cA\cB\cC\cD\cE\cF\cG\cH\cI\cJ\cK\cL\cM\cN\cO\cP\cQ\cR\cS\cT\cU\cV\cW\cX\cY\cZ\c[\c\\\c]\c^\c_\c?'
readonly SX_STR_OCT='01234567'
readonly SX_STR_DIGIT='0123456789'
readonly SX_STR_XDIGIT='0123456789ABCDEFabcdef'
readonly SX_STR_UPPER='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
readonly SX_STR_LOWER='abcdefghijklmnopqrstuvwxyz'
readonly SX_STR_PUNCT='!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~'
readonly SX_STR_ALPHA="${SX_STR_UPPER}${SX_STR_LOWER}"
readonly SX_STR_ALNUM="${SX_STR_DIGIT}${SX_STR_ALPHA}"
readonly SX_STR_WORD="_${SX_STR_ALNUM}"
readonly SX_STR_GRAPH="${SX_STR_PUNCT}${SX_STR_ALNUM}"
readonly SX_STR_PRINT=" ${SX_STR_GRAPH}"
readonly SX_STR_ASCII="${SX_STR_CNTRL}${SX_STR_GRAPH}"

# sx_str_split 等で使用するフラグ
readonly SX_STR_SPLIT_GLOB=1
readonly SX_STR_SPLIT_INC=2
readonly SX_STR_SUB_GLOB=1
readonly SX_STR_SUB_CB=2
readonly SX_STR_CAPITAL_KEEP=1
readonly SX_STR_CAPITAL_SENT=2
readonly SX_ARG_PAD_CB=1
readonly SX_ARG_RESIZE_PAD_LEFT=2
readonly SX_STR_ISEP_CB=1
readonly SX_STR_ISEP_PRE=2
readonly SX_STR_ISEP_POST=4
readonly SX_ARG_ISEP_CB=1
readonly SX_ARG_ISEP_PRE=2
readonly SX_ARG_ISEP_POST=4
readonly SX_ARG_FIND_GLOB=1
readonly SX_ARG_FIND_TEXT=4
readonly SX_ARG_FIND_CB=2
readonly SX_ARG_RFIND_GLOB=1
readonly SX_ARG_RFIND_TEXT=4
readonly SX_ARG_RFIND_CB=2
readonly SX_ARG_COUNT_GLOB=1
readonly SX_ARG_COUNT_CB=2
readonly SX_STR_FIND_GLOB=1
readonly SX_STR_FIND_OVERLAP=2
readonly SX_STR_FIND_TEXT=4
readonly SX_STR_RFIND_GLOB=1
readonly SX_STR_RFIND_OVERLAP=2
readonly SX_STR_RFIND_TEXT=4
readonly SX_STR_COUNT_GLOB=1
readonly SX_STR_COUNT_OVERLAP=2
readonly SX_STR_CHUNK_SKIP_SHORT=1
readonly SX_STR_CHUNK_SKIP_LONG=2

# 数値定数 (8bit / 16bit / 32bit / 64bit / 128bit 整数限界)
readonly SX_NUM_I8_MAX=127
readonly SX_NUM_I8_MIN=-128
readonly SX_NUM_U8_MAX=255
readonly SX_NUM_I16_MAX=32767
readonly SX_NUM_I16_MIN=-32768
readonly SX_NUM_U16_MAX=65535
readonly SX_NUM_I32_MAX=2147483647
readonly SX_NUM_I32_MIN=-2147483648
readonly SX_NUM_U32_MAX=4294967295
readonly SX_NUM_I64_MAX=9223372036854775807
readonly SX_NUM_I64_MIN=-9223372036854775808
readonly SX_NUM_U64_MAX=18446744073709551615
readonly SX_NUM_I128_MAX=170141183460469231731687303715884105727
readonly SX_NUM_I128_MIN=-170141183460469231731687303715884105728
readonly SX_NUM_U128_MAX=340282366920938463463374607431768211455

# SX_CFG_NUM_RANGE に対応するチャンク処理定数（事前定義）
# wlen = (SX_CFG_NUM_RANGE - 2) * 30103 / 100000 により
# 2 * 10^wlen <= 2^(SX_CFG_NUM_RANGE - 1) を保証
readonly SX_NUM_RANGE_32_WLEN=9
readonly SX_NUM_RANGE_32_QM='?????????'
readonly SX_NUM_RANGE_32_ZR='000000000'
readonly SX_NUM_RANGE_64_WLEN=18
readonly SX_NUM_RANGE_64_QM='??????????????????'
readonly SX_NUM_RANGE_64_ZR='000000000000000000'
readonly SX_NUM_RANGE_128_WLEN=37
readonly SX_NUM_RANGE_128_QM='?????????????????????????????????????'
readonly SX_NUM_RANGE_128_ZR='0000000000000000000000000000000000000'

# 最適乗算チャンク用動的定数の事前定義 (1〜37桁)
define([|__sx_m4_gen_qm|], [|readonly SX_QM_$1='$2'
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_qm(incr($1), $2?)|])|])dnl
__sx_m4_gen_qm(1, ?)

define([|__sx_m4_gen_zr|], [|readonly SX_ZR_$1='$2'
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_zr(incr($1), $2[|0|])|])|])dnl
__sx_m4_gen_zr(1, 0)

# 浮動小数点数限界 (IEEE 754 準拠)
readonly SX_NUM_DBL_MAX='1.7976931348623157e+308'
readonly SX_NUM_DBL_MIN='2.2250738585072014e-308'
readonly SX_NUM_DBL_EPSILON='2.2204460492503131e-16'
readonly SX_NUM_FLT_MAX='3.402823466e+38'
readonly SX_NUM_FLT_MIN='1.175494351e-38'
readonly SX_NUM_FLT_EPSILON='1.192092896e-07'

# 数学定数 (bc などの外部コマンド利用時用)
readonly SX_NUM_PI='3.14159265358979323846'
readonly SX_NUM_TAU='6.28318530717958647692'
readonly SX_NUM_E='2.71828182845904523536'
readonly SX_NUM_SQRT2='1.41421356237309504880'
readonly SX_NUM_SQRT3='1.73205080756887729352'
readonly SX_NUM_SQRT5='2.23606797749978969640'
readonly SX_NUM_PHI='1.61803398874989484820'
readonly SX_NUM_LN2='0.69314718055994530941'
readonly SX_NUM_LN10='2.30258509299404568401'

readonly SX_NUM_BASE8_PREFIX='0'
readonly SX_NUM_BASE8_CHARS='01234567'
readonly SX_NUM_BASE10_PREFIX=
readonly SX_NUM_BASE10_CHARS='0123456789'
readonly SX_NUM_BASE16_PREFIX='0[Xx]'
readonly SX_NUM_BASE16_CHARS='0123456789ABCDEFabcdef'

# 配列を識別するためのシグネチャ。外部コマンドに依存せず、十分に長く複雑な値をデフォルトとする。
readonly SX_CFG_DEF_SIG_BASE=sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c
readonly SX_CFG_DEF_SIG_ARR="array-${SX_CFG_DEF_SIG_BASE}"
readonly SX_CFG_DEF_SKIP_CHK=0
readonly SX_CFG_DEF_NUM_RANGE=32
readonly SX_CFG_DEF_SEP=':::'
readonly SX_CFG_DEF_UNSET_SOFT=0

: "${SX_CFG_SIG_BASE:=${SX_CFG_DEF_SIG_BASE}}"
: "${SX_CFG_SIG_ARR:=${SX_CFG_DEF_SIG_ARR}}"
: "${SX_CFG_SKIP_CHK:=${SX_CFG_DEF_SKIP_CHK}}"
: "${SX_CFG_NUM_RANGE:=${SX_CFG_DEF_NUM_RANGE}}"
: "${SX_CFG_SEP:=${SX_CFG_DEF_SEP}}"
: "${SX_CFG_UNSET_SOFT:=${SX_CFG_DEF_UNSET_SOFT}}"
SX_SYS_REV=0

# ========================================
#  CFG (Configuration)
# ========================================

### sx_cfg_is_valid - SX_CFG_* の値が妥当か検査する
##
## 使い方:
##   sx_cfg_is_valid [名前[=値] ...]
##
## 説明:
##   引数が '名前=値' の形式の場合は、その設定値が妥当か検査する。
##   引数が '名前' のみの場合は、その名前が設定項目として有効か検査する。
##   引数がない場合は、現在の SX_CFG_* 変数の値をすべて検査する。
##
## 終了ステータス:
##    0  すべて妥当 (SX_EX_OK)
##    1  無効な設定項目、または不適切な値が含まれる
sx_cfg_is_valid() {
	case "${#}" in 0)
		__sx_cfg_is_valid_out=

		for __sx_cfg_is_valid_vn in NUM_RANGE SKIP_CHK SIG_BASE SIG_ARR SEP UNSET_SOFT; do
			__sx_cfg_is_valid_out="${__sx_cfg_is_valid_out} ${__sx_cfg_is_valid_vn}=\"\${SX_CFG_${__sx_cfg_is_valid_vn}-}\""
		done

		eval set -- "${__sx_cfg_is_valid_out}"
		unset __sx_cfg_is_valid_out __sx_cfg_is_valid_vn

		sx_cfg_is_valid "${@}" || return 1

		return "${SX_EX_OK}"
	esac

	for __sx_cfg_is_valid_arg in "${@}"; do
		case "${__sx_cfg_is_valid_arg}" in
			NUM_RANGE | SKIP_CHK | SIG_BASE | SIG_ARR | SEP | UNSET_SOFT) ;;
			NUM_RANGE=32 | NUM_RANGE=64 | NUM_RANGE=128) ;;
			SKIP_CHK=[01] | UNSET_SOFT=[012] | SEP=?* | SIG_BASE=?* | SIG_ARR=?*) ;;
			*)
				unset __sx_cfg_is_valid_arg
				return 1
				;;
		esac
	done

	unset __sx_cfg_is_valid_arg
}

define([|V|], [|__sx_cfg_set_$1|])dnl
define([|CLEANUP|], [|V(arg) V(chk)|])dnl

### sx_cfg_set - SX_CFG_* を設定する
##
## 使い方:
##   sx_cfg_set [名前[=値] ...]
##
## 説明:
##   sx_cfg_is_valid を用いて全引数を検査し、すべて合格した場合のみ値を設定する。
##   '名前' のみが指定された場合は、その項目をデフォルト値にリセットする。
##   SX_CFG_SIG_BASE が変更された場合は、自動的に SX_CFG_SIG_ARR も更新する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  無効な設定項目、または不適切な値が含まれる (SX_EX_USAGE)
##   77  設定項目が読み取り専用 (SX_EX_NOPERM)
sx_cfg_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_cfg_set "${@}" || return; return 0;; esac

	case "${#}" in 0) return "${SX_EX_OK}"; esac

	sx_cfg_is_valid "${@}" || return "${SX_EX_USAGE}"

	__sx_cfg_set_chk=

	for __sx_cfg_set_arg in "${@}"; do
		__sx_cfg_set_chk="${__sx_cfg_set_chk} SX_CFG_${__sx_cfg_set_arg%%=*}"
	done

	eval sx_var_is_rw "${__sx_cfg_set_chk}" || {
		unset CLEANUP
		return "${SX_EX_NOPERM}"
	}

	unset CLEANUP
	__sx_cfg_set "${@}"
}

### __sx_cfg_set - SX_CFG_* の値を実際に設定する（内部用）
##
## 使い方:
##   __sx_cfg_set [名前[=値] ...]
##
## 説明:
##   sx_cfg_set の内部実装。
##   引数チェックを行わずに設定値を反映する。
##   '名前' のみが指定された場合は、対応する SX_CFG_DEF_* の値でリセットする。
##   SIG_BASE が変更された場合は、SIG_ARR も自動的に更新する。
__sx_cfg_set() {
	for __sx_cfg_set_arg_ in "${@}"; do
		case "${__sx_cfg_set_arg_}" in
			*=*) eval "SX_CFG_${__sx_cfg_set_arg_%%=*}=\"\${__sx_cfg_set_arg_#*=}\"";;
			*) eval "SX_CFG_${__sx_cfg_set_arg_}=\"\${SX_CFG_DEF_${__sx_cfg_set_arg_}}\"";;
		esac

		case "${__sx_cfg_set_arg_}" in SIG_BASE | SIG_BASE=*)
			SX_CFG_SIG_ARR="array-${SX_CFG_SIG_BASE}"
		esac
	done

	unset __sx_cfg_set_arg_
}

# ========================================
#  EX (Exit Status)
# ========================================

### sx_ex_is_err - すべての引数がエラーを示す終了ステータス（1-255）であるか確認する
##
## 使い方:
##   sx_ex_is_err [値1 [値2 ...]]
##
## 説明:
##   引数で指定されたすべての値が、1 以上 255 以下の整数（10進数）であるかを確認する。
##
## 終了ステータス:
##    0  すべて 1-255 の範囲内である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
sx_ex_is_err() {
	for __sx_ex_is_err_arg in "${@}"; do
		case "${__sx_ex_is_err_arg}" in
			[1-9] | [1-9][0-9] | 1[0-9][0-9] | 2[0-4][0-9] | 25[0-5]) continue;;
		esac

		unset __sx_ex_is_err_arg
		return 1
	done

	unset __sx_ex_is_err_arg
}

### sx_ex_is_status - すべての引数が有効な終了ステータス（0-255）であるか確認する
##
## 使い方:
##   sx_ex_is_status [値1 [値2 ...]]
##
## 説明:
##   引数で指定されたすべての値が、0 以上 255 以下の整数（10進数）であるかを確認する。
##
## 終了ステータス:
##    0  すべて有効な終了ステータスである (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
sx_ex_is_status() {
	for __sx_ex_is_status_arg in "${@}"; do
		case "${__sx_ex_is_status_arg}" in
			[0-9] | [1-9][0-9] | 1[0-9][0-9] | 2[0-4][0-9] | 25[0-5]) continue;;
		esac

		unset __sx_ex_is_status_arg
		return 1
	done

	unset __sx_ex_is_status_arg
}

### sx_ex_is_valid - すべての引数が有効な終了ステータス（数値または名前）であるか確認する
##
## 使い方:
##   sx_ex_is_valid [値1 [値2 ...]]
##
## 説明:
##   引数で指定されたすべての値が、0-255 の整数、または有効な終了ステータス名
##   （OK, USAGE 等）であるかを確認する。
##
## 終了ステータス:
##    0  すべて有効な終了ステータスである (SX_EX_OK)
##    1  範囲外、または無効な値が含まれる
sx_ex_is_valid() {
	for __sx_ex_is_valid_arg in "${@}"; do
		case "${__sx_ex_is_valid_arg}" in
			[0-9] | [1-9][0-9] | 1[0-9][0-9] | 2[0-4][0-9] | 25[0-5]) continue;;
		esac

		case " ${SX_EX_MAP} " in
			*" ${__sx_ex_is_valid_arg}:"*) continue;;
		esac

		unset __sx_ex_is_valid_arg
		return 1
	done

	unset __sx_ex_is_valid_arg
}

### sx_ex_map - 終了ステータスの数値と名前を相互変換、または有効性を確認する
##
## 使い方:
##   sx_ex_map バインド形式 [値1 [値2 ...]]
##
## 説明:
##   終了ステータスの数値（0-255）を対応する名前（OK, USAGE, ...）に、
##   あるいは名前を数値に変換し、結果を指定された変数に格納する。
##   引数が指定されない場合は、バインド形式に基づき変数を初期化する。
##
## バインド形式:
##   - `変数名`: すべての引数の変換結果をスペース区切りで結合して格納する。
##   - `変数名1:変数名2`: 各引数を順番に変換して格納する。詳細は __sx_var_bind_init を参照。
##
## 終了ステータス:
##   - 0 (SX_EX_OK): すべての変換に成功。
##   - 64 (SX_EX_USAGE): 無効なステータス、または対応するマッピングが存在しない。
##   - 77 (SX_EX_NOPERM): 書き込み禁止の変数に代入しようとした。
sx_ex_map() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_ex_map "${@}" || return; return 0;; esac

	sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return

	__sx_ex_map_bind="${1}"
	shift

	for __sx_ex_map_arg in "${@}"; do
		case " ${SX_EX_MAP} " in
			*" ${__sx_ex_map_arg}:"* | *":${__sx_ex_map_arg} "*) ;;
			*)
				unset __sx_ex_map_bind __sx_ex_map_arg
				return "${SX_EX_USAGE}"
				;;
		esac
	done

	__sx_ex_map "${__sx_ex_map_bind}" "${@}"
	unset __sx_ex_map_bind __sx_ex_map_arg
}

define([|V|], [|__sx_ex_map_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(map) V(out) V(arg) __M_BIND_USEVAR|])dnl
### __sx_ex_map - 終了ステータスの数値と名前を相互変換、または有効性を確認する（内部用）
##
## 使い方:
##   __sx_ex_map バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_ex_map の内部実装。
##   引数チェックを行わずに変換処理を行う。
__sx_ex_map() {
	__sx_var_bind_init "${1}"
	__sx_ex_map_bind_="${1}"
	__sx_ex_map_map_=" ${SX_EX_MAP} "
	__sx_ex_map_out_=
	shift

	for __sx_ex_map_arg_ in "${@}"; do
		case " ${__sx_ex_map_map_} " in
			*" ${__sx_ex_map_arg_}:"*)
				__sx_ex_map_arg_="${__sx_ex_map_map_#*" ${__sx_ex_map_arg_}:"}"
				__sx_ex_map_arg_="${__sx_ex_map_arg_%% *}"
				;;
			*":${__sx_ex_map_arg_} "*)
				__sx_ex_map_arg_="${__sx_ex_map_map_%":${__sx_ex_map_arg_} "*}"
				__sx_ex_map_arg_="${__sx_ex_map_arg_##* }"
				;;
		esac

		__M_BIND_UNQUOTE([|__sx_ex_map|], [|"${__sx_ex_map_arg_}"|], CLEANUP)
	done

	eval ${__sx_ex_map_out_:+"${__sx_ex_map_bind_}=\"\${__sx_ex_map_out_}\""}

	unset CLEANUP
}

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
sx_ex_remap() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_ex_remap "${@}" || return; return 0;; esac

	for __sx_ex_remap_arg in "${@}"; do
		case "${__sx_ex_remap_arg}" in
			"${SX_CFG_SEP}") break;;
			*:*) ;;
			*) break;;
		esac

		__sx_ex_remap_src="${__sx_ex_remap_arg%%:*}"

		case "${__sx_ex_remap_src}" in
			-) ;;
			*?-) sx_ex_is_status "${__sx_ex_remap_src%-}";;
			-?*) sx_ex_is_status "${__sx_ex_remap_src#-}";;
			*-*) sx_ex_is_status "${__sx_ex_remap_src#*-}" "${__sx_ex_remap_src%%-*}";;
			*) sx_ex_is_valid "${__sx_ex_remap_src#!}";;
		esac || {
			unset __sx_ex_remap_arg __sx_ex_remap_src
			return "${SX_EX_USAGE}"
		}

		sx_ex_is_valid "${__sx_ex_remap_arg#*:}" || {
			unset __sx_ex_remap_arg __sx_ex_remap_src
			return "${SX_EX_USAGE}"
		}
	done

	unset __sx_ex_remap_arg __sx_ex_remap_src

	__sx_ex_remap "${@}" || return
}

### __sx_ex_remap - 終了ステータスのマッピングとコマンド実行を行う（内部用）
##
## 使い方:
##   __sx_ex_remap [置換元:置換先 ...] [:::] コマンド [引数 ...]
##
## 説明:
##   sx_ex_remap の内部実装。
##   引数のバリデーションは行わず、マッピングのパース、コマンドの実行、
##   および終了ステータスの変換を順次行う。
__sx_ex_remap() {
	__sx_ex_remap_map_=

	while M_STR_NE([|"${#}"|], [|0|]); do
		case "${1}" in
			"${SX_CFG_SEP}") shift; break;;
			*:*)
				__sx_ex_remap_map_="${__sx_ex_remap_map_} '${1}'"
				shift
				;;
			*) break;;
		esac
	done

	SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_ex_remap_cmd_ "${@}"
	set -- "${__sx_ex_remap_map_}" "${__sx_ex_remap_cmd_}"
	unset __sx_ex_remap_map_ __sx_ex_remap_cmd_

	eval "${2}" && __sx_ex_remap_sts_="${?}" || __sx_ex_remap_sts_="${?}"
	eval set -- "${1}"

	for __sx_ex_remap_map_ in "${@}"; do
		set -- "${__sx_ex_remap_map_%%:*}" "${__sx_ex_remap_map_#*:}"

		case "${1}" in
			"${__sx_ex_remap_sts_}") __sx_ex_remap_sts_="${2}"; break;;
			*-*)
				set -- "${@}" "${1%%-*}" "${1#*-}"

				case "$((${3:-0} <= __sx_ex_remap_sts_ && __sx_ex_remap_sts_ <= ${4:-255}))" in 1)
					__sx_ex_remap_sts_="${2}"; break
				esac
				;;
			!*)
				case "${1}" in ![!0-9]*)
					SX_CFG_UNSET_SOFT=2 __sx_ex_map __sx_ex_remap_n_ "${1#!}"
					set -- "!${__sx_ex_remap_n_}" "${2}"
				esac

				if M_STR_NE([|"${1#!}"|], [|"${__sx_ex_remap_sts_}"|]); then
					__sx_ex_remap_sts_="${2}"; break
				fi
				;;
			[!0-9]*)
				SX_CFG_UNSET_SOFT=2 __sx_ex_map __sx_ex_remap_n_ "${1}"

				case "${__sx_ex_remap_n_}" in "${__sx_ex_remap_sts_}")
					__sx_ex_remap_sts_="${2}"; break
				esac
				;;
		esac
	done

	case "${__sx_ex_remap_sts_}" in [!0-9]*)
		SX_CFG_UNSET_SOFT=2 __sx_ex_map __sx_ex_remap_sts_ "${__sx_ex_remap_sts_}"
	esac

	set -- "${__sx_ex_remap_sts_}"
	unset __sx_ex_remap_sts_ __sx_ex_remap_map_ __sx_ex_remap_n_
	return "${1}"
}

### sx_ex_yield - 任意の終了ステータスを発生させる
##
## 使い方:
##   sx_ex_yield [ステータス番号 | ステータス名]
##
## 説明:
##   指定された終了ステータス（数値または名前）を発生させる。
##   サブシェルを使用しないため、(exit n) よりも高速に動作する。
##
## 終了ステータス:
##   - 指定されたステータスを返す。
##   - 引数が指定されない場合は 0 (SX_EX_OK) を返す。
##   - ステータス値が 0-255 の範囲外、または整数でない場合は SX_EX_USAGE (64) を返す。
sx_ex_yield() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_ex_yield "${@}" || return; return 0;; esac

	sx_ex_is_valid "${1-0}" || return "${SX_EX_USAGE}"

	__sx_ex_yield "${@}" || return
}

### __sx_ex_yield - 任意の終了ステータスを発生させる（内部用）
##
## 使い方:
##   __sx_ex_yield [ステータス番号 | ステータス名]
##
## 説明:
##   指定された終了ステータス（数値または名前）を発生させる。
##   名前が渡された場合は数値に変換して返す。バリデーションは行わない。
##
## 終了ステータス:
##   - 指定されたステータスを返す。
__sx_ex_yield() {
	case "${1-0}" in [!0-9]*)
		SX_CFG_UNSET_SOFT=2 __sx_ex_map __sx_ex_yield_s_ "${1}"
		set -- "${__sx_ex_yield_s_}"
		unset __sx_ex_yield_s_
	esac

	return "${1-0}"
}

# ========================================
#  FN (Function)
# ========================================

define([|V|], [|__sx_fn_is_valid_$1|])dnl
define([|CLEANUP|], [|V(arg)|])dnl

### sx_fn_is_valid - 関数定義の妥当性（名前および構文）を確認する
##
## 使い方:
##   sx_fn_is_valid 名前=本体 [名前=本体 ...]
##
## 終了ステータス:
##    0  すべて妥当
##    1  無効な名前、または構文エラーが含まれる
sx_fn_is_valid() {
	for __sx_fn_is_valid_arg in "${@}"; do
		case "${__sx_fn_is_valid_arg}" in *=*)
			sx_var_is_name "${__sx_fn_is_valid_arg%%=*}" || {
				unset CLEANUP
				return 1
			}

			continue
		esac

		unset CLEANUP
		return 1
	done

	unset CLEANUP

	(
		for arg in "${@}"; do
			body="${arg#*=}"
			eval "${arg%%=*}() { ${body:-:}${SX_STR_LF}}" || exit 1
		done
	) 2>&- || return 1
}

### sx_fn_set - 関数を動的に定義する
##
## 使い方:
##   sx_fn_set 名前=本体 [名前=本体 ...]
##
## 説明:
##   指定された名前と本体（コマンド文字列）を用いて、関数を定義する。
##   本体は eval を介して定義されるため、クォーティングに注意が必要。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (名前が無効、または '=' がない) (SX_EX_USAGE)
sx_fn_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_set "${@}" || return; return 0;; esac

	sx_fn_is_valid "${@}" || return "${SX_EX_USAGE}"

	__sx_fn_set "${@}"
}

### __sx_fn_set - 関数を実際に定義する（内部用）
##
## 使い方:
##   __sx_fn_set 名前=本体 [名前=本体 ...]
__sx_fn_set() {
	for __sx_fn_set_arg_ in "${@}"; do
		__sx_fn_set_body_="${__sx_fn_set_arg_#*=}"
		eval "${__sx_fn_set_arg_%%=*}() { ${__sx_fn_set_body_:-:}${SX_STR_LF}}"
	done

	unset __sx_fn_set_arg_ __sx_fn_set_body_
}

### sx_fn_with - 一時的な匿名関数を定義してコマンドを実行する
##
## 使い方:
##   sx_fn_with [エイリアス=本体 ...] [${SX_CFG_SEP}] コマンド [引数 ...]
##
## 説明:
##   指定されたエイリアス名で一時的な関数を定義し、コマンドを実行する。
##   コマンドの引数の中にエイリアス名と一致するものがあれば、生成された一意な名前に置換される。
##   コマンドの実行終了後、定義された関数は自動的に削除される。
sx_fn_with() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_with "${@}" || return; return;; esac

	__sx_fn_with_i=0
	for __sx_fn_with_arg in "${@}"; do
		case "${__sx_fn_with_arg}" in
			"${SX_CFG_SEP-}") break;;
			*=*) ;;
			*) break;;
		esac

		: $((__sx_fn_with_i += 1))
	done

	case "${__sx_fn_with_i}" in [!0]*)
		SX_CFG_UNSET_SOFT=2 __sx_arg_quote "${__sx_fn_with_i}__sx_fn_with_fn:" "${@}"
		eval sx_fn_is_valid "${__sx_fn_with_fn}" || {
			unset __sx_fn_with_i __sx_fn_with_arg __sx_fn_with_fn
			return "${SX_EX_USAGE}"
		}
	esac

	unset __sx_fn_with_i __sx_fn_with_arg __sx_fn_with_fn

	__sx_fn_with "${@}" || return
}

### __sx_fn_with - 一時的な匿名関数を定義してコマンドを実行する（内部用）
__sx_fn_with() {
	__sx_fn_with_fns_=
	__sx_fn_with_map_=' '

	# 1. エイリアスの解析と関数定義
	while M_STR_NE([|"${#}"|], [|0|]); do
		case "${1}" in
			"${SX_CFG_SEP-}") shift; break;;
			*=*)
				__sx_fn_anon __sx_fn_with_u_ "${1#*=}"
				__sx_fn_with_fns_="${__sx_fn_with_fns_}${__sx_fn_with_fns_:+ }${__sx_fn_with_u_}"
				__sx_fn_with_map_="${__sx_fn_with_map_}${1%%=*}:${__sx_fn_with_u_} "
				shift
				;;
			*) break;;
		esac
	done

	# 2. コマンド引数の置換とクォート処理
	__sx_fn_with_q_=
	for __sx_fn_with_arg_ in "${@}"; do
		case "${__sx_fn_with_map_}" in
			*" ${__sx_fn_with_arg_}:"*)
				__sx_fn_with_m_="${__sx_fn_with_map_#*" ${__sx_fn_with_arg_}:"}"
				__sx_fn_with_arg_="${__sx_fn_with_m_%% *}"
				;;
		esac
		SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_fn_with_qa_ "${__sx_fn_with_arg_}"
		__sx_fn_with_q_="${__sx_fn_with_q_}${__sx_fn_with_q_:+ }${__sx_fn_with_qa_}"
	done

	# 3. 実行準備とクリーンアップ
	set -- "${__sx_fn_with_fns_}" "${__sx_fn_with_q_}"
	unset __sx_fn_with_fns_ __sx_fn_with_map_ __sx_fn_with_u_ __sx_fn_with_q_ __sx_fn_with_arg_ __sx_fn_with_m_ __sx_fn_with_qa_

	# 4. 実行と状態の保持 (set -e 対策)
	eval "${2}" || set -- "${@}" "${?}"

	# 5. 後始末
	case "${1}" in ?*) eval "unset -f ${1}";; esac

	return "${3-0}"
}

### sx_fn_anon - 一意な名前を持つ匿名関数を生成して定義する
##
## 使い方:
##   sx_fn_anon 結果変数名（またはバインド形式） 本体 [本体 ...]
##
## 説明:
##   指定された本体（コマンド文字列）を持つ関数を一意な名前で定義し、
##   その名前を結果変数に格納する。複数の本体を指定した場合は、
##   それぞれの関数名がスペース区切りで格納される。
##   生成された関数名は sx_fn_anon_N の形式となる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  本体の構文が不正 (SX_EX_USAGE)
sx_fn_anon() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_anon "${@}" || return; return;; esac

	__sx_fn_anon_bind="${1}"
	__sx_fn_anon_chk=
	shift

	for __sx_fn_anon_arg in "${@}"; do
		SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_fn_anon_arg "f=${__sx_fn_anon_arg}"
		__sx_fn_anon_chk="${__sx_fn_anon_chk} ${__sx_fn_anon_arg}"
	done

	eval sx_fn_is_valid "${__sx_fn_anon_chk}" || {
		unset __sx_fn_anon_bind __sx_fn_anon_chk __sx_fn_anon_arg
		return "${SX_EX_USAGE}"
	}

	__sx_fn_anon "${__sx_fn_anon_bind}" "${@}"
	unset __sx_fn_anon_bind __sx_fn_anon_chk __sx_fn_anon_arg
}

define([|V|], [|__sx_fn_anon_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(arg) V(name) __M_BIND_USEVAR|])dnl

### __sx_fn_anon - 匿名関数を実際に生成・定義する（内部用）
##
## 使い方:
##   __sx_fn_anon 結果変数名（またはバインド形式） 本体 [本体 ...]
##
##   一意な関数名 (sx_fn_anon_${SX_SYS_REV}) を生成して定義し、
##   結果変数に格納する。
__sx_fn_anon() {
	__sx_var_bind_init "${1}"
	__sx_fn_anon_bind_="${1}"
	__sx_fn_anon_out_=
	shift

	for __sx_fn_anon_arg_ in "${@}"; do
		__sx_fn_anon_name_="sx_fn_anon_${SX_SYS_REV}"

		__M_BIND_UNQUOTE([|__sx_fn_anon|], [|"${__sx_fn_anon_name_}"|], CLEANUP)

		__sx_fn_set "${__sx_fn_anon_name_}=${__sx_fn_anon_arg_}"

		: $((SX_SYS_REV += 1))
	done

	eval ${__sx_fn_anon_out_:+"${__sx_fn_anon_bind_}=\"\${__sx_fn_anon_out_}\""}

	unset CLEANUP
}

# ========================================
#  UTIL (Utilities)
# ========================================

### sx_util_eval - 文字列をシェルコマンドとして実行する
##
## 使い方:
##   sx_util_eval コマンド文字列
##
## 説明:
##   引数で渡された文字列を eval を用いて実行する。
##   直接的な eval の使用を避け、意図を明確にするためのラッパー。
sx_util_eval() {
	eval "${1}" || return
}

# ========================================
#  ARG (Arguments)
# ========================================

### sx_arg_count - 引数リストから指定された値の出現回数を取得する
##
## 使い方:
##   sx_arg_count 結果変数名 [arg...]
##   sx_arg_count 結果変数名 [検索対象 [フラグ]] ::: [arg ...]
##
## 説明:
##   引数リストから検索対象と一致する値の出現回数を数え、結果変数に非負整数で格納する。
##   フラグの意味は sx_arg_find と同一（SX_ARG_COUNT_GLOB, SX_ARG_COUNT_CB）。
##   SX_ARG_COUNT_CB (2) を指定すると、検索対象をコールバック関数として扱う。
##   コールバックシグネチャ: callback 値 インデックス 一致数
##     0 を返すと一致、非0 は不一致としてスキップ。
##   実質的に __sx_arg_find に委譲し、結果のスペース区切り件数を __sx_arg_len で取得する。
##
##   空の検索対象を指定した場合、空文字の値のみが一致とみなされる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_count() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_count "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 "${3}" || return

			case "$(((${3} & SX_ARG_COUNT_GLOB) * (${3} & SX_ARG_COUNT_CB)))" in [!0])
				return "${SX_EX_USAGE}"
			esac
			;;
	esac

	__sx_arg_count "${@}"
}

### __sx_arg_count - 引数リストから指定された値の出現回数を取得する（内部用）
##
## 使い方:
##   __sx_arg_count 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   sx_arg_count の内部実装。引数チェックは行わない。
__sx_arg_count() {
	__sx_arg_count_res_="${1}"
	shift

	SX_CFG_UNSET_SOFT=2 __sx_arg_find __sx_arg_count_tmp_ "${@}" || :

	eval __sx_arg_len "${__sx_arg_count_res_}" "${__sx_arg_count_tmp_}"

	unset __sx_arg_count_res_ __sx_arg_count_tmp_
}

### sx_arg_each - 引数リストの各要素に対してコールバック関数を実行する
##
## 使い方:
##   sx_arg_each コールバック [値 ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を実行する。
##   戻り値は収集せず、副作用のみを目的とする。
##
##   コールバック関数のシグネチャ:
##     callback 値 インデックス
##
##   コールバックの戻り値と動作:
##     - 成功 (0) => 次の要素に進む
##     - 失敗 (非0) => その時点で中断し、そのステータスを返す
##
## 終了ステータス:
##   すべてのコールバックが成功 => 0 (SX_EX_OK)
##   コールバックが失敗 => 最初の失敗のステータス
sx_arg_each() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_each "${@}" || return; return 0;; esac

	__sx_arg_each "${@}" || return
}

### __sx_arg_each - 引数リストの各要素に対してコールバック関数を実行する（内部用）
##
## 使い方:
##   __sx_arg_each コールバック [値 ...]
##
## 説明:
##   sx_arg_each の内部実装。引数チェックは行わない。
##   状態は位置変数で管理し、for ループでイテレートする。
##   カウンタの初期値を状態変数の個数 * -1 に設定し、
##   cnt < 0 の間は状態変数領域としてスキップする。
##
__sx_arg_each() {
	# $1: cnt, $2: cb, $@: data
	set -- -2 "${@}"

	for __sx_arg_each_arg_ in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${__sx_arg_each_arg_}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset __sx_arg_each_arg_

		"${2}" "${3}" "${1}" || return
	done

	unset __sx_arg_each_arg_
}

### sx_arg_enough - 引数リストから callback の条件を満たす要素が指定数以上あるか確認する
##
## 使い方:
##   sx_arg_enough [cb [need]] ::: [arg ...]
##   sx_arg_enough [cb] [arg ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を適用し、
##   成功（終了ステータス 0）となった要素の数が指定された個数以上であれば
##   0、そうでなければ 1 を返す。
##
##   第1形式（::: 形式）:
##     [cb [need]] ::: [arg ...]
##     ::: で metadata とデータを分離する。
##     need を省略すると data の個数がデフォルト値となる。
##     need に 0 を指定すると常に成功する（callback は呼ばれない）。
##
##   第2形式（短縮形式）:
##     [cb] [arg ...]
##     ::: を使用せず、第1引数が cb、第2引数以降が data となる。
##     need は常に data の個数（明示指定不可）。
##
##   コールバック関数のシグネチャ:
##     callback 値 インデックス
##   コールバックが 0 を返すと、その要素は条件を満たしたとカウントされる。
##
##   短絡評価:
##   - 条件を満たす要素が必要数に達した時点で即座に 0 を返す
##   - 残りの要素すべてが条件を満たしても必要数に達しないことが確定した時点で即座に 1 を返す
##
## 終了ステータス:
##    0  条件を満たす要素が必要数以上存在する (SX_EX_OK)
##    1  条件を満たす要素が必要数未満
##   64  引数不正 (SX_EX_USAGE)
sx_arg_enough() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_enough "${@}" || return; return 0;; esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}") ;;
		"${3+X${3}}") __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 "${2}" || return;;
	esac

	__sx_arg_enough "${@}" || return
}

### __sx_arg_enough - 引数リストから callback の条件を満たす要素が指定数以上あるか確認する（内部用）
##
## 使い方:
##   __sx_arg_enough [cb [need]] [:::] [arg ...]
##
## 説明:
##   sx_arg_enough の内部実装。引数チェックは行わない。
##   SX_CFG_SEP を $1/$2/$3 のいずれかから検出し、cb・need を抽出した上で
##   状態変数（idx, total, cb, need）を設定しループ処理する。
##   need をカウントダウン方式で管理し、状態変数を 4 個に抑えている。
##
__sx_arg_enough() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			__sx_arg_enough_cb_="${1}"
			shift 2
			;;
		"${3+X${3}}")
			__sx_arg_enough_cb_="${1}" __sx_arg_enough_need_="${2}"
			shift 3
			;;
		*)
			__sx_arg_enough_cb_="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	# $1=idx(-4), $2=total, $3=cb, $4=need(count-found)
	set -- -4 "${#}" "${__sx_arg_enough_cb_-}" "$((${__sx_arg_enough_need_:-${#}}))" "${@}"
	unset __sx_arg_enough_cb_ __sx_arg_enough_need_

	case "${4}" in 0)
		return "${SX_EX_OK}"
	esac

	for __sx_arg_enough_arg_ in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${__sx_arg_enough_arg_}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset __sx_arg_enough_arg_

		# 短絡評価: 残りの全要素が成功しても必要数に達しない
		case "$((${2} - ${1} + 1 < ${4}))" in 1)
			return 1
		esac

		"${3}" "${5}" "${1}" && set -- "${1}" "${2}" "${3}" "$((${4} - 1))" || :

		# 短絡評価: 必要数に達した
		case "${4}" in 0)
			return "${SX_EX_OK}"
		esac
	done

	unset __sx_arg_enough_arg_
	return 1
}

### sx_arg_find - 引数リストから指定された値を探し、そのインデックスまたは値を取得する
##
## 使い方:
##   sx_arg_find [結果変数名 [検索対象 [フラグ]]] ::: [値 ...]
##   sx_arg_find 結果変数名 [値 ...]
##
## 説明:
##   検索対象が、指定された値のリストの中で何番目（1開始）にあるかを探し、
##   一致した項目のインデックスをスペース区切りで結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   フラグに SX_ARG_FIND_GLOB (1) を指定すると、検索対象を glob パターンとして扱う。
##   フラグに SX_ARG_FIND_TEXT (4) を指定すると、インデックスの代わりにマッチした値を出力する。
##   フラグに SX_ARG_FIND_CB (2) を指定すると、検索対象をコールバック関数として扱う。
##   コールバックシグネチャ: callback value index
##     0 を返すと一致、非0 は不一致としてスキップ。
##   見つからない場合は空文字列を格納する。
##   取得件数はバインド形式によって決まる。
##   例: res（全件）、3res:（最大3件）、idx1:idx2（2件を分配）
##   2つの呼び出し形式がある:
##     1. ::: を使用する形式。bind, target, flg を :::
##        で区切って指定する。すべて省略可能（::: が第1引数の場合、
##        bind ごと省略）。
##     2. ::: を使用しない簡易形式。第1引数が bind、
##        第2引数以降が検索対象の値となる。
##        target・flg は指定不可。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった (不一致)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_find() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_find "${@}" || return; return 0;; esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*) __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable ${1+"${1}"} || return
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 "${3}" || return

			case "$(((${3} & SX_ARG_FIND_GLOB) * (${3} & SX_ARG_FIND_CB)))" in [!0])
				return "${SX_EX_USAGE}"
			esac
			;;
	esac

	__sx_arg_find "${@}" || return
}

### __sx_arg_find - 引数リストから指定された値を探す（内部用: ディスパッチャ）
##
## 使い方:
##   __sx_arg_find 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   ::: セパレータをパースし、フラグに応じて __sx_arg_find_lit または
##   __sx_arg_find_cb にディスパッチする。
##   引数チェックは行わない。
__sx_arg_find() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			__sx_arg_find_bind_="${1}"
			shift 2;;
		"${3+X${3}}")
			__sx_arg_find_bind_="${1}" __sx_arg_find_tgt_="${2}"
			shift 3
			;;
		"${4+X${4}}")
			__sx_arg_find_bind_="${1}" __sx_arg_find_tgt_="${2}" __sx_arg_find_flg_="${3}"
			shift 4
			;;
		*)
			__sx_arg_find_bind_="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

		set -- "${__sx_arg_find_bind_-}" "${__sx_arg_find_tgt_-}" "${__sx_arg_find_flg_:-0}" "${@}"
	unset __sx_arg_find_bind_ __sx_arg_find_tgt_ __sx_arg_find_flg_

	__sx_var_bind_init "${1}"

	case "$((${3} & SX_ARG_FIND_CB))" in
		0) __sx_arg_find_lit "${@}";;
		*) __sx_arg_find_cb "${@}";;
	esac || return
}

### __sx_arg_find_cb - 引数リストからコールバックで値を検索する（内部用）
##
## 使い方:
##   __sx_arg_find_cb 結果変数名 コールバック フラグ [値 ...]
##
## 説明:
##   __sx_arg_find から呼ばれる。コールバックの終了ステータスで一致を判定する。
##   コールバックシグネチャ: callback value index count
##     0 を返すと一致、非0 は不一致としてスキップ。
##   引数は正規化済み。引数チェックは行わない。
##   状態は位置変数で管理し、__sx_var_bind でバインドする。
__sx_arg_find_cb() {
	set -- -6 0 "$(((${3} & SX_ARG_FIND_TEXT) != 0))" "${@}"

	for __sx_arg_find_cb_arg_ in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${5}" "${__sx_arg_find_cb_arg_}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset __sx_arg_find_cb_arg_ __sx_arg_find_cb_bind_

		case "${4}" in '')
			break
		esac

		# $1=i, $2=match_cnt, $3=txt_flg, $4=bind, $5=cb, $6=value
		"${5}" "${6}" "${1}" "${2}" && {
			case "${3}" in
				0) __sx_var_bind __sx_arg_find_cb_bind_ "${4}" "${1}" 0;;
				*) __sx_var_bind __sx_arg_find_cb_bind_ "${4}" "${6}" "${SX_VAR_BIND_QUOTE}";;
			esac

			set -- "${1}" "$((${2} + 1))" "${3}" "${__sx_arg_find_cb_bind_}" "${5}"
		}
	done

	unset __sx_arg_find_cb_arg_ __sx_arg_find_cb_bind_

	return "$((!${2}))"
}

define([|V|], [|__sx_arg_find_lit_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(tgt) V(glob) V(text) V(out) V(i) V(arg) V(sts) __M_BIND_USEVAR|])dnl

### __sx_arg_find_lit - 引数リストから指定された値を探す（内部用: リテラル/glob照合）
##
## 使い方:
##   __sx_arg_find_lit 結果変数名 検索対象 フラグ [値 ...]
##
## 説明:
##   __sx_arg_find から呼ばれる。先頭から末尾に向かって検索する。
##   引数は正規化済み。引数チェックは行わない。
__sx_arg_find_lit() {
	__sx_arg_find_lit_bind_="${1}"
	__sx_arg_find_lit_tgt_="${2}"
	__sx_arg_find_lit_glob_=$(((${3} & SX_ARG_FIND_GLOB) != 0))
	__sx_arg_find_lit_text_=$(((${3} & SX_ARG_FIND_TEXT) != 0))
	__sx_arg_find_lit_i_=1
	__sx_arg_find_lit_out_=

	shift 3

	for __sx_arg_find_lit_arg_ in "${@}"; do
		case "${__sx_arg_find_lit_glob_}${__sx_arg_find_lit_arg_}" in "0${__sx_arg_find_lit_tgt_}" | 1${__sx_arg_find_lit_tgt_})
			case "${__sx_arg_find_lit_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_arg_find_lit|], [|"${__sx_arg_find_lit_i_}"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_arg_find_lit|], [|"${__sx_arg_find_lit_arg_}"|], CLEANUP);;
			esac

			__sx_arg_find_lit_sts_="${SX_EX_OK}"
		esac

		: $((__sx_arg_find_lit_i_ += 1))
	done

	eval ${__sx_arg_find_lit_out_:+"${__sx_arg_find_lit_bind_}=\"\${__sx_arg_find_lit_out_# }\""}

	set -- "${__sx_arg_find_lit_sts_-1}"

	unset CLEANUP
	return "${1}"
}

### sx_arg_fold - 引数リストをコールバックで畳み込む（fold）
##
## 使い方:
##   sx_arg_fold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を適用し、
##   アキュムレータを更新しながら畳み込みを行う。
##   コールバック契約: callback ret_var acc current_value index
##     - ret_var: 新しいアキュムレータ値を格納する変数名
##     - acc: 現在のアキュムレータ値
##     - current_value: 現在処理中の要素の値
##     - index: 1-based インデックス
##   コールバックが ret_var を unset した場合、アキュムレータは変更されない。
##   コールバックが非0を返した場合、その時点のアキュムレータ値を結果変数に格納し、
##   直ちに終了する。
##
## 終了ステータス:
##   すべてのコールバックが成功 => 0 (SX_EX_OK)
##   コールバックが失敗 => 最初のエラーのステータス
##   64 => 引数不正 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_fold() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_fold "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_arg_fold "${@}" || return
}

### __sx_arg_fold - 引数リストをコールバックで畳み込む（内部用）
##
## 使い方:
##   __sx_arg_fold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   sx_arg_fold の内部実装。引数チェックは行わない。
##   状態は位置変数で管理し、for ループでイテレートする。
##   カウンタの初期値を状態変数の個数 * -1 に設定し、
##   cnt < 0 の間は状態変数領域としてスキップする。
##
__sx_arg_fold() {
	# $1: count, $2: res, $3: cb, $4: acc, $@: data
	set -- -4 "${@}"

	for __sx_arg_fold_arg_ in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${__sx_arg_fold_arg_}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset __sx_arg_fold_arg_

		"${3}" __sx_arg_fold_ret_ "${4}" "${5}" "${1}" || {
			set -- "${@}" "${?}"
			__sx_var_set "${2}=${4}"
			unset __sx_arg_fold_ret_
			return "${6}"
		}

		set -- "${1}" "${2}" "${3}" "${__sx_arg_fold_ret_-${4}}"
		unset __sx_arg_fold_ret_
	done

	__sx_var_set "${2}=${4}"
	unset __sx_arg_fold_arg_
}

define([|V|], [|__sx_arg_isep_$1|])dnl
define([|CLEANUP|], [|V(int) V(lim) V(flg)|])dnl

### sx_arg_isep - 引数間にセパレータを挿入し、すべてをクォートして結合する
##
## 使い方:
##   sx_arg_isep [bind [sep [inv [limit [flg]]]]] ::: [arg ...]
##   sx_arg_isep [bind] [arg ...]
##
## 説明:
##   引数グループの間にセパレータを挿入し、すべての要素（セパレータを含む）を
##   シングルクォートで囲んでスペース区切りで結合し、結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   インターバルが正の場合は先頭から、負の場合は末尾から数えて挿入する。
##   リミットを指定すると、セパレータの挿入回数を制限できる。
##   インターバルに 0 は指定できない。
##
##   2 つの呼び出し形式がある:
##     1) ::: 形式: bind/sep/inv/limit/flg を ::: より前の位置引数で指定し、
##        ::: 以降をデータとして扱う。設定引数とデータを明確に分離できる。
##     2) 簡略形式: bind のみを第一引数で指定し、第二引数以降はすべてデータ
##        として扱われる。この形式ではセパレータは空文字、インターバルは 1、
##        リミットは無制限、フラグは 0 になる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_isep "${@}" || return; return 0;; esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*) __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return;;
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}") __sx_arg_isep_int="${3}";;
		"${5+X${5}}") __sx_arg_isep_int="${3}" __sx_arg_isep_lim="${4}";;
		"${6+X${6}}") __sx_arg_isep_int="${3}" __sx_arg_isep_lim="${4}" __sx_arg_isep_flg="${5}";;
	esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int_inv ${__sx_arg_isep_int:+"${__sx_arg_isep_int}"} && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 ${__sx_arg_isep_lim:+"${__sx_arg_isep_lim}"} ${__sx_arg_isep_flg:+"${__sx_arg_isep_flg}"} || {
		set -- "${?}"
		unset CLEANUP
		return "${1}"
	}

	case ${__sx_arg_isep_int:+"${__sx_arg_isep_int#[+-]}"} in 0)
		unset CLEANUP
		return "${SX_EX_USAGE}"
	esac

	unset CLEANUP

	__sx_arg_isep "${@}" || return
}

define([|V|], [|__sx_arg_isep_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(sep) V(int) V(lim) V(flg)|])dnl

### __sx_arg_isep - 引数間にセパレータを挿入する（ディスパッチャ、内部用）
##
## 使い方:
##   __sx_arg_isep [bind [sep [inv [limit [flg]]]]] ::: [arg ...]
##   __sx_arg_isep [bind] [arg ...]
##
## 説明:
##   ::: のパースと、lit/cb の振り分けを行う。
__sx_arg_isep() {
	# ::: の位置を特定 (Bounded Search: $2, $3, $4, $5, $6)
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			__sx_arg_isep_bind_="${1}"
			shift 2;;
		"${3+X${3}}")
			__sx_arg_isep_bind_="${1}" __sx_arg_isep_sep_="${2}"
			shift 3
			;;
		"${4+X${4}}")
			__sx_arg_isep_bind_="${1}" __sx_arg_isep_sep_="${2}" __sx_arg_isep_int_="${3}"
			shift 4
			;;
		"${5+X${5}}")
			__sx_arg_isep_bind_="${1}" __sx_arg_isep_sep_="${2}" __sx_arg_isep_int_="${3}" __sx_arg_isep_lim_="${4}"
			shift 5
			;;
		"${6+X${6}}")
			__sx_arg_isep_bind_="${1}" __sx_arg_isep_sep_="${2}" __sx_arg_isep_int_="${3}" __sx_arg_isep_lim_="${4}" __sx_arg_isep_flg_="${5}"
			shift 6
			;;
		*)
			__sx_arg_isep_bind_="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	set -- "${__sx_arg_isep_bind_-}" "${__sx_arg_isep_sep_-}" "${__sx_arg_isep_int_:-1}" "${__sx_arg_isep_lim_:-${SX_NUM_I32_MAX}}" "$((${__sx_arg_isep_flg_:-0} & (${#} != 0 ? ~0 : (${__sx_arg_isep_int_:-1} > 0 ? ~SX_ARG_ISEP_POST : ~SX_ARG_ISEP_PRE))))" "${@}"
	unset CLEANUP

	__sx_var_bind_init "${1}"

	case "$((${5} & SX_ARG_ISEP_CB))" in
		0) __sx_arg_isep_lit "${@}";;
		*) __sx_arg_isep_cb "${@}";;
	esac || return
}

define([|V|], [|__sx_arg_isep_cb_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(int) V(flg) V(cnt) V(stat) V(post) V(r) V(i) V(arg) V(ret)|])dnl

### __sx_arg_isep_cb - 引数間にセパレータを挿入する（コールバックモード、内部用）
##
## 使い方:
##   __sx_arg_isep_cb 結果変数名 コールバック インターバル リミット フラグ [値 ...]
##
## 説明:
##   コールバックモード。セパレータ位置ごとにコールバックを呼び出し、
##   その戻り値をセパレータとして挿入する。
##
##   状態レイアウト（位置パラメータ、前向きのみ）:
##     $1: sep_cnt, $2: skip, $3: stat, $4: i
##     $5: bind, $6: cb, $7: int, $8: lim, $9: flags
##     $10+: 元の値（for ループが走査）
##
##   コールバック呼出: cb_func ret_var slot count skip
__sx_arg_isep_cb() {
	if M_NUM_LT([|0|], [|${3}|]); then
		# === 正のインターバル: 前向き処理 (左→右, append) ===
		# 状態レイアウトに再構築: $1=sep_cnt $2=skip $3=stat $4=i $5=bind $6=cb $7=int $8=lim $9=flags
		set -- 0 0 0 -10 "${@}"

		case "${5}" in '')
			return "${3}"
		esac

		# === PRE セパレータ ===
		case "$((${1} < ${8} && ${9} & SX_ARG_ISEP_PRE))" in 1)
			if "${6}" __sx_arg_isep_cb_ret_ 0 "$((${1} + 1))" "${2}"; then
				case "${__sx_arg_isep_cb_ret_+X}" in X)
					__sx_var_bind __sx_arg_isep_cb_bind_ "${5}" "${__sx_arg_isep_cb_ret_}" "${SX_VAR_BIND_QUOTE}"
					eval 'shift 5;' set -- "$((${1} + 1))" "${2}" 0 "${4}" "${__sx_arg_isep_cb_bind_}" '"${@}"';;
				*)
					eval 'shift 2;' set -- "$((${1} + 1))" "$((${2} + 1))" '"${@}"';;
				esac
			else
				eval 'shift 3;' set -- "${8}" "${2}" "${?}" '"${@}"'
			fi

			unset __sx_arg_isep_cb_ret_ __sx_arg_isep_cb_bind_ __sx_arg_isep_cb_cb_
		esac

		# === メインループ ===
		for __sx_arg_isep_cb_arg_ in "${@}"; do
			set -- "${1}" "${2}" "${3}" "$((${4} + 1))" "${5}" "${6}" "${7}" "${8}" "${9}" "${__sx_arg_isep_cb_arg_}"

			case "$((${4} < 0))" in 1)
				continue
			esac

			unset __sx_arg_isep_cb_arg_

			case "${5}" in '')
				return "${3}"
			esac

			# 内部セパレータ挿入判定（前向き）
			case "$((${1} < ${8} && 0 < ${4} && ${4} % ${7} == 0))" in 1)
				if "${6}" __sx_arg_isep_cb_ret_ "${4}" "$((${1} + 1))" "${2}"; then
					case "${__sx_arg_isep_cb_ret_+X}" in X)
						__sx_var_bind __sx_arg_isep_cb_bind_ "${5}" "${__sx_arg_isep_cb_ret_}" "${SX_VAR_BIND_QUOTE}"

						set -- "$((${1} + 1))" "${2}" 0 "${4}" "${__sx_arg_isep_cb_bind_}" "${6}" "${7}" "${8}" "${9}" "${10}";;
					*)
						set -- "$((${1} + 1))" "$((${2} + 1))" 0 "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}";;
					esac
				else
					set -- "${8}" "${2}" "${?}" "${4}" "${5}" '' "${7}" "${8}" "${9}" "${10}"
				fi
			esac

			__sx_var_bind __sx_arg_isep_cb_bind_ "${5}" "${10}" "${SX_VAR_BIND_QUOTE}" || :
			set -- "${1}" "${2}" "${3}" "${4}" "${__sx_arg_isep_cb_bind_}" "${6}" "${7}" "${8}" "${9}"
			unset __sx_arg_isep_cb_ret_ __sx_arg_isep_cb_bind_
		done

		case "${5}" in '')
			unset __sx_arg_isep_cb_arg_
			return "${3}"
		esac

		# === POST セパレータ ===
		case "$((${1} < ${8} && ${9} & SX_ARG_ISEP_POST && (${4} + 1) % ${7} == 0))" in 1)
			if "${6}" __sx_arg_isep_cb_ret_ "$((${4} + 1))" "$((${1} + 1))" "${2}"; then
				case "${__sx_arg_isep_cb_ret_+X}" in X)
					__sx_var_bind __sx_arg_isep_cb_bind_ "${5}" "${__sx_arg_isep_cb_ret_}" "${SX_VAR_BIND_QUOTE}" || :
				esac
			else
				set -- "${1}" "${2}" "${?}"
			fi
		esac

		unset __sx_arg_isep_cb_ret_ __sx_arg_isep_cb_arg_ __sx_arg_isep_cb_bind_
		return "${3}"
	else
		# === 負のインターバル: countベースCB呼出 + 左→右bind ===
		__sx_arg_isep_cb_bind_="${1}"
		__sx_arg_isep_cb_cb_="${2}"
		__sx_arg_isep_cb_int_="${3}"
		__sx_arg_isep_cb_lim_="${4}"
		__sx_arg_isep_cb_flg_="${5}"
		shift 5

		# max = eff（accumulator、max < lim なら lim を cap）
		__sx_arg_isep_cb_max_=$(((0 < ${#}) * (${#} - 1) / ${__sx_arg_isep_cb_int_#-}))

		# POST加算
		case "$((__sx_arg_isep_cb_flg_ & SX_ARG_ISEP_POST))" in [!0]*)
			: $((__sx_arg_isep_cb_max_ += 1))
		esac

		# PRE加算（eff < lim - post は max < lim に簡約）
		case "$((__sx_arg_isep_cb_flg_ & SX_ARG_ISEP_PRE && (${#} % ${__sx_arg_isep_cb_int_#-}) == 0))" in 1)
			: $((__sx_arg_isep_cb_max_ += 1))
		esac

		# lim capping
		__sx_arg_isep_cb_lim_=$((__sx_arg_isep_cb_max_ < __sx_arg_isep_cb_lim_ ? __sx_arg_isep_cb_max_ : __sx_arg_isep_cb_lim_))

		# ===== Phase 1: countベースCB呼出 + 結果prepend（save/restore対応） =====
			# SAVE state (8 vars) — 再帰呼び出しでCLEANUPにより変数が消える対策
		set -- 0 0 "${__sx_arg_isep_cb_bind_}" "${__sx_arg_isep_cb_cb_}" "${__sx_arg_isep_cb_int_}" "${__sx_arg_isep_cb_lim_}" "${__sx_arg_isep_cb_flg_}" "${#}" "${@}"
		unset __sx_arg_isep_cb_bind_ __sx_arg_isep_cb_cb_ __sx_arg_isep_cb_int_ __sx_arg_isep_cb_lim_ __sx_arg_isep_cb_flg_ __sx_arg_isep_cb_max_

		while M_NUM_BOOL([|${1} < ${6}|]); do
			if "${4}" __sx_arg_isep_cb_ret_ "$(((${7} & SX_ARG_ISEP_POST) && ${1} == 0 ? ${8} : ${8} - (${1} + 1 - ((${7} & SX_ARG_ISEP_POST) != 0)) * ${5#-}))" "$((${1} + 1))" "${2}"; then
				case "${__sx_arg_isep_cb_ret_+X}" in
					X)
						__sx_arg_isep_cb_cb_="${4}"
						eval 'shift 8;' set -- "$((${1} + 1))" "${2}" "${3}" '"${__sx_arg_isep_cb_cb_}"' "${5}" "${6}" "${7}" "${8}" '"${__sx_arg_isep_cb_ret_+:}${__sx_arg_isep_cb_ret_-}"' '"${@}"'
						;;
				*) eval 'shift 2;' set -- "$((${1} + 1))" "$((${2} + 1))" '"${@}"';;
				esac
			else
				__sx_arg_isep_cb_stat_="${?}"
				break
			fi

			unset __sx_arg_isep_cb_ret_ __sx_arg_isep_cb_cb_
		done

		__sx_arg_isep_cb_cnt_="${1}"
		__sx_arg_isep_cb_bind_="${3}"
		__sx_arg_isep_cb_int_="${5}"
		__sx_arg_isep_cb_flg_="${7}"
		: "${__sx_arg_isep_cb_stat_=0}"
		shift 8

		# ===== Phase 2: 左→右bind (for ループ) =====
		# $@ = sep_N ... sep_1 data_1 ... data_M
		# cnt_ 個の sep が先頭に積まれている
		__sx_arg_isep_cb_post_=$((__sx_arg_isep_cb_flg_ & SX_ARG_ISEP_POST && 0 < __sx_arg_isep_cb_cnt_))
		__sx_arg_isep_cb_r_=$(((${#} - __sx_arg_isep_cb_cnt_) - (__sx_arg_isep_cb_cnt_ - __sx_arg_isep_cb_post_) * ${__sx_arg_isep_cb_int_#-}))

		# $@ 先頭から ${1} + shift で sep を消費する
		# PRE (先頭セパレータ)
		case "$((__sx_arg_isep_cb_flg_ & SX_ARG_ISEP_PRE && __sx_arg_isep_cb_r_ == 0))" in 1)
			case "${1}" in :*)
				__sx_var_bind __sx_arg_isep_cb_bind_ "${__sx_arg_isep_cb_bind_}" "${1#:}" "${SX_VAR_BIND_QUOTE}" || {
					set -- "${__sx_arg_isep_cb_stat_}"
					unset CLEANUP
					return "${1}"
				}
			esac

			shift
			: $((__sx_arg_isep_cb_cnt_ -= 1))
		esac

		# 要素を左→右に走査してbind (for ループ)
		__sx_arg_isep_cb_i_="-${__sx_arg_isep_cb_cnt_}"
		for __sx_arg_isep_cb_arg_ in "${@}"; do
			: $((__sx_arg_isep_cb_i_ += 1))

			# 先頭の sep 領域をスキップ
			case "$((__sx_arg_isep_cb_i_ <= 0))" in 1) continue; esac

			# 内部セパレータ
			case "$((
				1 < __sx_arg_isep_cb_i_ &&
				__sx_arg_isep_cb_r_ < __sx_arg_isep_cb_i_ &&
				(__sx_arg_isep_cb_i_ - __sx_arg_isep_cb_r_ - 1) % ${__sx_arg_isep_cb_int_#-} == 0
			))" in 1)
				case "${1}" in :*)
					__sx_var_bind __sx_arg_isep_cb_bind_ "${__sx_arg_isep_cb_bind_}" "${1#:}" "${SX_VAR_BIND_QUOTE}" || {
						set -- "${__sx_arg_isep_cb_stat_}"
						unset CLEANUP
						return "${1}"
					}
				esac

				shift
			esac

			# 要素本体をbind
			__sx_var_bind __sx_arg_isep_cb_bind_ "${__sx_arg_isep_cb_bind_}" "${__sx_arg_isep_cb_arg_}" "${SX_VAR_BIND_QUOTE}" || {
				set -- "${__sx_arg_isep_cb_stat_}"
				unset CLEANUP
				return "${1}"
			}
		done

		# POST (末尾セパレータ)
		case "$((__sx_arg_isep_cb_post_))${1}" in 1:*)
			__sx_var_bind __sx_arg_isep_cb_bind_ "${__sx_arg_isep_cb_bind_}" "${1#:}" "${SX_VAR_BIND_QUOTE}" || :;;
		esac

		set -- "${__sx_arg_isep_cb_stat_}"
		unset CLEANUP
		return "${1}"
	fi
}

define([|V|], [|__sx_arg_isep_lit_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(sep) V(int) V(flg) V(lim) V(eff) V(r) V(i) V(arg) V(max) V(post_ok) __M_BIND_USEVAR|])dnl

### __sx_arg_isep_lit - 引数間にリテラルセパレータを挿入する（内部用）
##
## 使い方:
##   __sx_arg_isep_lit 結果変数名 セパレータ インターバル フラグ リミット [値 ...]
##
## 説明:
##   引数間にセパレータを挿入し、すべてをクォートして結合する。
##   PRE/POST フラグにより先頭・末尾への挿入も行う。
__sx_arg_isep_lit() {
	__sx_arg_isep_lit_bind_="${1}"
	__sx_arg_isep_lit_sep_="${2}"
	__sx_arg_isep_lit_int_="${3}"
	__sx_arg_isep_lit_lim_="${4}"
	__sx_arg_isep_lit_flg_="${5}"
	__sx_arg_isep_lit_out_=
	shift 5

	# セパレータを挿入可能な論理的な箇所数（要素間のみ）を計算
	__sx_arg_isep_lit_eff_=$(((0 < ${#}) * (${#} - 1) / ${__sx_arg_isep_lit_int_#-}))

	# --- 特殊処理: 負のインターバル（後方から数えるモード） ---
	# インターバルが負の場合、末尾（POST側）を基準にするため、
	# POSTフラグが指定されている場合は、ループ前にあらかじめ回数を1つ消費しておく。
	case "$((__sx_arg_isep_lit_int_ < 0 && __sx_arg_isep_lit_lim_ != 0 && __sx_arg_isep_lit_flg_ & SX_ARG_ISEP_POST))" in 1)
		__sx_arg_isep_lit_post_ok_=1
		: $((__sx_arg_isep_lit_lim_ -= 1))
	esac

	# --- 回数制限 (lim) の調整 ---
	# PRE/POSTフラグを含めた「物理的に挿入可能な絶対最大数」を算出し、lim がそれを超えないよう制限(cap)する。
	__sx_arg_isep_lit_max_="${__sx_arg_isep_lit_eff_}"
	case "$((__sx_arg_isep_lit_flg_ & SX_ARG_ISEP_PRE))" in [!0]*)
		: $((__sx_arg_isep_lit_max_ += 1))
	esac

	case "$((__sx_arg_isep_lit_flg_ & SX_ARG_ISEP_POST))" in [!0]*)
		: $((__sx_arg_isep_lit_max_ += 1))
	esac

	case "$((__sx_arg_isep_lit_max_ < __sx_arg_isep_lit_lim_))" in 1)
		__sx_arg_isep_lit_lim_="${__sx_arg_isep_lit_max_}"
	esac

	# --- オフセット (r_) の計算 ---
	# ループ内で最初のセパレータをどこで入れるかを決めるための基準値を算出する。
	# 正の場合：単純にインターバル数。
	# 負の場合：要素数と残りの挿入可能回数から、左から数えて何個目を起点にするかを逆算。
	__sx_arg_isep_lit_r_=$((0 < __sx_arg_isep_lit_int_ ? __sx_arg_isep_lit_int_ : ${#} - __sx_arg_isep_lit_lim_ * ${__sx_arg_isep_lit_int_#-}))

	# --- PRE セパレータの挿入 ---
	# 先頭にセパレータを配置するフラグがある場合の処理。
	case "$((
		__sx_arg_isep_lit_flg_ & SX_ARG_ISEP_PRE &&
		(0 < __sx_arg_isep_lit_int_ ?
			__sx_arg_isep_lit_lim_ != 0 :
			__sx_arg_isep_lit_eff_ < __sx_arg_isep_lit_lim_ &&
			(__sx_arg_isep_lit_r_ % __sx_arg_isep_lit_int_) == 0)
		))" in 1)
		__M_BIND_QUOTE([|__sx_arg_isep_lit|], [|"${__sx_arg_isep_lit_sep_}"|], CLEANUP)
		: $((__sx_arg_isep_lit_lim_ -= 1))
	esac

	__sx_arg_isep_lit_i_=1
	# --- メインループ: 引数の結合 ---
	for __sx_arg_isep_lit_arg_ in "${@}"; do
		# 1. セパレータの挿入判定
		#    - 制限回数 (lim) が残っている
		#    - 最初の要素ではなく (1 < j_)
		#    - オフセット位置を過ぎており (r_ < j_)
		#    - インターバルの倍数位置である ((j - r - 1) % int == 0)
		case "$((
			__sx_arg_isep_lit_lim_ != 0 &&
			1 < __sx_arg_isep_lit_i_ &&
			__sx_arg_isep_lit_r_ < __sx_arg_isep_lit_i_ &&
			(__sx_arg_isep_lit_i_ - __sx_arg_isep_lit_r_ - 1) % __sx_arg_isep_lit_int_ == 0
		))" in 1)
			__M_BIND_QUOTE([|__sx_arg_isep_lit|], [|"${__sx_arg_isep_lit_sep_}"|], CLEANUP)
			: $((__sx_arg_isep_lit_lim_ -= 1))
		esac

		# 2. 値の結合（クォートして結合）
		__M_BIND_QUOTE([|__sx_arg_isep_lit|], [|"${__sx_arg_isep_lit_arg_}"|], CLEANUP)
		: $((__sx_arg_isep_lit_i_ += 1))
	done

	# --- POST セパレータの挿入 ---
	# 末尾にセパレータを配置するフラグがある場合の処理。
	case "$((${__sx_arg_isep_lit_post_ok_-0} || (
		0 < __sx_arg_isep_lit_int_ &&
		__sx_arg_isep_lit_lim_ != 0 &&
		__sx_arg_isep_lit_flg_ & SX_ARG_ISEP_POST &&
		(${#} - __sx_arg_isep_lit_r_) % ${__sx_arg_isep_lit_int_} == 0
	)))" in 1)
		__M_BIND_QUOTE([|__sx_arg_isep_lit|], [|"${__sx_arg_isep_lit_sep_}"|], CLEANUP)
	esac

	# 結果を出力変数に格納
	eval ${__sx_arg_isep_lit_out_:+"${__sx_arg_isep_lit_bind_}=\"\${__sx_arg_isep_lit_out_}\""}

	unset CLEANUP
}

### sx_arg_join - 引数を指定された区切り文字で結合する
##
## 使い方:
##   sx_arg_join 結果変数名 区切り文字 [値 ...]
##
## 説明:
##   指定された値を区切り文字で結合した文字列を作成して結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_join() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_join "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_arg_join "${@}"
}

### __sx_arg_join - 引数を指定された区切り文字で結合する（内部用）
##
## 使い方:
##   __sx_arg_join 結果変数名 区切り文字 [値 ...]
##
## 説明:
##   引数チェックを行わずに結合処理を行う。
__sx_arg_join() {
	__sx_arg_join_res_="${1}"
	__sx_arg_join_sep_="${2-}"
	__sx_arg_join_out_=
	shift ${2+2}

	for __sx_arg_join_arg_ in "${@}"; do
		__sx_arg_join_out_="${__sx_arg_join_out_}${__sx_arg_join_sep_}${__sx_arg_join_arg_}"
	done

	__sx_var_set "${__sx_arg_join_res_}=${__sx_arg_join_out_#"${__sx_arg_join_sep_}"}"

	unset __sx_arg_join_res_ __sx_arg_join_sep_ __sx_arg_join_out_ __sx_arg_join_arg_
}

### sx_arg_len - 引数の個数を取得する
##
## 使い方:
##   sx_arg_len 結果変数名 [引数 ...]
##
## 説明:
##   第2引数以降に渡された引数の個数を数え、その結果を結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_len() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_len "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_arg_len "${@}"
}

### __sx_arg_len - 引数の個数を取得する（内部用）
##
## 使い方:
##   __sx_arg_len 結果変数名 [引数 ...]
##
## 説明:
##   引数チェックを行わずに個数の取得を行う。
__sx_arg_len() {
	__sx_var_set "${1}=$((${#} - 1))"
}

### sx_arg_map - 引数リストの各要素にコールバック関数を適用する
##
## 使い方:
##   sx_arg_map 結果変数名（またはバインド形式） コールバック [値 ...]
##
## 説明:
##   指定された値のリストの各要素に対してコールバック関数を適用し、
##   その結果をバインド形式に従って結果変数に格納する。
##
##   コールバック関数のシグネチャ:
##     callback 結果変数名 現在の値 インデックス
##
##   コールバックの戻り値と動作:
##     - 成功 (0) + 結果変数に値を設定 => その値を変換後の要素としてバインド
##     - 成功 (0) + 結果変数が unset のまま => その要素をスキップ
##     - 失敗 (非0) => 元の値をそのままバインド、終了ステータスに反映
##   最初のエラー以降の要素も元の値をバインドする。
##
## 終了ステータス:
##   すべてのコールバックが成功 => 0 (SX_EX_OK)
##   一部のコールバックが失敗 => 最初の失敗のステータス
##   64 => 引数不正 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_map() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_map "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return

	__sx_arg_map "${@}" || return
}

### __sx_arg_map - 引数リストの各要素にコールバック関数を適用する（内部用）
##
## 使い方:
##   __sx_arg_map 結果変数名（またはバインド形式） コールバック [値 ...]
##
## 説明:
##   sx_arg_map の内部実装。引数チェックは行わない。
##   状態は位置変数で管理し、for ループでイテレートする。
##   カウンタの初期値を状態変数の個数 * -1 に設定し、
##   cnt < 0 の間は状態変数領域としてスキップする。
##
__sx_arg_map() {
	__sx_var_bind_init "${1}"

	# $1: status, $2: count, $3: callback, $4: bind, $@: 処理対象の引数
	set -- 0 -4 "${@}"

	for __sx_arg_map_arg_ in "${@}"; do
		set -- "${1}" "$((${2} + 1))" "${3}" "${4}" "${__sx_arg_map_arg_}"

		case "$((${2} <= 0))" in 1)
			continue
		esac

		case "${3}" in '') break;; esac

		case "${1}" in
			0)
				unset __sx_arg_map_arg_
				shift

				"${3}" __sx_arg_map_ret_ "${4}" "${1}" && set -- "${?}" "${@}" || {
					set -- "${?}" "${@}"
					__sx_arg_map_ret_="${5}"
				}
				;;
			*) __sx_arg_map_ret_="${5}";;
		esac

		case "${__sx_arg_map_ret_+X}" in X)
			__sx_var_bind __sx_arg_map_fmt_ "${3}" "${__sx_arg_map_ret_}"

			set -- "${1}" "${2}" "${__sx_arg_map_fmt_}" "${4}"
		esac

		unset __sx_arg_map_ret_ __sx_arg_map_fmt_
	done

	unset __sx_arg_map_arg_
	return "${1}"
}

### sx_arg_quote - 引数をシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arg_quote スキーマ [値 ...]
##
## 説明:
##   指定された値をそれぞれシングルクォートで囲み（内部のシングルクォートはエスケープ）、
##   スペース区切りで順方向に結合した文字列を作成して結果変数（スキーマ）に格納する。
##   スキーマにコロン (:) を含めることで、引数の分配代入（デストラクチャリング）が可能。
##   作成された文字列は eval 等で安全に位置パラメータに戻すことができる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_quote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_quote "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return

	__sx_arg_quote "${@}"
}

define([|V|], [|__sx_arg_quote_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(arg) __M_BIND_USEVAR|])dnl

### __sx_arg_quote - 引数をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_quote スキーマ [値 ...]
##
## 説明:
##   引数チェックを行わずに分配代入およびクォート結合処理を行う。
__sx_arg_quote() {
	__sx_var_bind_init "${1}"
	__sx_arg_quote_bind_="${1}"
	__sx_arg_quote_out_=
	shift

	for __sx_arg_quote_arg_ in "${@}"; do
		__M_BIND_QUOTE([|__sx_arg_quote|], [|"${__sx_arg_quote_arg_}"|], CLEANUP)
	done

	eval ${__sx_arg_quote_out_:+"${__sx_arg_quote_bind_}=\"\${__sx_arg_quote_out_}\""}

	unset CLEANUP
}

### sx_arg_pad - 引数リストを指定された長さになるようパディングする
##
## 使い方:
##   sx_arg_pad [bind [len [val [flg]]]] ::: [arg ...]
##   sx_arg_pad [bind] [arg ...]
##
## 説明:
##   与えられた引数リスト [arg ...] を、絶対値が |len| になるよう
##   val で拡張する。len が正の場合は右側（末尾）に、
##   負の場合は左側（先頭）にパディングする。
##   元の引数リストの長さが |len| 以上の場合は、そのまま出力する。
##   結果はシングルクォートで囲まれ、スペース区切りで結合された形式で
##   結果変数に格納される。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##
##   2 つの呼び出し形式がある:
##     1) ::: 形式: bind/len/val/flg を ::: より前の位置引数で指定し、
##        ::: 以降をデータとして扱う。設定引数とデータを明確に分離できる。
##     2) 簡略形式: bind のみを第一引数で指定し、第二引数以降はすべてデータ
##        として扱われる。この形式では len は 0、val は空文字、flg は 0 になる。
##
##   コールバックモード:
##     flg に SX_ARG_PAD_CB (1) を設定すると、val はコールバック関数名として
##     解釈される。コールバックはパディングスロットごとに呼び出され、
##     動的にパディング値を生成する。
##     コールバック契約: cb ret_var idx cnt skip
##       - ret_var: 結果を格納する変数名（unset するとそのスロットをスキップ）
##       - idx: 1-based 実際の出力位置（skip 考慮済み）
##       - cnt: 1-based パディングスロット番号
##       - skip: スキップ累計数
##     callback が非 0 を返した場合、処理を中断する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_pad() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_pad "${@}" || return; return 0;; esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*) __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable ${1+"${1}"} || return
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}") ;;
		"${3+X${3}}" | "${4+X${4}}") __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int_inv "${2}" || return;;
		"${5+X${5}}") __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int_inv "${2}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int_inv "${4}" || return;;
	esac

	__sx_arg_pad "${@}" || return
}

__sx_arg_pad() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			__sx_arg_pad_bind_="${1}"
			shift 2
			;;
		"${3+X${3}}")
			__sx_arg_pad_bind_="${1}" __sx_arg_pad_len_="${2}"
			shift 3
			;;
		"${4+X${4}}")
			__sx_arg_pad_bind_="${1}" __sx_arg_pad_len_="${2}" __sx_arg_pad_val_="${3}"
			shift 4
			;;
		"${5+X${5}}")
			__sx_arg_pad_bind_="${1}" __sx_arg_pad_len_="${2}" __sx_arg_pad_val_="${3}" __sx_arg_pad_flg_="${4}"
			shift 5
			;;
		*)
			__sx_arg_pad_bind_="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	set -- "${__sx_arg_pad_bind_-}" "${__sx_arg_pad_len_:-0}" "${__sx_arg_pad_val_-}" "${__sx_arg_pad_flg_:-0}" "${@}"
	unset  __sx_arg_pad_bind_ __sx_arg_pad_len_ __sx_arg_pad_val_ __sx_arg_pad_flg_

	__sx_var_bind_init "${1}"

	case "$((${4} & SX_ARG_PAD_CB))" in
		0) __sx_arg_pad_lit "${@}";;
		*) __sx_arg_pad_cb "${@}";;
	esac || return
}

### __sx_arg_pad_cb - 引数リストをコールバックでパディングする（内部用）
##
## 使い方:
##   __sx_arg_pad_cb スキーマ 長さ コールバック フラグ [値 ...]
##
## 説明:
##   sx_arg_pad のコールバックモード実装。パディング値の代わりに
##   コールバック関数を呼び出し、その戻り値をパディング値として使用する。
##   コールバック契約: cb ret_var idx cnt skip
##    cnt は 1-based。
##
##   コールバックが ret_var を unset した場合、そのスロットはスキップされる。
##   コールバックが非0を返した場合、処理を中断する。
##
##   状態レイアウト（位置パラメータ）:
##     $1: idx, $2: cnt, $3: skip, $4: needed, $5: bind, $6: len, $7: cb, $8: flag
##     $9+: 元の値
__sx_arg_pad_cb() {
	set -- 1 1 0 "$((${2#-} - ${#} + 4))" "${@}"

	# 左パディング
	case "$((${6} < 0))" in 1)
		while M_NUM_LE([|${2}|], [|${4}|]) && M_STR_NE([|"${5}"|], [|''|]); do
			"${7}" __sx_arg_pad_cb_ret_ "${1}" "${2}" "${3}" || {
				__sx_arg_pad_cb_ex_="${?}"
				break
			}

			case "${__sx_arg_pad_cb_ret_+X}" in
				X)
					__sx_var_bind __sx_arg_pad_cb_bind_ "${5}" "${__sx_arg_pad_cb_ret_}" "${SX_VAR_BIND_QUOTE}"
					eval 'shift 5;' set -- "$((${1} + 1))" "$((${2} + 1))" "${3}" "${4}" "${__sx_arg_pad_cb_bind_}" '"${@}"'
					;;
				*) eval 'shift 3;' set -- "${1}" "$((${2} + 1))" "$((${3} + 1))" '"${@}"';;
			esac

			unset __sx_arg_pad_cb_ret_ __sx_arg_pad_cb_bind_
		done
	esac

	# idx は左パディングで消費済み。残り8フィールドを-8カウンタでスキップ
	shift 1
	set -- -8 "${@}"

	for __sx_arg_pad_cb_arg_ in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		__sx_var_bind __sx_arg_pad_cb_bind_ "${5}" "${__sx_arg_pad_cb_arg_}" "${SX_VAR_BIND_QUOTE}" || break
		eval 'shift 5;' set -- "${1}" "${2}" "${3}" "${4}" "${__sx_arg_pad_cb_bind_}" '"${@}"'
	done

	unset __sx_arg_pad_cb_arg_ __sx_arg_pad_cb_bind_

	eval 'shift;' set -- "$((${1} + 1))" '"${@}"'

	case "$((${6} < 0))" in 0)
		while M_NUM_LE([|${2}|], [|${4}|]) && M_STR_NE([|"${5}"|], [|''|]); do
			"${7}" __sx_arg_pad_cb_ret_ "${1}" "${2}" "${3}" || {
				__sx_arg_pad_cb_ex_="${?}"
				break
			}

			case "${__sx_arg_pad_cb_ret_+X}" in
				X)
					__sx_var_bind __sx_arg_pad_cb_bind_ "${5}" "${__sx_arg_pad_cb_ret_}" "${SX_VAR_BIND_QUOTE}"
					eval 'shift 5;' set -- "$((${1} + 1))" "$((${2} + 1))" "${3}" "${4}" "${__sx_arg_pad_cb_bind_}" '"${@}"'
					;;
				*) eval 'shift 3;' set -- "${1}" "$((${2} + 1))" "$((${3} + 1))" '"${@}"';;
			esac

			unset __sx_arg_pad_cb_ret_ __sx_arg_pad_cb_bind_
		done
	esac

	set -- "${__sx_arg_pad_cb_ex_-0}"
	unset __sx_arg_pad_cb_ex_ __sx_arg_pad_cb_ret_
	return "${1}"
}

define([|V|], [|__sx_arg_pad_lit_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(len) V(val) V(needed) V(arg) __M_BIND_USEVAR|])dnl
### __sx_arg_pad_lit - 引数リストをパディングする（内部用）
##
## 使い方:
##   __sx_arg_pad_lit スキーマ 長さ パディング値 [値 ...]
##
## 説明:
##   sx_arg_pad の内部実装。引数チェックは行わない。
__sx_arg_pad_lit() {
	__sx_arg_pad_lit_bind_="${1}"
	__sx_arg_pad_lit_len_="${2}"
	__sx_arg_pad_lit_val_="${3}"
	__sx_arg_pad_lit_out_=
	shift 4

	__sx_arg_pad_lit_needed_=$((${__sx_arg_pad_lit_len_#-} - ${#}))

	# 左パディング（needed <= 0 なら何もしない）
	case "${__sx_arg_pad_lit_len_}" in -*)
		while M_NUM_LT([|0|], [|__sx_arg_pad_lit_needed_|]); do
			__M_BIND_QUOTE([|__sx_arg_pad_lit|], [|"${__sx_arg_pad_lit_val_}"|], CLEANUP)

			: $((__sx_arg_pad_lit_needed_ -= 1))
		done
	esac

	# 入力値を結合
	for __sx_arg_pad_lit_arg_ in "${@}"; do
		__M_BIND_QUOTE([|__sx_arg_pad_lit|], [|"${__sx_arg_pad_lit_arg_}"|], CLEANUP)
	done

	# 右パディング（needed <= 0 なら何もしない）
	case "${__sx_arg_pad_lit_len_}" in [!-]*)
		while M_NUM_LT([|0|], [|__sx_arg_pad_lit_needed_|]); do
			__M_BIND_QUOTE([|__sx_arg_pad_lit|], [|"${__sx_arg_pad_lit_val_}"|], CLEANUP)

			: $((__sx_arg_pad_lit_needed_ -= 1))
		done
	esac

	eval ${__sx_arg_pad_lit_out_:+"${__sx_arg_pad_lit_bind_}=\"\${__sx_arg_pad_lit_out_}\""}
	unset CLEANUP
}

### sx_arg_resize - 引数リストを指定された形状にリサイズする
##
## 使い方:
##   sx_arg_resize [bind [shape [pad_val [flag]]]] ::: [arg ...]
##   sx_arg_resize [bind] [arg ...]
##
## 説明:
##   与えられた引数リスト [arg ...] を、指定された shape の総要素数に
##   リサイズする。要素が不足している場合は pad_val で埋め、
##   超過している場合は切り詰める。
##
##   shape は ":" 区切りの多次元形式で指定する。
##     2:3   → 2行×3列 = 6要素
##     2:3:4 → 2行×3列×4層 = 24要素
##   いずれかの軸に -1 を指定すると、その軸のサイズを
##   切り上げ ceil(要素数 / 既知の軸の積) で自動計算する。
##   ただし -1 は1つまで。
##
##   flag には以下のビットマスクを指定できる（省略時は 0）:
##     SX_ARG_RESIZE_PAD_LEFT (2) — 不足要素を左側に詰める
##
##   2 つの呼び出し形式がある:
##     1) ::: 形式: bind/shape/val/flag を ::: より前の位置引数で指定し、
##        ::: 以降をデータとして扱う。設定引数とデータを明確に分離できる。
##     2) 簡略形式: bind のみを第一引数で指定し、第二引数以降はすべてデータ
##        として扱われる。この形式では shape は空になり、
##        リサイズは行われず単にクォートのみ行う。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE) - shape の形式が不正
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_resize() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_resize "${@}" || return; return 0;; esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*) __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable ${1+"${1}"} || return
	esac

	__sx_arg_resize_shape=
	case "X${SX_CFG_SEP}" in
		"${3+X${3}}" | "${4+X${4}}") __sx_arg_resize_shape="${2}";;
		"${5+X${5}}")
			__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 "${4:-}" || return
			__sx_arg_resize_shape="${2}"
			;;
	esac

	case "${__sx_arg_resize_shape}" in *::* | *-[02-9]* | *[!:0-9-]* | *-1*-1* | :* | *: | *-1[!:]*)
		unset __sx_arg_resize_shape
		return "${SX_EX_USAGE}"
	esac

	unset __sx_arg_resize_shape

	__sx_arg_resize "${@}"
}

### __sx_arg_resize - 引数リストをリサイズする（内部用）
##
## 使い方:
##   __sx_arg_resize 結果変数名 [形状 [パディング値]] ::: [値 ...]
##
## 説明:
##   ::: セパレータをパースし、形状を解析してリサイズを実行する。
##   引数チェックは行わない。
##   形状が空または1次元（":"なし）の場合はフラット出力、
##   2次元以上の場合は階層出力を行う。
__sx_arg_resize() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			__sx_arg_resize_bind_="${1}"
			shift 2
			;;
		"${3+X${3}}")
			__sx_arg_resize_bind_="${1}" __sx_arg_resize_shape_="${2}"
			shift 3
			;;
		"${4+X${4}}")
			__sx_arg_resize_bind_="${1}" __sx_arg_resize_shape_="${2}" __sx_arg_resize_val_="${3}"
			shift 4
			;;
		"${5+X${5}}")
			__sx_arg_resize_bind_="${1}" __sx_arg_resize_shape_="${2}" __sx_arg_resize_val_="${3}" __sx_arg_resize_flg_="${4}"
			shift 5
			;;
		*)
			__sx_arg_resize_bind_="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	: "${__sx_arg_resize_bind_=}" "${__sx_arg_resize_shape_:=${#}}" "${__sx_arg_resize_val_=}" "${__sx_arg_resize_flg_:=0}"

	__sx_var_bind_init "${__sx_arg_resize_bind_}"
	SX_CFG_UNSET_SOFT=2 __sx_str_sub __sx_arg_resize_shape_ "${__sx_arg_resize_shape_}" : '*'
	SX_CFG_UNSET_SOFT=2 __sx_str_sub __sx_arg_resize_tmp_ "${__sx_arg_resize_shape_}" -1 1
	__sx_arg_resize_total_=$((${__sx_arg_resize_tmp_}))

	# 形状解析
	case "${__sx_arg_resize_shape_}" in *-1*)
		__sx_arg_resize_inferred_=$((__sx_arg_resize_total_ == 0 ? 0 : (${#} + __sx_arg_resize_total_ - 1) / __sx_arg_resize_total_))

		__sx_arg_resize_total_=$((__sx_arg_resize_total_ * __sx_arg_resize_inferred_))
		SX_CFG_UNSET_SOFT=2 __sx_str_sub __sx_arg_resize_shape_ "${__sx_arg_resize_shape_}" -1 "${__sx_arg_resize_inferred_}"
	esac

	SX_CFG_UNSET_SOFT=2 __sx_arg_pad __sx_arg_resize_padded_ "$((__sx_arg_resize_total_ * (${__sx_arg_resize_flg_} & SX_ARG_RESIZE_PAD_LEFT ? -1 : 1)))" "${__sx_arg_resize_val_}" ::: "${@}"

	eval set -- "${__sx_arg_resize_padded_}"

	# Phase 1-N: grouping (最内→最外)
	while M_STR_HAS([|"${__sx_arg_resize_shape_}"|], [|'*'|]); do
		__sx_arg_resize_dim_="${__sx_arg_resize_shape_##*'*'}"
		__sx_arg_resize_shape_="${__sx_arg_resize_shape_%'*'*}"
		__sx_arg_resize_cnt_=$((${__sx_arg_resize_shape_}))
		__sx_arg_resize_out_=

		while M_NUM_LT([|0|], [|__sx_arg_resize_cnt_|]); do
			case ${__sx_arg_resize_dim_} in
				[!0]*) __sx_arg_quote "${__sx_arg_resize_dim_}__sx_arg_resize_group_:" "${@}";;
				*) __sx_arg_resize_group_=;;
			esac

			__sx_arg_quote __sx_arg_resize_group_ "${__sx_arg_resize_group_}"
			__sx_arg_resize_out_="${__sx_arg_resize_out_} ${__sx_arg_resize_group_}"

			shift "${__sx_arg_resize_dim_}"
			: $((__sx_arg_resize_cnt_ -= 1))
		done

		eval set -- "${__sx_arg_resize_out_}"
	done

	for __sx_arg_resize_arg_ in "${@}"; do
		case "$((0 < __sx_arg_resize_shape_))" in 0)
			break
		esac

		__sx_var_bind __sx_arg_resize_bind_ "${__sx_arg_resize_bind_}" "${__sx_arg_resize_arg_}" "${SX_VAR_BIND_QUOTE}" || break
		: $((__sx_arg_resize_shape_ -= 1))
	done

	# クリーンアップ
	unset __sx_arg_resize_padded_ __sx_arg_resize_bind_ __sx_arg_resize_shape_ __sx_arg_resize_val_ __sx_arg_resize_inferred_ __sx_arg_resize_total_ __sx_arg_resize_out_ __sx_arg_resize_arg_ __sx_arg_resize_tmp_ __sx_arg_resize_cnt_ __sx_arg_resize_dim_ __sx_arg_resize_group_ __sx_arg_resize_flg_
}

### sx_arg_range - 位置パラメータの参照文字列を生成する
##
## 使い方:
##   sx_arg_range 宛先 終了
##   sx_arg_range 宛先 開始 終了
##   sx_arg_range 宛先 開始 終了 増分
##
## 説明:
##   指定された範囲のインデックスに対応する位置パラメータの参照文字列
##   （例: '"${1}" "${2}"'）を生成し、宛先変数に格納する。
##   引数の仕様は sx_num_range と同一（Python の range 互換）だが、
##   すべての数値引数は 0 以上の整数 (nat0) である必要がある。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  宛先変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_range "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 "${2-}" ${3+"${3}"} ${4+"${4}"} || return

	case "${4-1}" in 0)
		return "${SX_EX_USAGE}"
	esac

	__sx_arg_range "${@}"
}

### __sx_arg_range - 位置パラメータの参照文字列を指定範囲で生成する（内部用）
##
## 使い方:
##   __sx_arg_range 宛先変数名 [開始 [終了 [ステップ]]]
##
## 説明:
##   指定された範囲のインデックスに対応する位置パラメータの参照文字列を生成し、
##   宛先変数に格納する。バリデーションは行わない。
__sx_arg_range() {
	__sx_arg_range_res_="${1}"
	shift
	SX_CFG_UNSET_SOFT=2 __sx_num_range __sx_arg_range_idxs_ "${@}"

	case "${__sx_arg_range_idxs_}" in
		'') __sx_var_set "${__sx_arg_range_res_}=";;
		*)
			SX_CFG_UNSET_SOFT=2 __sx_str_sub __sx_arg_range_tmp_ "${__sx_arg_range_idxs_}" ' ' '}" "${'
			__sx_var_set "${__sx_arg_range_res_}=\"\${${__sx_arg_range_tmp_}}\""
			;;
	esac

	unset __sx_arg_range_res_ __sx_arg_range_idxs_ __sx_arg_range_tmp_
}

### sx_arg_rfind - 引数リストから指定された値を末尾から探し、そのインデックスまたは値を取得する
##
## 使い方:
##   sx_arg_rfind [結果変数名 [検索対象 [フラグ]]] ::: [値 ...]
##   sx_arg_rfind 結果変数名 [値 ...]
##
## 説明:
##   sx_arg_find と同じだが、末尾から前方向に検索する。
##   一致した項目のインデックスを発見順（末尾から）にスペース区切りで結果変数に格納する。
##   フラグに SX_ARG_RFIND_TEXT (4) を指定すると、インデックスの代わりにマッチした値を出力する。
##   フラグに SX_ARG_RFIND_CB (2) を指定すると、検索対象をコールバック関数として扱う。
##   コールバックシグネチャ: callback value index count
##     0 を返すと一致、非0 は不一致としてスキップ。
##   取得件数はバインド形式によって決まる。
##   呼び出し形式は sx_arg_find に準ずる。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった (不一致)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_rfind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rfind "${@}" || return; return 0;; esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*) __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable ${1+"${1}"} || return
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 "${3}" || return

			case "$(((${3} & SX_ARG_RFIND_GLOB) * (${3} & SX_ARG_RFIND_CB)))" in [!0])
				return "${SX_EX_USAGE}"
			esac
			;;
	esac

	__sx_arg_rfind "${@}" || return
}

### __sx_arg_rfind - 引数リストから指定された値を後ろ向きに探す（内部用: ディスパッチャ）
##
## 使い方:
##   __sx_arg_rfind 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   ::: セパレータをパースし、フラグに応じて __sx_arg_rfind_lit または
##   __sx_arg_rfind_cb にディスパッチする。
##   引数チェックは行わない。
__sx_arg_rfind() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			__sx_arg_rfind_bind_="${1}"
			shift 2;;
		"${3+X${3}}")
			__sx_arg_rfind_bind_="${1}" __sx_arg_rfind_tgt_="${2}"
			shift 3
			;;
		"${4+X${4}}")
			__sx_arg_rfind_bind_="${1}" __sx_arg_rfind_tgt_="${2}" __sx_arg_rfind_flg_="${3}"
			shift 4
			;;
		*)
			__sx_arg_rfind_bind_="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	set -- "${__sx_arg_rfind_bind_-}" "${__sx_arg_rfind_tgt_-}" "${__sx_arg_rfind_flg_:-0}" "${@}"
	unset __sx_arg_rfind_bind_ __sx_arg_rfind_tgt_ __sx_arg_rfind_flg_

	__sx_var_bind_init "${1}"

	case "$((${3} & SX_ARG_RFIND_CB))" in
		0) __sx_arg_rfind_lit "${@}";;
		*) __sx_arg_rfind_cb "${@}";;
	esac || return
}

### __sx_arg_rfind_cb - 引数リストから指定された値をコールバックで検索する（内部用）
##
## 使い方:
##   __sx_arg_rfind_cb 結果変数名 コールバック フラグ [値 ...]
##
## 説明:
##    __sx_arg_rfind から呼ばれる。末尾から先頭に向かって検索し、
##    コールバックの終了ステータスで一致を判定する。
##    コールバックシグネチャ: callback value index count
##      0 を返すと一致、非0 は不一致としてスキップ。
##    引数は正規化済み。引数チェックは行わない。
##    状態は位置変数で管理し、__sx_var_bind でバインドする。
__sx_arg_rfind_cb() {
	# 初期状態を設定
	# $1: 現在のインデックス i (最初は値の個数)
	# $2: 一致件数 match (最初は 0)
	# $3: 現在のバインド状態 bind (最初は元の $1 = 結果変数名)
	# $4: コールバック cb (元の $2)
	# $5: テキストフラグ txt (元の $3 から計算)
	# $6以降: 元の引数リスト (結果変数名 コールバック フラグ [値 ...])
	set -- "$((${#} - 3))" 0 "${1}" "${2}" "$(((${3} & SX_ARG_RFIND_TEXT) != 0))" "${@}"

	while M_NUM_LT([|0|], [|${1}|]) && M_STR_NE([|"${3}"|], [|''|]); do
		# コールバックを実行。一時変数を使わずに、eval で間接参照する。
		if eval '"${4}"' "\"\${$((${1} + 8))}\"" "${1}" "${2}"; then
			case "${5}" in
				0) __sx_var_bind __sx_arg_rfind_cb_bind_ "${3}" "${1}";;
				*) eval __sx_var_bind __sx_arg_rfind_cb_bind_ "${3}" "\"\${$((${1} + 8))}\"" "${SX_VAR_BIND_QUOTE}";;
			esac

			eval 'shift 3;' set -- "$((${1} - 1))" "$((${2} + 1))" '"${__sx_arg_rfind_cb_bind_}"' '"${@}"'
		else
			eval 'shift 1;' set -- "$((${1} - 1))" '"${@}"'
		fi

		unset __sx_arg_rfind_cb_bind_
	done

	return "$((!${2}))"
}

define([|V|], [|__sx_arg_rfind_lit_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(glob) V(text) V(out) V(i) V(arg) V(sts) __M_BIND_USEVAR|])dnl

### __sx_arg_rfind_lit - 引数リストから指定された値を後ろ向きに探す（内部用: リテラル/Glob）
##
## 使い方:
##   __sx_arg_rfind_lit 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   sx_arg_rfind のリテラル/Glob検索実装。末尾から先頭に向かって検索する。
##   引数チェックは行わない。
__sx_arg_rfind_lit() {
	__sx_arg_rfind_lit_bind_="${1}"
	__sx_arg_rfind_lit_glob_=$(((${3} & SX_ARG_RFIND_GLOB) != 0))
	__sx_arg_rfind_lit_text_=$(((${3} & SX_ARG_RFIND_TEXT) != 0))
	__sx_arg_rfind_lit_i_="${#}"
	__sx_arg_rfind_lit_out_=

	while M_NUM_LT([|3|], [|__sx_arg_rfind_lit_i_|]); do
		eval __sx_arg_rfind_lit_arg_=\"\${${__sx_arg_rfind_lit_i_}}\"

		case "${__sx_arg_rfind_lit_glob_}${__sx_arg_rfind_lit_arg_}" in "0${2}" | 1${2})
			case "${__sx_arg_rfind_lit_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_arg_rfind_lit|], [|"$((${__sx_arg_rfind_lit_i_} - 3))"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_arg_rfind_lit|], [|"${__sx_arg_rfind_lit_arg_}"|], CLEANUP);;
			esac

			__sx_arg_rfind_lit_sts_="${SX_EX_OK}"
		esac

		: $((__sx_arg_rfind_lit_i_ -= 1))
	done

	eval ${__sx_arg_rfind_lit_out_:+"${__sx_arg_rfind_lit_bind_}=\"\${__sx_arg_rfind_lit_out_# }\""}

	set -- "${__sx_arg_rfind_lit_sts_-1}"

	unset CLEANUP
	return "${1}"
}

### sx_arg_rfold - 引数リストを右からコールバックで畳み込む（rfold）
##
## 使い方:
##   sx_arg_rfold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   sx_arg_fold と同様に畳み込みを行うが、右端の要素から処理を開始する。
##   コールバック契約: callback ret_var acc current_value index
##     - ret_var: 新しいアキュムレータ値を格納する変数名
##     - acc: 現在のアキュムレータ値
##     - current_value: 現在処理中の要素の値
##     - index: 元の引数リストにおける 1-based インデックス
##   コールバックが ret_var を unset した場合、アキュムレータは変更されない。
##   コールバックが非0を返した場合、その時点のアキュムレータ値を結果変数に格納し、
##   直ちに終了する。
##
## 終了ステータス:
##   すべてのコールバックが成功 => 0 (SX_EX_OK)
##   コールバックが失敗 => 最初のエラーのステータス
##   64 => 引数不正 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_rfold() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rfold "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_arg_rfold "${@}" || return
}

### __sx_arg_rfold - 引数リストを右からコールバックで畳み込む（内部用）
##
## 使い方:
##   __sx_arg_rfold 結果変数 コールバック 初期値 [値 ...]
##
## 説明:
##   sx_arg_rfold の内部実装。引数チェックは行わない。
##   状態（cnt, res, cb, acc）は位置変数で管理し、eval で後方から間接参照する。
##   各イテレーション後は shift 4 で状態を退避し、set -- ... "${@}" で
##   データを保持したまま状態だけを更新する。これにより再帰呼び出しにも安全。
##
__sx_arg_rfold() {
	set -- "$((${#} - 3))" "${@}"

	while M_NUM_LT([|0|], [|${1}|]); do
		eval '"${3}"' __sx_arg_rfold_ret_ '"${4}"' "\"\${$((${1} + 4))}\"" "${1}" || {
			set -- "${?}" "${@}"
			__sx_var_set "${3}=${5}"
			unset __sx_arg_rfold_ret_
			return "${1}"
		}

		__sx_arg_rfold_cb_="${3}"
		: "${__sx_arg_rfold_ret_=${4}}"

		eval 'shift 4;' set -- "$((${1} - 1))" "${2}" '"${__sx_arg_rfold_cb_}"' '"${__sx_arg_rfold_ret_}"' '"${@}"'

		unset __sx_arg_rfold_ret_ __sx_arg_rfold_cb_
	done

	__sx_var_set "${2}=${4}"
}

### __sx_arg_norm - 引数リスト内の数値をプレースホルダに展開して正規化する（内部用）
##
## 使い方:
##   __sx_arg_norm 結果変数名 プレースホルダ [引数...]
##
## 説明:
##   引数リストを走査し、数値 N があればそれを N 個のプレースホルダに展開する。
##   数値以外の文字列はそのまま残す。
__sx_arg_norm() {
	__sx_arg_norm_res_="${1}"
	sx_arg_quote __sx_arg_norm_pl_ "${2-}"
	shift ${2+2}

	__sx_arg_norm_out_=
	for __sx_arg_norm_arg_ in "${@}"; do
		if sx_num_is_nat0 "${__sx_arg_norm_arg_}"; then
			# 数値 N を N 個のプレースホルダに展開
			SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_arg_norm_tmp_ " ${__sx_arg_norm_pl_}" "${__sx_arg_norm_arg_}"
			__sx_arg_norm_out_="${__sx_arg_norm_out_}${__sx_arg_norm_tmp_}"
		else
			sx_arg_quote __sx_arg_norm_tmp_ "${__sx_arg_norm_arg_}"
			__sx_arg_norm_out_="${__sx_arg_norm_out_} ${__sx_arg_norm_tmp_}"
		fi
	done

	# 先頭の余計なスペースを削って結果変数に格納
	__sx_var_set "${__sx_arg_norm_res_}=${__sx_arg_norm_out_# }"

	unset __sx_arg_norm_res_ __sx_arg_norm_pl_ __sx_arg_norm_out_ __sx_arg_norm_arg_ __sx_arg_norm_tmp_
}

### sx_arg_rquote - 引数を逆順にシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arg_rquote 結果変数名（またはバインド形式） [値 ...]
##
## 説明:
##   指定された値をそれぞれシングルクォートで囲み、
##   逆順（最後の引数が先頭）にスペース区切りで結合した文字列を作成して結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_rquote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rquote "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return

	__sx_arg_rquote "${@}"
}

define([|V|], [|__sx_arg_rquote_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(i) V(val) __M_BIND_USEVAR|])dnl

### __sx_arg_rquote - 引数を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_rquote スキーマ [値 ...]
##
## 説明:
##   引数チェックを行わずに逆順分配代入およびクォート結合処理を行う。
__sx_arg_rquote() {
	__sx_var_bind_init "${1}"
	__sx_arg_rquote_bind_="${1}"
	__sx_arg_rquote_out_=
	shift
	__sx_arg_rquote_i_="${#}"

	while M_NUM_LT([|0|], [|__sx_arg_rquote_i_|]); do
		eval "__sx_arg_rquote_val_=\"\${${__sx_arg_rquote_i_}}\""

		__M_BIND_QUOTE([|__sx_arg_rquote|], [|"${__sx_arg_rquote_val_}"|], CLEANUP)

		: $((__sx_arg_rquote_i_ -= 1))
	done

	eval ${__sx_arg_rquote_out_:+"${__sx_arg_rquote_bind_}=\"\${__sx_arg_rquote_out_}\""}
	unset CLEANUP
}

# ========================================
#  VAR (Variable)
# ========================================

### sx_var_bind_init - バインド形式に基づき変数を初期化する
##
## 使い方:
##   sx_var_bind_init [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   指定されたバインド形式に従って、変数を初期化する。
##   最後のコロン（:）より前の変数は関連要素を含めて削除（unset）され、
##   最後の変数は空文字列（""）で初期化される。
##   これにより、前の変数が「省略された」ことを sx_var_is_set で判定できる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  バインド形式が不正 (SX_EX_USAGE)
##   77  書き込み不可な変数が含まれる (SX_EX_NOPERM)
sx_var_bind_init() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_bind_init "${@}" || return; return 0;; esac

	__sx_ex_remap "64:${SX_EX_USAGE}" "1:${SX_EX_NOPERM}" sx_var_is_bindable "${@}" || return

	__sx_var_bind_init "${@}"
}

### __sx_var_bind_init - バインド形式に基づき変数を初期化する（内部用）
##
## 使い方:
##   __sx_var_bind_init [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   sx_var_bind_init の内部実装。
##   引数チェックは行わない。
__sx_var_bind_init() {
	for __sx_var_bind_init_arg_ in "${@}"; do
		__sx_var_bind_init_ls_=

		while
			__sx_var_bind_init_seg_="${__sx_var_bind_init_arg_%%:*}"
			__sx_var_bind_init_ls_="${__sx_var_bind_init_ls_} ${__sx_var_bind_init_seg_#"${__sx_var_bind_init_seg_%%[!0-9]*}"}"
			M_STR_HAS([|"${__sx_var_bind_init_arg_}"|], [|:|])
		do
			__sx_var_bind_init_arg_="${__sx_var_bind_init_arg_#*:}"
		done

		eval __sx_var_unset "${__sx_var_bind_init_ls_}"

		case "${__sx_var_bind_init_arg_}" in ?*)
			eval "${__sx_var_bind_init_arg_}="
		esac
	done

	unset __sx_var_bind_init_arg_ __sx_var_bind_init_ls_ __sx_var_bind_init_seg_
}

### sx_var_bind - バインド状態に従って値を割り当てる
##
## 使い方:
##   sx_var_bind 結果変数名 バインド形式 値 [フラグ]
##
## 説明:
##   バインド形式（a:b:c 等）を解析し、値を適切な変数に割り当てる。
##   割り当て後、残りのバインド形式が結果変数に格納される。
##   フラグに SX_VAR_BIND_QUOTE (1) を指定すると、リスト蓄積時に値をクオートする。
##
## 終了ステータス:
##    0  割り当て成功 (SX_EX_OK)
##    1  バインド先がもうない（バインド形式が空）
##   64  引数不正 (SX_EX_USAGE)
##   77  変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_bind "${@}" || return; return 0;; esac

	# 結果変数名自体の妥当性と書き込み権限をチェック
	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${2-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 ${4+"${4}"} || return

	__sx_var_bind "${@}"
}

### __sx_var_bind - バインド状態に従って値を割り当てる（内部用）
##
## 使い方:
##   __sx_var_bind 結果変数名 バインド形式 値 [フラグ]
##
## 説明:
##   バインド形式（a:b:c 等）を解析し、値を適切な変数に割り当てる。
##   割り当て後、残りのバインド形式が結果変数に格納される。
##   フラグに SX_VAR_BIND_QUOTE (1) を指定すると、リスト蓄積時に値をクオートする。
##
## 終了ステータス:
##    0  割り当て成功
##    1  バインド先がもうない（バインド形式が空）
__sx_var_bind() {
	set -- "${1}" "${2-}" "${3-}" "${4:-0}"

	case "${2}" in '') return 1;; esac

	__sx_var_bind_seg_="${2%%:*}"

	case "${__sx_var_bind_seg_}" in *["${SX_STR_ALPHA}_"]*)
		__sx_var_bind_v_="${3}"

		case "$((${4} & SX_VAR_BIND_QUOTE))" in [!0]*)
			case "${3}" in
				*"'"*) SX_CFG_UNSET_SOFT=2 __sx_str_sub __sx_var_bind_v_ "${3}" "'" "'\\''";;
				*) __sx_var_bind_v_="${3}";;
			esac

			__sx_var_bind_v_="'${__sx_var_bind_v_}'"
		esac
	esac

	case "${2}" in
		:*) eval "${1}=\"\${2#*:}\"";;
		[1-9]*:*)
			__sx_var_bind_c_="${2%%[!0-9]*}"
			__sx_var_bind_n_="${__sx_var_bind_seg_#${__sx_var_bind_c_}}"

			case "${__sx_var_bind_n_}" in ?*)
				eval "${__sx_var_bind_n_}=\"\${${__sx_var_bind_n_}-}\${${__sx_var_bind_n_}+ }\${__sx_var_bind_v_}\""
			esac

			case "${__sx_var_bind_c_}" in
				1) eval "${1}=\"\${2#*:}\"";;
				*) eval "${1}=\"$((${__sx_var_bind_c_} - 1))${__sx_var_bind_n_}:\${2#*:}\"";;
			esac
			;;
		*:*) eval "${2%%:*}=\${3}; ${1}=\"\${2#*:}\"";;
		*) eval "${2}=\"\${${2}}\${${2}:+ }\${__sx_var_bind_v_}\"; ${1}=\"\${2}\"";;
	esac

	unset __sx_var_bind_seg_ __sx_var_bind_v_ __sx_var_bind_c_ __sx_var_bind_n_
}

### sx_var_copy - 変数の値を連鎖コピーする
##
## 使い方:
##   sx_var_copy [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   指定された連鎖式に従って、変数の値をコピーする。
##   連鎖式には以下の形式が使用できる：
##     A-B-C : 左から右へコピー (A -> B -> C)
##     A=B=C : 右から左へコピー (A <- B <- C)
##   例: v1-v2-v3 の場合、v1 の値を v2 に、v2 の元の値を v3 にコピーする。
##   複数の連鎖式が指定された場合は、順次実行される。
##   引数が単一の変数名の場合は、何もせず成功する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  コピー先または関連要素が読み取り専用 (SX_EX_NOPERM)
sx_var_copy() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_copy "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_copyable "${@}" || return

	__sx_var_copy "${@}"
}

### __sx_var_copy - 変数の値を連鎖コピーする（内部用）
##
## 使い方:
##   __sx_var_copy [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_copy の内部実装。
##   引数チェックは行わない。
__sx_var_copy() {
	SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_var_copy_esc_ "${@}"
	SX_CFG_UNSET_SOFT=2 __sx_var_list_copy __sx_var_copy_ls_ "${@}"
	eval set -- "${__sx_var_copy_ls_}"

	# 1. 値のキャプチャと代入式の生成
	__sx_var_copy_asg_=

	for __sx_var_copy_pair_ in "${@}"; do
		__sx_var_copy_dst_="${__sx_var_copy_pair_%%=*}"
		__sx_var_copy_src_="${__sx_var_copy_pair_#*=}"

		if sx_var_is_set "${__sx_var_copy_src_}"; then
			eval SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_var_copy_val_ "\"\${${__sx_var_copy_src_}}\""
			__sx_var_copy_asg_="${__sx_var_copy_asg_} ${__sx_var_copy_dst_}=${__sx_var_copy_val_};"
		else
			__sx_var_copy_asg_="${__sx_var_copy_asg_} unset ${__sx_var_copy_dst_};"
		fi
	done

	# 2. コピー先を削除
	eval set -- "${__sx_var_copy_esc_}"
	for __sx_var_copy_arg_ in "${@}"; do
		case "${__sx_var_copy_arg_}" in
			*=*)
				sx_str_sub __sx_var_copy_dsts_ "${__sx_var_copy_arg_%=*}" = ' '
				eval __sx_var_unset "${__sx_var_copy_dsts_}"
				;;
			*-*)
				sx_str_sub __sx_var_copy_dsts_ "${__sx_var_copy_arg_#*-}" - ' '
				eval __sx_var_unset "${__sx_var_copy_dsts_}"
				;;
		esac
	done

	# 3. 代入の実行
	eval "${__sx_var_copy_asg_}"

	# 内部用変数を掃除
	unset __sx_var_copy_esc_ __sx_var_copy_ls_ __sx_var_copy_asg_ __sx_var_copy_pair_ __sx_var_copy_dst_ __sx_var_copy_src_ __sx_var_copy_val_ __sx_var_copy_dsts_ __sx_var_copy_arg_
}

### sx_var_dump - 変数や配列の状態を文字列として取得する
##
## 使い方:
##   sx_var_dump 結果変数名 [名前1 ...]
##
## 説明:
##   指定された変数（または配列）の現在の状態を、代入式（name='value'）の
##   形式で取得し、結果変数に格納する。配列の場合は関連する全要素を含む。
##   変数が設定されていない場合は 'unset name' の形式となる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_dump() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_dump "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_rw_all "${1}" || return "${SX_EX_NOPERM}"

	__sx_var_dump "${@}"
}

### __sx_var_dump - 変数や配列の状態を文字列として取得する（内部用）
##
## 使い方:
##   __sx_var_dump 結果変数名 [名前1 ...]
##
## 説明:
##   sx_var_dump の内部実装。
##   引数チェックは行わない。
__sx_var_dump() {
	__sx_var_dump_res_="${1}"
	__sx_var_dump_out_=
	shift

	SX_CFG_UNSET_SOFT=2 __sx_var_list_dep __sx_var_dump_ls_ "${@}"
	eval set -- "${__sx_var_dump_ls_}"

	for __sx_var_dump_vn_ in "${@}"; do
		if sx_var_is_set "${__sx_var_dump_vn_}"; then
			eval SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_var_dump_val_ "\"\${${__sx_var_dump_vn_}}\""
			__sx_var_dump_out_="${__sx_var_dump_out_}${__sx_var_dump_vn_}=${__sx_var_dump_val_}${SX_STR_LF}"
		else
			__sx_var_dump_out_="${__sx_var_dump_out_}unset ${__sx_var_dump_vn_}${SX_STR_LF}"
		fi
	done

	__sx_var_set "${__sx_var_dump_res_}=${__sx_var_dump_out_}"

	unset __sx_var_dump_res_ __sx_var_dump_out_ __sx_var_dump_ls_ __sx_var_dump_vn_ __sx_var_dump_val_
}

### sx_var_is_arr - 指定された変数がsx配列であるか確認する
##
## 使い方:
##   sx_var_is_arr 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべてsx配列である (SX_EX_OK)
##    1  sx配列ではない変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_arr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_arr "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"

	__sx_var_is_arr "${@}" || return
}

### __sx_var_is_arr - 指定された変数がsx配列であるか確認する（内部用）
##
## 使い方:
##   __sx_var_is_arr [変数名1 ...]
##
## 説明:
##   変数の値（シグネチャ）と長さ変数の妥当性をチェックする。
##   引数チェックは行わない。
__sx_var_is_arr() {
	for __sx_var_is_arr_arg_ in "${@}"; do
		if
			! eval sx_str_sw "\"\${${__sx_var_is_arr_arg_}-}\"" '"${SX_CFG_SIG_ARR}":' ||
			! eval __sx_num_is_base_nat0 10 "\"\${${__sx_var_is_arr_arg_}_len-}\""
		then
			unset __sx_var_is_arr_arg_
			return 1
		fi
	done

	unset __sx_var_is_arr_arg_
}

### sx_var_is_bind - 文字列が分配代入バインド形式として有効か確認する
##
## 使い方:
##   sx_var_is_bind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、分配代入バインド形式（var1:var2::var3 等）
##   として有効な形式であるかを確認する。
##   各要素は有効な変数名、またはスキップを意味する空文字列である必要がある。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
sx_var_is_bind() {
	for __sx_var_is_bind_arg in "${@}"; do
		case "${__sx_var_is_bind_arg}" in
			*[!"${SX_STR_WORD}":]* | 0* | *:0*)
				unset __sx_var_is_bind_arg
				return 1
				;;
		esac

		case "${__sx_var_is_bind_arg##*:}" in [0-9]*)
			unset __sx_var_is_bind_arg
			return 1
		esac
	done

	unset __sx_var_is_bind_arg
}

### sx_var_is_bindable - バインド形式が有効であり、かつ全変数が書き込み可能か確認する
##
## 使い方:
##   sx_var_is_bindable [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   指定されたバインド形式が妥当な名前で構成されており、かつ含まれるすべての変数が
##   書き込み可能（読み取り専用でない）であることを確認する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる (SX_EX_NOPERM)
##   64  バインド形式が不正 (SX_EX_USAGE)
sx_var_is_bindable() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_bindable "${@}" || return; return 0;; esac

	sx_var_is_bind "${@}" || return "${SX_EX_USAGE}"

	__sx_var_is_bindable "${@}"
}

### __sx_var_is_bindable - バインド形式に含まれる変数が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_bindable バインド形式
##
## 説明:
##   コロン区切りのバインド形式を解析し、含まれるすべての変数名に対して
##   一括で書き込み権限を確認する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる
__sx_var_is_bindable() {
	__sx_var_is_bindable_chk_=

	for __sx_var_is_bindable_arg_ in "${@}"; do
		while
			__sx_var_is_bindable_seg_="${__sx_var_is_bindable_arg_%%:*}"
			__sx_var_is_bindable_chk_="${__sx_var_is_bindable_chk_} ${__sx_var_is_bindable_seg_#"${__sx_var_is_bindable_seg_%%[!0-9]*}"}"
			M_STR_HAS([|"${__sx_var_is_bindable_arg_}"|], [|:|])
		do
			__sx_var_is_bindable_arg_="${__sx_var_is_bindable_arg_#*:}"
		done
	done

	eval "set -- ${__sx_var_is_bindable_chk_}"
	unset __sx_var_is_bindable_chk_ __sx_var_is_bindable_arg_ __sx_var_is_bindable_seg_

	__sx_var_is_rw_all "${@}" || return
}

### sx_var_is_chain - 文字列が有効な連鎖式であるか確認する
##
## 使い方:
##   sx_var_is_chain [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、sx_var_copy 等で使用可能な
##   有効な連鎖式（A-B-C または A=B=C）であるか、あるいは単一の有効な変数名
##   であるかを確認する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
sx_var_is_chain() {
	for __sx_var_is_chain_arg in "${@}"; do
		case "${__sx_var_is_chain_arg}" in
			*=*) ! M_STR_MATCH([|"${__sx_var_is_chain_arg}"|], [|*[!"${SX_STR_WORD}"=]*|], [|*==*|], [|=*|], [|*=|], [|[0-9]*|], [|*=[0-9]*|]);;
			*-*) ! M_STR_MATCH([|"${__sx_var_is_chain_arg}"|], [|*[!"${SX_STR_WORD}"-]*|], [|*--*|], [|-*|], [|*-|], [|[0-9]*|], [|*-[0-9]*|]);;
			*) sx_var_is_name "${__sx_var_is_chain_arg}";;
		esac || {
			unset __sx_var_is_chain_arg
			return 1
		}
	done

	unset __sx_var_is_chain_arg
}

### sx_var_is_copyable - コピー先が構造を含めて書き込み可能か確認する
##
## 使い方:
##   sx_var_is_copyable [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   与えられた連鎖式群を実行した場合に、書き込み対象となる全ての変数
##   （配列の子要素を含む）が書き込み可能か確認する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_var_is_copyable() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_copyable "${@}" || return; return 0;; esac

	sx_var_is_chain "${@}" || return "${SX_EX_USAGE}"

	__sx_var_is_copyable "${@}" || return
}

### __sx_var_is_copyable - コピー先が構造を含めて書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_copyable 変数名1 変数名2 [変数名3 ...]
##
## 説明:
##   sx_var_is_copyable の内部実装。
##   引数チェックは行わない。
__sx_var_is_copyable() {
	SX_CFG_UNSET_SOFT=2 __sx_var_list_copy __sx_var_is_copyable_ls_ "${@}"
	eval set -- "${__sx_var_is_copyable_ls_}"

	__sx_var_is_copyable_out_=
	for __sx_var_is_copyable_arg_ in "${@}"; do
		__sx_var_is_copyable_out_="${__sx_var_is_copyable_out_} ${__sx_var_is_copyable_arg_%%=*}"
	done

	eval set -- "${__sx_var_is_copyable_out_}"
	unset __sx_var_is_copyable_ls_ __sx_var_is_copyable_out_ __sx_var_is_copyable_arg_

	__sx_var_is_rw_all "${@}" || return
}

### sx_var_is_empty - 変数が設定されており、かつ空か確認する
##
## 使い方:
##   sx_var_is_empty 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて空である (SX_EX_OK)
##    1  設定されていない、または空でない変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_empty() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_empty "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_empty "${@}" || return
}

### __sx_var_is_empty - 変数が設定されており、かつ空か確認する（内部用）
##
## 使い方:
##   __sx_var_is_empty 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が空（かつ設定済み）か確認する。
##   引数チェックは行わない。
__sx_var_is_empty() {
	for __sx_var_is_empty_arg_ in "${@}"; do
		eval "__sx_var_is_empty_e_=\"\${${__sx_var_is_empty_arg_}+X}\${${__sx_var_is_empty_arg_}-}\""

		case "${__sx_var_is_empty_e_}" in '' | X?*)
			unset __sx_var_is_empty_arg_ __sx_var_is_empty_e_
			return 1
		esac

		unset __sx_var_is_empty_arg_ __sx_var_is_empty_e_
	done
}

### sx_var_is_name - 変数名として有効か確認する
##
## 使い方:
##   sx_var_is_name [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて有効な変数名 (SX_EX_OK)
##    1  無効な変数名が含まれる
sx_var_is_name() {
	for __sx_var_is_name_arg in "${@}"; do
		case "${__sx_var_is_name_arg}" in '' | [0-9]* | *[!"${SX_STR_WORD}"]*)
			unset __sx_var_is_name_arg
			return 1
		esac
	done

	unset __sx_var_is_name_arg
}

### sx_var_is_ro - 変数が読み取り専用か確認する
##
## 使い方:
##   sx_var_is_ro 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて読み取り専用 (SX_EX_OK)
##    1  書き込み可能な変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_ro() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_ro "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_ro "${@}" || return
}

### __sx_var_is_ro - 変数が読み取り専用か確認する（内部用）
##
## 使い方:
##   __sx_var_is_ro 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が読み取り専用か確認する。
##   引数チェックは行わない。
__sx_var_is_ro() {
	for __sx_var_is_ro_arg_ in "${@}"; do
		if __sx_var_is_rw "${__sx_var_is_ro_arg_}"; then
			unset __sx_var_is_ro_arg_
			return 1
		fi

		unset __sx_var_is_ro_arg_
	done
}

### sx_var_is_rw - 変数が書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  読み取り専用が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_rw() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_rw "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_rw "${@}" || return
}

### __sx_var_is_rw - 変数が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_rw 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が書き込み可能か確認する。
##   サブシェルの生成を最小限にするため、一括で検証を行う。
__sx_var_is_rw() {
	case "${#}" in [1-9]*)
		( unset -v "${@}" ) 2>&- || return 1
	esac
}

### sx_var_is_rw_all - 指定された変数およびその関連要素がすべて書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw_all 名前1 [名前2 ...]
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  読み取り専用が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_rw_all() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_rw_all "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"

	__sx_var_is_rw_all "${@}" || return
}

### __sx_var_is_rw_all - 指定された変数および関連要素が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_rw_all 名前1 [名前2 ...]
##
## 説明:
##   sx_var_is_rw_all の内部実装。
##   引数チェックは行わない。
__sx_var_is_rw_all() {
	SX_CFG_UNSET_SOFT=2 __sx_var_list_dep __sx_var_is_rw_all_ls_ "${@}"
	eval set -- "${__sx_var_is_rw_all_ls_}"
	unset __sx_var_is_rw_all_ls_

	__sx_var_is_rw "${@}" || return
}

### sx_var_is_set - 変数が設定されているか確認する
##
## 使い方:
##   sx_var_is_set 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて設定されている (SX_EX_OK)
##    1  未設定の変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_set "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_set "${@}" || return
}

### __sx_var_is_set - 変数が設定されているか確認する（内部用）
##
## 使い方:
##   __sx_var_is_set 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が設定されているか確認する。
##   引数チェックは行わない。
__sx_var_is_set() {
	for __sx_var_is_set_arg_ in "${@}"; do
		eval "__sx_var_is_set_e_=\"\${${__sx_var_is_set_arg_}+X}\""

		case "${__sx_var_is_set_e_}" in '')
			unset __sx_var_is_set_arg_ __sx_var_is_set_e_
			return 1
		esac

		unset __sx_var_is_set_arg_ __sx_var_is_set_e_
	done
}

### sx_var_is_val - 変数が値を持ち、かつ空でないか確認する
##
## 使い方:
##   sx_var_is_val 変数名1 [変数名2 ...]
##
## 終了ステータス:
##    0  すべて値があり、空でない (SX_EX_OK)
##    1  設定されていない、または空の変数が含まれる
##   64  変数名が無効 (SX_EX_USAGE)
sx_var_is_val() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_val "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_val "${@}" || return
}

### __sx_var_is_val - 変数が値を持ち、かつ空でないか確認する（内部用）
##
## 使い方:
##   __sx_var_is_val 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が値を持ち、空でないか確認する。
##   引数チェックは行わない。
__sx_var_is_val() {
	for __sx_var_is_val_arg_ in "${@}"; do
		eval "__sx_var_is_val_e_=\"\${${__sx_var_is_val_arg_}:+X}\""

		case "${__sx_var_is_val_e_}" in '')
			unset __sx_var_is_val_arg_ __sx_var_is_val_e_
			return 1
		esac

		unset __sx_var_is_val_arg_ __sx_var_is_val_e_
	done
}

### sx_var_list_copy - 変数のコピー用代入式リストを生成する
##
## 使い方:
##   sx_var_list_copy 結果変数名 [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   与えられた連鎖式群に対するコピー処理で必要となる、
##   スペース区切りの代入式リスト（例: "dest=src dest2=src2"）を生成して結果変数に格納する。
##   コピー元が sx 配列である場合は、関連するすべての要素も含めてリストに含める。
##   生成されたリストは eval set -- 等で利用できる。
##   連鎖式が指定されない場合や引数が単一の変数名の場合は、空文字列を格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_list_copy() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_list_copy "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return
	sx_var_is_chain "${@}" || return "${SX_EX_USAGE}"

	__sx_var_list_copy "${@}"
}

### __sx_var_list_copy - 変数のコピー用代入式リストを生成する（内部用）
##
## 使い方:
##   __sx_var_list_copy 結果変数名 [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   sx_var_list_copy の内部実装。
##   変数名列から右方向連鎖コピー用の代入式リストを生成する。
##   引数チェックは行わない。
__sx_var_list_copy() {
	__sx_var_list_copy_res_="${1}"
	__sx_var_list_copy_out_=
	shift

	for __sx_var_list_copy_chain_ in "${@}"; do
		case "${__sx_var_list_copy_chain_}" in
			*=*)
				sx_str_sub __sx_var_list_copy_args_ "${__sx_var_list_copy_chain_}" = ' '
				eval sx_arg_rquote __sx_var_list_copy_args_ "${__sx_var_list_copy_args_}"
				;;
			*) sx_str_sub __sx_var_list_copy_args_ "${__sx_var_list_copy_chain_}" - ' ';;
		esac

		eval set -- "${__sx_var_list_copy_args_}"

		for __sx_var_list_copy_dest_ in "${@}"; do
			if sx_var_is_set __sx_var_list_copy_src_; then
				SX_CFG_UNSET_SOFT=2 __sx_var_list_dep __sx_var_list_copy_ls_ "${__sx_var_list_copy_src_}"
				eval set -- "${__sx_var_list_copy_ls_}"

				for __sx_var_list_copy_name_ in "${@}"; do
					__sx_var_list_copy_out_="${__sx_var_list_copy_out_} ${__sx_var_list_copy_dest_}${__sx_var_list_copy_name_#"${__sx_var_list_copy_src_}"}=${__sx_var_list_copy_name_}"
				done
			fi

			__sx_var_list_copy_src_="${__sx_var_list_copy_dest_}"
		done

		unset __sx_var_list_copy_src_
	done

	__sx_var_set "${__sx_var_list_copy_res_}=${__sx_var_list_copy_out_}"
	unset __sx_var_list_copy_res_ __sx_var_list_copy_out_ __sx_var_list_copy_chain_ __sx_var_list_copy_args_ __sx_var_list_copy_ls_ __sx_var_list_copy_dest_ __sx_var_list_copy_name_
}

### sx_var_list_dep - 指定された変数に関連するすべての変数名を取得する
##
## 使い方:
##   sx_var_list_dep 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   指定された変数名、およびそれらがsx配列である場合に再帰的に含まれる
##   すべての変数名（_len, _0, _1...）をスペース区切りの文字列として取得し、
##   指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_list_dep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_list_dep "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" "${@}" || return "${SX_EX_USAGE}"
	__sx_var_is_rw_all "${1}" || return "${SX_EX_NOPERM}"

	__sx_var_list_dep "${@}"
}
### __sx_var_list_dep - 指定された変数に関連するすべての変数名を取得する（内部用）
##
## 使い方:
##   __sx_var_list_dep 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   位置パラメータをキューとして利用し、非再帰的に関連変数を収集する。
##   引数チェックは行わない。
__sx_var_list_dep() {
	__sx_var_list_dep_res_="${1}"
	shift

	__sx_var_list_dep_out_=' '

	while M_STR_NE([|"${#}"|], [|0|]); do
		case "${__sx_var_list_dep_out_}" in *" ${1} "*)
			shift
			continue
		esac

		__sx_var_list_dep_out_="${__sx_var_list_dep_out_}${1} "

		if __sx_var_is_arr "${1}"; then
			eval "__sx_var_list_dep_len_=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			__sx_var_list_dep_i_=0
			while M_STR_NE([|"${__sx_var_list_dep_i_}"|], [|"${__sx_var_list_dep_len_}"|]); do
				set -- "${@}" "${1}_${__sx_var_list_dep_i_}"
				: $((__sx_var_list_dep_i_ += 1))
			done
		fi

		shift
	done

	__sx_var_list_dep_out_="${__sx_var_list_dep_out_# }"
	__sx_var_set "${__sx_var_list_dep_res_}=${__sx_var_list_dep_out_% }"

	unset __sx_var_list_dep_res_ __sx_var_list_dep_out_ __sx_var_list_dep_len_ __sx_var_list_dep_i_
}


### sx_var_list_ro - 読み取り専用変数の一覧を取得する
##
## 使い方:
##   sx_var_list_ro 結果変数名
##
## 説明:
##   現在のシェルで読み取り専用として設定されている全ての変数名（重複除去済み）を
##   スペース区切りの文字列として取得し、指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_list_ro() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_list_ro "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" IFS || return

	__sx_var_list_ro "${@}"
}

### __sx_var_list_ro - 読み取り専用変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_ro 結果変数名
##
## 説明:
##   sx_var_list_ro の内部実装。
##   引数チェックは行わない。
__sx_var_list_ro() {
	__sx_var_list_ro_res_="${1}"
	__sx_var_list_ro_out_=' '

	IFS="${SX_STR_LF}" __sx_str_split_ifs __sx_var_list_ro_args_ "$(readonly -p)"
	eval set -- "${__sx_var_list_ro_args_}"

	for __sx_var_list_ro_ln_; do
		case "${__sx_var_list_ro_ln_}" in 'readonly '[_"${SX_STR_ALPHA}"] | 'readonly '[_"${SX_STR_ALPHA}"]*["${SX_STR_WORD}"] | 'readonly '[_"${SX_STR_ALPHA}"]=* | 'readonly '[_"${SX_STR_ALPHA}"]*["${SX_STR_WORD}"]=*)
			__sx_var_list_ro_vn_="${__sx_var_list_ro_ln_#readonly }"
			__sx_var_list_ro_vn_="${__sx_var_list_ro_vn_%%=*}"

			if
				sx_var_is_name "${__sx_var_list_ro_vn_}" &&
				! M_STR_HAS([|"${__sx_var_list_ro_out_}"|], [|" ${__sx_var_list_ro_vn_} "|]) &&
				__sx_var_is_ro "${__sx_var_list_ro_vn_}"
			then
				__sx_var_list_ro_out_="${__sx_var_list_ro_out_}${__sx_var_list_ro_vn_} "
			fi
		esac
	done

	__sx_var_list_ro_out_="${__sx_var_list_ro_out_# }"
	__sx_var_set "${__sx_var_list_ro_res_}=${__sx_var_list_ro_out_% }"

	unset __sx_var_list_ro_res_ __sx_var_list_ro_out_ __sx_var_list_ro_args_ __sx_var_list_ro_ln_ __sx_var_list_ro_vn_
}

### sx_var_list_set - 設定されている変数の一覧を取得する
##
## 使い方:
##   sx_var_list_set 結果変数名
##
## 説明:
##   現在のシェルで設定されている全ての変数名（重複除去済み）をスペース区切りの文字列として取得し、
##   指定された結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_list_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_list_set "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" IFS || return

	__sx_var_list_set "${@}"
}

### __sx_var_list_set - 設定されている変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_set 結果変数名
##
## 説明:
##   sx_var_list_set の内部実装。
##   引数チェックは行わない。
__sx_var_list_set() {
	IFS="${SX_STR_LF}" __sx_str_split_ifs __sx_var_list_set_args_ "$(set)"
	__sx_var_list_set_res_="${1}"
	__sx_var_list_set_out_=' '

	eval set -- "${__sx_var_list_set_args_}"

	for __sx_var_list_set_ln_; do
		case "${__sx_var_list_set_ln_}" in [_"${SX_STR_ALPHA}"]=* | [_"${SX_STR_ALPHA}"]*["${SX_STR_WORD}"]=*)
			__sx_var_list_set_vn_="${__sx_var_list_set_ln_%%=*}"

			if
				sx_var_is_name "${__sx_var_list_set_vn_}" &&
				! M_STR_HAS([|"${__sx_var_list_set_out_}"|], [|" ${__sx_var_list_set_vn_} "|]) &&
				__sx_var_is_set "${__sx_var_list_set_vn_}"
			then
				__sx_var_list_set_out_="${__sx_var_list_set_out_}${__sx_var_list_set_vn_} "
			fi
		esac
	done

	__sx_var_list_set_out_="${__sx_var_list_set_out_# }"
	__sx_var_set "${__sx_var_list_set_res_}=${__sx_var_list_set_out_% }"

	unset __sx_var_list_set_args_ __sx_var_list_set_res_ __sx_var_list_set_out_ __sx_var_list_set_ln_ __sx_var_list_set_vn_
}

### sx_var_move - 変数を連鎖移動する
##
## 使い方:
##   sx_var_move [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   指定された連鎖式に従って、変数の値を移動し、元の変数を削除する。
##   連鎖式には以下の形式が使用できる：
##     A-B-C : 左から右へ移動 (A -> B -> C)
##     A=B=C : 右から左へ移動 (A <- B <- C)
##   例: v1-v2-v3 の場合、v1 の値を v2 に、v2 の元の値を v3 に移し、
##   最後に元のソースである v1 を削除する。
##   複数の連鎖式が指定された場合は、順次実行される。
##   引数が単一の変数名の場合は、その変数を削除する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  移動先または削除対象が読み取り専用 (SX_EX_NOPERM)
sx_var_move() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_move "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_copyable "${@}" || return

	__sx_var_move_chk=
	for __sx_var_move_arg in "${@}"; do
		case "${__sx_var_move_arg}" in
			*=*) __sx_var_move_chk="${__sx_var_move_chk} ${__sx_var_move_arg##*=}";;
			*) __sx_var_move_chk="${__sx_var_move_chk} ${__sx_var_move_arg%%-*}";;
		esac
	done

	eval __sx_var_is_rw_all "${__sx_var_move_chk}" || {
		unset __sx_var_move_chk __sx_var_move_arg
		return "${SX_EX_NOPERM}"
	}

	__sx_var_copy "${@}"
	eval __sx_var_unset "${__sx_var_move_chk}"

	unset __sx_var_move_chk __sx_var_move_arg
}

### __sx_var_move - 変数を連鎖移動する（内部用）
##
## 使い方:
##   __sx_var_move [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_move の内部実装。
##   引数チェックは行わない。
__sx_var_move() {
	__sx_var_copy "${@}"

	for __sx_var_move_arg_ in "${@}"; do
		case "${__sx_var_move_arg_}" in
			*=*) __sx_var_unset "${__sx_var_move_arg_##*=}";;
			*) __sx_var_unset "${__sx_var_move_arg_%%-*}";;
		esac
	done

	unset __sx_var_move_arg_
}

### sx_var_set - 変数に値を設定、または削除する
##
## 使い方:
##   sx_var_set [名前=値 | 名前 ...]
##
## 説明:
##   指定された変数に値を設定する。= を含まない名前のみが指定された場合は、
##   その変数を削除（unset）する。対象が sx 配列である場合は、
##   関連するすべての要素（_len, _0, _1...）も再帰的に削除される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  読み取り専用変数への操作失敗 (SX_EX_NOPERM)
sx_var_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_set "${@}" || return; return 0;; esac

	__sx_var_set_chk=

	for __sx_var_set_arg in "${@}"; do
		sx_var_is_name "${__sx_var_set_arg%%=*}" || {
			unset __sx_var_set_arg __sx_var_set_chk
			return "${SX_EX_USAGE}"
		}

		__sx_var_set_chk="${__sx_var_set_chk} ${__sx_var_set_arg%%=*}"
	done

	eval sx_var_is_rw_all "${__sx_var_set_chk}" || {
		unset  __sx_var_set_chk __sx_var_set_arg
		return "${SX_EX_NOPERM}"
	}

	unset  __sx_var_set_chk __sx_var_set_arg
	__sx_var_set "${@}"
}

### __sx_var_set - 変数に値を設定、または削除する（内部用）
##
## 使い方:
##   __sx_var_set [名前=値 | 名前 ...]
##
## 説明:
##   sx_var_set の内部実装。
##   引数チェックは行わない。
__sx_var_set() {
	for __sx_var_set_arg_ in "${@}"; do
		__sx_var_set_vn_="${__sx_var_set_arg_%%=*}"
		__sx_var_unset "${__sx_var_set_vn_%%=*}"

		case "${__sx_var_set_arg_}" in *=*)
			eval "${__sx_var_set_vn_}="'"${__sx_var_set_arg_#*=}"'
		esac
	done

	unset __sx_var_set_arg_ __sx_var_set_vn_
}

### sx_var_swap - 変数を連鎖的にローテーションする
##
## 使い方:
##   sx_var_swap [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   指定された連鎖式内の変数群をローテーションさせる。
##   連鎖式には以下の形式が使用できる：
##     A-B-C : 右方向に回転 (C の値を A に、A の値を B に、B の値を C に移動)
##     A=B=C : 左方向に回転 (A の値を C に、C の値を B に、B の値を A に移動)
##   例: v1-v2-v3 の場合、v3 の値を v1 に、v1 の値を v2 に、v2 の値を v3 に移動する。
##   引数が単一の変数名の場合は、何もせず成功する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_var_swap() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_swap "${@}" || return; return 0;; esac

	sx_var_is_chain "${@}" || return "${SX_EX_USAGE}"

	__sx_var_swap_out=
	SX_CFG_UNSET_SOFT=2 __sx_arr_gen __sx_var_swap_arr

	for __sx_var_swap_arg in "${@}"; do
		SX_CFG_UNSET_SOFT=2 __sx_arr_push __sx_var_swap_arr ''
		__sx_var_swap_tmp="__sx_var_swap_arr_$((__sx_var_swap_arr_len - 1))"

		case "${__sx_var_swap_arg}" in
			*=*)
				SX_CFG_UNSET_SOFT=2 __sx_var_copy "${__sx_var_swap_arg%%=*}-${__sx_var_swap_tmp}"
				__sx_var_swap_out="${__sx_var_swap_out} ${__sx_var_swap_arg}=${__sx_var_swap_tmp}"
				;;
			*-*)
				SX_CFG_UNSET_SOFT=2 __sx_var_copy "${__sx_var_swap_arg##*-}-${__sx_var_swap_tmp}"
				__sx_var_swap_out="${__sx_var_swap_out} ${__sx_var_swap_tmp}-${__sx_var_swap_arg}"
				;;
		esac
	done

	eval set -- "${__sx_var_swap_out}"
	unset __sx_var_swap_arg __sx_var_swap_tmp __sx_var_swap_out

	__sx_var_is_copyable "${@}" || {
		__sx_var_unset __sx_var_swap_arr
		return "${SX_EX_NOPERM}"
	}

	__sx_var_copy "${@}"
	__sx_var_unset __sx_var_swap_arr
}

### __sx_var_swap - 変数を連鎖的にローテーションする（内部用）
##
## 使い方:
##   __sx_var_swap [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_swap の内部実装。
##   引数チェックは行わない。
__sx_var_swap() {
	__sx_var_swap_out_=
	SX_CFG_UNSET_SOFT=2 __sx_arr_gen __sx_var_swap_arr_

	for __sx_var_swap_arg_ in "${@}"; do
		SX_CFG_UNSET_SOFT=2 __sx_arr_push __sx_var_swap_arr_ ''
		__sx_var_swap_tmp_="__sx_var_swap_arr__$((__sx_var_swap_arr__len - 1))"

		case "${__sx_var_swap_arg_}" in
			*=*)
				SX_CFG_UNSET_SOFT=2 __sx_var_copy "${__sx_var_swap_arg_%%=*}-${__sx_var_swap_tmp_}"
				__sx_var_swap_out_="${__sx_var_swap_out_} ${__sx_var_swap_arg_}=${__sx_var_swap_tmp_}"
				;;
			*-*)
				SX_CFG_UNSET_SOFT=2 __sx_var_copy "${__sx_var_swap_arg_##*-}-${__sx_var_swap_tmp_}"
				__sx_var_swap_out_="${__sx_var_swap_out_} ${__sx_var_swap_tmp_}-${__sx_var_swap_arg_}"
				;;
		esac
	done

	eval __sx_var_copy "${__sx_var_swap_out_}"

	unset __sx_var_swap_arg_ __sx_var_swap_tmp_ __sx_var_swap_out_
	__sx_var_unset __sx_var_swap_arr_
}

### sx_var_touch - リビジョン番号を更新する
##
## 使い方:
##   sx_var_touch 変数名
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_var_touch() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_touch "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw "${@}" || return

	__sx_var_touch "${@}"
}

### __sx_var_touch - 変数のリビジョン番号を更新する（内部用）
##
## 使い方:
##   __sx_var_touch 変数名1 [変数名2 ...]
##
## 説明:
##   指定された変数の値に含まれるリビジョン番号（末尾の : 以降）を
##   現在の SX_SYS_REV で更新し、SX_SYS_REV をインクリメントする。
##   引数チェックは行わない。
__sx_var_touch() {
	for __sx_var_touch_arg_ in "${@}"; do
		eval "${__sx_var_touch_arg_}=\"\${${__sx_var_touch_arg_}%:*}:\${SX_SYS_REV}\""
		: $((SX_SYS_REV += 1))
	done

	unset __sx_var_touch_arg_
}

### sx_var_unset - 変数または配列を関連要素を含めて削除する
##
## 使い方:
##   sx_var_unset 名前1 [名前2 ...]
##
## 説明:
##   指定された変数を削除する。対象がsx配列である場合は、その要素および
##   長さ変数も含めて再帰的にすべて削除する。
##   一つでも削除不可能な変数（読み取り専用など）が含まれる場合は、
##   どの変数も削除せずにエラーを返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  削除不可能な変数が含まれる (SX_EX_NOPERM)
sx_var_unset() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_unset "${@}" || return; return 0;; esac

	# リストの内容（変数名）がすべて書き込み可能か一括チェック
	case "${SX_CFG_UNSET_SOFT-}" in
		1) __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw "${@}" || return ;;
		2) ;;
		*) __sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${@}" || return ;;
	esac

	__sx_var_unset "${@}"
}

### __sx_var_unset - 変数または配列を関連要素を含めて削除する（内部用）
##
## 使い方:
##   __sx_var_unset 名前1 [名前2 ...]
##
## 説明:
##   sx_var_unset の内部実装。
##   引数チェックは行わない。
__sx_var_unset() {
	case "${SX_CFG_UNSET_SOFT-}" in
		1)
			case "${#}" in [!0]*)
				unset -v "${@}"
			esac

			return "${SX_EX_OK}"
			;;
		2) return "${SX_EX_OK}";;
	esac

	while M_STR_NE([|"${#}"|], [|0|]); do
		if __sx_var_is_arr "${1}"; then
			eval "__sx_var_unset_len_=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			__sx_var_unset_i_=0
			while M_STR_NE([|"${__sx_var_unset_i_}"|], [|"${__sx_var_unset_len_}"|]); do
				set -- "${@}" "${1}_${__sx_var_unset_i_}"
				: $((__sx_var_unset_i_ += 1))
			done
		fi

		unset -v "${1}"
		shift
	done

	unset __sx_var_unset_len_ __sx_var_unset_i_
}

# ========================================
#  NUM (Numerical Operations)
# ========================================

### sx_num_cmp_arith - 2つの数値を算術展開で比較する
##
## 使い方:
##   sx_num_cmp_arith 数値1 数値2
##
## 終了ステータス:
##   1  数値1 < 数値2
##   2  数値1 = 数値2
##   3  数値1 > 数値2
##  64  引数不正 (SX_EX_USAGE)
sx_num_cmp_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_arith "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int "${1-}" "${2-}" || return

	__sx_num_cmp_arith "${1}" "${2}" || return
}

### __sx_num_cmp_arith - 整数を算術展開で比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_arith() {
	return "$((${1} < ${2} ? 1 : (${1} > ${2} ? 3 : 2)))"
}

### sx_num_cmp_float - 2つの数値を比較する
##
## 使い方:
##   sx_num_cmp_float 左辺 右辺
##
## 説明:
##   指定された2つの数値を比較する。
##
## 終了ステータス:
##    1  左辺 < 右辺
##    2  左辺 = 右辺
##    3  左辺 > 右辺
##   64  引数が数値ではない (SX_EX_USAGE)
sx_num_cmp_float() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_float "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_float "${1-}" "${2-}" || return

	__sx_num_cmp_float "${@}"
}

### __sx_num_cmp_float - 2つの数値を比較する（検証なし）
##
## 使い方:
##   __sx_num_cmp_float 左辺 右辺
##
## 説明:
##   指定された2つの数値を比較する。
##   引数が数値であることの検証は行わない。
##
## 終了ステータス:
##    1  左辺 < 右辺
##    2  左辺 = 右辺
##    3  左辺 > 右辺
__sx_num_cmp_float() {
	SX_CFG_UNSET_SOFT=2 __sx_num_norm __sx_num_cmp_float_a_:__sx_num_cmp_float_b_ "${1}" "${2}"
	set -- "${__sx_num_cmp_float_a_}" "${__sx_num_cmp_float_b_}"
	unset __sx_num_cmp_float_a_ __sx_num_cmp_float_b_

	__sx_num_cmp_fixed "${@}" || return
}

### __sx_num_cmp_fixed_abs - 正規化済み絶対値同士を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_fixed_abs() {
	case "${1}" in
		*.*) set -- "${1%%.*}" "${2}" "${1#*.}";;
		*) set -- "${1}" "${2}" '';;
	esac

	case "${2}" in
		*.*) set -- "${1}" "${2%%.*}" "${3}" "${2#*.}";;
		*) set -- "${1}" "${2}" "${3}" '';;
	esac

	__sx_num_cmp_nat0 "${1}" "${2}" || case "${?}" in 1 | 3)
		return "${?}"
	esac

	__sx_num_cmp_fixed_frac "${3}" "${4}" || return "${?}"
}

### sx_num_cmp_fixed - 2つの固定小数点数を比較する
##
## 使い方:
##   sx_num_cmp_fixed 左辺 右辺
##
## 説明:
##   指定された2つの固定小数点数を比較する。
##   引数は sx_num_norm 等で正規化された10進固定小数点形式である必要がある。
##
## 終了ステータス:
##    1  左辺 < 右辺
##    2  左辺 = 右辺
##    3  左辺 > 右辺
##   64  引数が正規化済み数値ではない (SX_EX_USAGE)
sx_num_cmp_fixed() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_fixed "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_fixed "${1-}" "${2-}" || return

	__sx_num_cmp_fixed "${1}" "${2}" || return
}

### __sx_num_cmp_fixed - 正規化済み数値を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_fixed() {
	set -- "${1#[+-]}" "${2#[+-]}" "${1%%[!-]*}" "${2%%[!-]*}"

	case "${3:-+}${4:-+}" in
		-+) return 1;;
		+-) return 3;;
	esac

	case "${3}" in
		-*) __sx_num_cmp_fixed_abs "${2}" "${1}";;
		*)  __sx_num_cmp_fixed_abs "${1}" "${2}";;
	esac || return "${?}"
}

### __sx_num_cmp_arith_digit - 10進整数文字列を算術展開で比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_arith_digit() {
	set -- "${1#${1%%[!0]*}}" "${2#${2%%[!0]*}}"
	__sx_num_cmp_arith "${1:-0}" "${2:-0}"
}

### __sx_num_cmp_fixed_frac - 小数部を左から比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_fixed_frac() {
	# 完全に一致する場合は即座に終了 (EQ)
	case "${1}" in "${2}") return 2;; esac

	# 接頭辞チェック（正規化により、長い方が必ず大きい）
	# 冒頭で行うことで、長い小数部の延長比較をループなしで高速に処理する
	case "${1}" in "${2}"*) return 3;; esac
	case "${2}" in "${1}"*) return 1;; esac

	# 窓幅パターン（?????????）を準備
	eval "__sx_num_cmp_fixed_frac_q_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_QM}\""
	# $1: qm, $2: lhs, $3: rhs
	set -- "${__sx_num_cmp_fixed_frac_q_}" "${1}" "${2}"
	unset __sx_num_cmp_fixed_frac_q_

	# 両方の文字列が窓幅以上の間、チャンクごとに比較
	while M_STR_MATCH([|"${2}"|], [|${1}?*|]) && M_STR_MATCH([|"${3}"|], [|${1}?*|]); do
		set -- "${1}" "${2#${1}}" "${3#${1}}" "${2}" "${3}"
		__sx_num_cmp_arith_digit "${4%"${2}"}" "${5%"${3}"}" || case "${?}" in
			1 | 3) return "${?}";;
		esac
	done

	# 接頭辞の関係にない（＝どこかの桁で異なる）残りの部分をパディングして最後の比較
	eval "__sx_num_cmp_fixed_frac_z_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_ZR}\""
	set -- "${1}" "${2}${__sx_num_cmp_fixed_frac_z_}" "${3}${__sx_num_cmp_fixed_frac_z_}"
	unset __sx_num_cmp_fixed_frac_z_

	__sx_num_cmp_arith_digit "${2%"${2#${1}}"}" "${3%"${3#${1}}"}" || return "${?}"
}

### sx_num_cmp_nat0 - 2つの符号なし10進整数を比較する
##
## 使い方:
##   sx_num_cmp_nat0 数値1 数値2
##
## 説明:
##   指定された2つの符号なし10進整数を比較する。
##   引数はすべて 0 以上の整数である必要がある。
##
## 終了ステータス:
##   1  数値1 < 数値2
##   2  数値1 = 数値2
##   3  数値1 > 数値2
##  64  引数不正 (SX_EX_USAGE)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_cmp_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_nat0 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"
	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_base_nat0 10 "${1-}" "${2-}" || return

	__sx_num_cmp_nat0 "${1}" "${2}" || return
}

define([|V|], [|__sx_num_cmp_nat0_$1_|])dnl
define([|CLEANUP|], [|V(l) V(r) V(qm)|])dnl

### __sx_num_cmp_nat0 - 符号なし10進整数文字列を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_cmp_nat0() {
	case "${1}" in "${2}")
		return 2
	esac

	__sx_num_cmp_nat0_l_="${#1}"
	__sx_num_cmp_nat0_r_="${#2}"

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${__sx_num_cmp_nat0_l_}" "${__sx_num_cmp_nat0_r_}"; then
		__sx_num_cmp_arith "${__sx_num_cmp_nat0_l_}" "${__sx_num_cmp_nat0_r_}"
	else
		__sx_num_cmp_nat0 "${__sx_num_cmp_nat0_l_}" "${__sx_num_cmp_nat0_r_}"
	fi || case "${?}" in 1 | 3)
		set -- "${?}"
		unset CLEANUP
		return "${1}"
	esac

	eval "__sx_num_cmp_nat0_qm_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_QM}\""

	while M_STR_MATCH([|"${1}"|], [|${__sx_num_cmp_nat0_qm_}?*|]); do
		set -- "${1#${__sx_num_cmp_nat0_qm_}}" "${2#${__sx_num_cmp_nat0_qm_}}" "${1}" "${2}"
		__sx_num_cmp_arith_digit "${3%"${1}"}" "${4%"${2}"}" || case "${?}" in 1 | 3)
			set -- "${?}"
			unset CLEANUP
			return "${1}"
		esac
	done

	unset CLEANUP

	__sx_num_cmp_arith_digit "${1}" "${2}" || return "${?}"
}

### sx_num_is_base_int - 指定された基数で整数か確認する
##
## 使い方:
##   sx_num_is_base_int 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が、任意で符号（+ または -）を持つ整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_base_nat0 に準ずる。
##
## 終了ステータス:
##    0  すべて整数である (SX_EX_OK)
##    1  整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_base_int() {
	case "${1-}" in 8 | 10 | 16) ;; *) return "${SX_EX_USAGE}";; esac

	__sx_num_is_base_int "${@}"
}

### __sx_num_is_base_int - 指定された基数で整数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_base_int 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_base_int の内部実装。基数チェックを行わない。
__sx_num_is_base_int() {
	__sx_num_is_base_int_base_="${1}"
	shift

	for __sx_num_is_base_int_arg_ in "${@}"; do
		__sx_num_is_base_nat0 "${__sx_num_is_base_int_base_}" "${__sx_num_is_base_int_arg_#[+-]}" || {
			unset __sx_num_is_base_int_base_ __sx_num_is_base_int_arg_
			return 1
		}
	done

	unset __sx_num_is_base_int_base_ __sx_num_is_base_int_arg_
}

### sx_num_is_base_nat0 - 指定された基数で0以上の自然数か確認する
##
## 使い方:
##   sx_num_is_base_nat0 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 0 以上の自然数（符号なし整数）であるか確認する。
##   基数 8 および 16 では各々のプレフィックス（8: '0', 16: '0x'/'0X'）を必須とする。
##   基数 10 ではプレフィックスを認めず、また 0 以外の数値における先行する 0 も認めない。
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_base_nat0() {
	case "${1-}" in 8 | 10 | 16) ;; *) return "${SX_EX_USAGE}";; esac

	__sx_num_is_base_nat0 "${@}"
}

### __sx_num_is_base_nat0 - 指定された基数で0以上の自然数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_base_nat0 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_base_nat0 の内部実装。基数チェックを行わない。
__sx_num_is_base_nat0() {
	eval "
		__sx_num_is_base_nat0_pfix_=\"\${SX_NUM_BASE${1}_PREFIX}\"
		__sx_num_is_base_nat0_char_=\"\${SX_NUM_BASE${1}_CHARS}\"
	"
	shift

	for __sx_num_is_base_nat0_arg_ in "${@}"; do
		case "${__sx_num_is_base_nat0_arg_}" in
			${__sx_num_is_base_nat0_pfix_}*) ! M_STR_MATCH([|"${__sx_num_is_base_nat0_arg_#${__sx_num_is_base_nat0_pfix_}}"|] , [|''|], [|0?*|], [|*[!"${__sx_num_is_base_nat0_char_}"]*|]);;
			*) ! :;;
		esac || {
			unset __sx_num_is_base_nat0_pfix_ __sx_num_is_base_nat0_char_ __sx_num_is_base_nat0_arg_
			return 1
		}
	done

	unset __sx_num_is_base_nat0_arg_ __sx_num_is_base_nat0_pfix_ __sx_num_is_base_nat0_char_
}

### sx_num_is_base_nat1 - 指定された基数で1以上の自然数か確認する
##
## 使い方:
##   sx_num_is_base_nat1 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 1 以上の自然数（符号なし整数）であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_base_nat0 に準ずる。
##
## 終了ステータス:
##    0  すべて 1 以上の自然数である (SX_EX_OK)
##    1  1 以上の自然数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_base_nat1() {
	case "${1-}" in 8 | 10 | 16) ;; *) return "${SX_EX_USAGE}";; esac

	__sx_num_is_base_nat1 "${@}"
}

### __sx_num_is_base_nat1 - 指定された基数で1以上の自然数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_base_nat1 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_base_nat1 の内部実装。基数チェックを行わない。
__sx_num_is_base_nat1() {
	eval "
		__sx_num_is_base_nat1_pfix_=\"\${SX_NUM_BASE${1}_PREFIX}\"
		__sx_num_is_base_nat1_char_=\"\${SX_NUM_BASE${1}_CHARS}\"
	"
	shift

	for __sx_num_is_base_nat1_arg_ in "${@}"; do
		case "${__sx_num_is_base_nat1_arg_}" in
			${__sx_num_is_base_nat1_pfix_}*) ! M_STR_MATCH([|"${__sx_num_is_base_nat1_arg_#${__sx_num_is_base_nat1_pfix_}}"|], [|''|], [|0*|], [|*[!"${__sx_num_is_base_nat1_char_}"]*|]);;
			*) ! :;;
		esac || {
			unset __sx_num_is_base_nat1_pfix_ __sx_num_is_base_nat1_char_ __sx_num_is_base_nat1_arg_
			return 1
		}
	done

	unset __sx_num_is_base_nat1_arg_ __sx_num_is_base_nat1_pfix_ __sx_num_is_base_nat1_char_
}

### sx_num_is_base_nint - 指定された基数で負の整数（-1以下）か確認する
##
## 使い方:
##   sx_num_is_base_nint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が、負の符号（-）を必須で持つ -1 以下の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_base_nat0 に準ずる。
##
## 終了ステータス:
##    0  すべて負の整数である (SX_EX_OK)
##    1  負の整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_base_nint() {
	case "${1-}" in 8 | 10 | 16) ;; *) return "${SX_EX_USAGE}";; esac

	__sx_num_is_base_nint "${@}"
}

### __sx_num_is_base_nint - 指定された基数で負の整数（-1以下）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_base_nint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_base_nint の内部実装。基数チェックを行わない。
__sx_num_is_base_nint() {
	__sx_num_is_base_nint_base_="${1}"
	shift

	for __sx_num_is_base_nint_arg_ in "${@}"; do
		case "${__sx_num_is_base_nint_arg_}" in
			-*) __sx_num_is_base_nat1 "${__sx_num_is_base_nint_base_}" "${__sx_num_is_base_nint_arg_#-}";;
			*) ! :;;
			esac || {
				unset __sx_num_is_base_nint_base_ __sx_num_is_base_nint_arg_
				return 1
			}
	done

	unset __sx_num_is_base_nint_base_ __sx_num_is_base_nint_arg_
}

### sx_num_is_base_nnint - 指定された基数で非負整数（0以上）か確認する
##
## 使い方:
##   sx_num_is_base_nnint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 0 以上の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_base_nat0 に準ずる。
##
## 終了ステータス:
##    0  すべて非負整数である (SX_EX_OK)
##    1  非負整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_base_nnint() {
	case "${1-}" in 8 | 10 | 16) ;; *) return "${SX_EX_USAGE}";; esac

	__sx_num_is_base_nnint "${@}"
}

### __sx_num_is_base_nnint - 指定された基数で非負整数（0以上）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_base_nnint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_base_nnint の内部実装。基数チェックを行わない。
__sx_num_is_base_nnint() {
	__sx_num_is_base_nnint_base_="${1}"
	shift

	for __sx_num_is_base_nnint_arg_ in "${@}"; do
		case "${__sx_num_is_base_nnint_base_}${__sx_num_is_base_nnint_arg_}" in
			800 | 8[+-]00 | 100 | 10[+-]0 | 160[Xx]0 | 16[+-]0[Xx]0) continue;;
		esac

		__sx_num_is_base_pint "${__sx_num_is_base_nnint_base_}" "${__sx_num_is_base_nnint_arg_}" || {
			unset __sx_num_is_base_nnint_base_ __sx_num_is_base_nnint_arg_
			return 1
		}
	done

	unset __sx_num_is_base_nnint_base_ __sx_num_is_base_nnint_arg_
}

### sx_num_is_base_npint - 指定された基数で非正整数（0以下）か確認する
##
## 使い方:
##   sx_num_is_base_npint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 0 以下の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_base_nat0 に準ずる。
##
## 終了ステータス:
##    0  すべて非正整数である (SX_EX_OK)
##    1  非正整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_base_npint() {
	case "${1-}" in 8 | 10 | 16) ;; *) return "${SX_EX_USAGE}";; esac

	__sx_num_is_base_npint "${@}"
}

### __sx_num_is_base_npint - 指定された基数で非正整数（0以下）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_base_npint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_base_npint の内部実装。基数チェックを行わない。
__sx_num_is_base_npint() {
	__sx_num_is_base_npint_base_="${1}"
	shift

	for __sx_num_is_base_npint_arg_ in "${@}"; do
		case "${__sx_num_is_base_npint_base_}${__sx_num_is_base_npint_arg_}" in
			800 | 8[+-]00 | 100 | 10[+-]0 | 160[Xx]0 | 16[+-]0[Xx]0) continue;;
		esac

		__sx_num_is_base_nint "${__sx_num_is_base_npint_base_}" "${__sx_num_is_base_npint_arg_}" || {
			unset __sx_num_is_base_npint_base_ __sx_num_is_base_npint_arg_
			return 1
		}
	done

	unset __sx_num_is_base_npint_base_ __sx_num_is_base_npint_arg_
}

### sx_num_is_base_pint - 指定された基数で正の整数（1以上）か確認する
##
## 使い方:
##   sx_num_is_base_pint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が、任意で正の符号（+）を持つ 1 以上の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_base_nat0 に準ずる。
##
## 終了ステータス:
##    0  すべて正の整数である (SX_EX_OK)
##    1  正の整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_base_pint() {
	case "${1-}" in 8 | 10 | 16) ;; *) return "${SX_EX_USAGE}";; esac

	__sx_num_is_base_pint "${@}"
}

### __sx_num_is_base_pint - 指定された基数で正の整数（1以上）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_base_pint 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_base_pint の内部実装。基数チェックを行わない。
__sx_num_is_base_pint() {
	__sx_num_is_base_pint_base_="${1}"
	shift

	for __sx_num_is_base_pint_arg_ in "${@}"; do
		__sx_num_is_base_nat1 "${__sx_num_is_base_pint_base_}" "${__sx_num_is_base_pint_arg_#+}" || {
			unset __sx_num_is_base_pint_base_ __sx_num_is_base_pint_arg_
			return 1
		}
	done

	unset __sx_num_is_base_pint_base_ __sx_num_is_base_pint_arg_
}

### sx_num_is_fixed - すべての引数が 10 進の実数表記（固定小数点形式）であるか確認する
##
## 使い方:
##   sx_num_is_fixed [文字列1 [文字列2 ...]]
##
## 説明:
##   任意で符号（+ または -）を持つ 10 進の実数表記（固定小数点形式）であるかを確認する。
##   整数部は 10 進整数として検査し、小数点を含む場合は小数部に 1 文字以上の数字を要求する。
##   したがって、"1.0" は許可されるが "1." や ".1" は許可されない。
##
## 終了ステータス:
##    0  すべて 10 進の実数表記である (SX_EX_OK)
##    1  10 進の実数表記ではない値が含まれる
sx_num_is_fixed() {
	for __sx_num_is_fixed_arg in "${@}"; do
		case "${__sx_num_is_fixed_arg}" in *.*)
			sx_str_is_digit "${__sx_num_is_fixed_arg#*.}"
		esac && sx_num_is_base_int 10 "${__sx_num_is_fixed_arg%%.*}" || {
			unset __sx_num_is_fixed_arg
			return 1
		}
	done

	unset __sx_num_is_fixed_arg
}

### sx_num_is_float - すべての引数が 10 進の実数表記（浮動小数点形式）であるか確認する
##
## 使い方:
##   sx_num_is_float [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_fixed に加えて、指数表記（e または E による表記）を許可する。
##   指数部は 10 進整数として検査する。
##
## 終了ステータス:
##    0  すべて 10 進の実数表記である (SX_EX_OK)
##    1  10 進の実数表記ではない値が含まれる
sx_num_is_float() {
	for __sx_num_is_float_arg in "${@}"; do
		case "${__sx_num_is_float_arg}" in *[Ee]*)
			__sx_num_is_base_int 10 "${__sx_num_is_float_arg#*[Ee]}"
		esac && sx_num_is_fixed "${__sx_num_is_float_arg%%[Ee]*}" || {
			unset __sx_num_is_float_arg
			return 1
		}
	done

	unset __sx_num_is_float_arg
}

### sx_num_is_int - すべての引数が整数であるか確認する
##
## 使い方:
##   sx_num_is_int [文字列1 [文字列2 ...]]
##
## 説明:
##   任意で符号（+ または -）を持つ整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて整数である (SX_EX_OK)
##    1  整数ではない値が含まれる
sx_num_is_int() {
	for __sx_num_is_int_arg in "${@}"; do
		sx_num_is_nat0 "${__sx_num_is_int_arg#[+-]}" || {
			unset __sx_num_is_int_arg
			return 1
		}
	done

	unset __sx_num_is_int_arg
}

### sx_num_is_int_fit_dec - すべての引数が指定されたビット幅の符号付き10進整数の範囲内か確認する
##
## 使い方:
##   sx_num_is_int_fit_dec ビット幅 [整数1 [整数2 ...]]
##
## 説明:
##   第1引数で指定されたビット幅の符号付き整数として、
##   後続のすべての引数が、その範囲内の10進整数であるか確認する。
##   8進数 (0...) や 16進数 (0x...) 形式はサポートしない。
##
## 終了ステータス:
##    0  すべて範囲内である (SX_EX_OK)
##    1  範囲内に収まらない値が含まれる（ビット幅は正しい）
##   64  ビット幅指定が不正、または整数として不正な値が含まれる (SX_EX_USAGE)
sx_num_is_int_fit_dec() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_fit_dec "${@}" || return; return 0;; esac

	case "${1-}" in
		8 | 16 | 32 | 64 | 128) ;;
		*) return "${SX_EX_USAGE}";;
	esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_base_int 10 "${@}" || return

	__sx_num_is_int_fit_dec "${@}" || return
}

__sx_num_is_int_fit_dec() {
	__sx_num_is_int_fit_dec_bit_="${1}"
	shift

	for __sx_num_is_int_fit_dec_arg_ in "${@}"; do
		case "${__sx_num_is_int_fit_dec_arg_}" in
			-*) __sx_num_is_int_fit_dec_e_=8;;
			*) __sx_num_is_int_fit_dec_e_=7;;
		esac

		__sx_num_is_int_fit_dec_arg_=${__sx_num_is_int_fit_dec_arg_#[+-]}

		case "${__sx_num_is_int_fit_dec_bit_}" in
			8)
				case "${#__sx_num_is_int_fit_dec_arg_}" in
					[12]) continue;;
					3)
						case "${__sx_num_is_int_fit_dec_arg_}" in
							1[01]* | 12[0-${__sx_num_is_int_fit_dec_e_}]) continue;;
						esac
						;;
				esac
				;;
			16)
				case "${#__sx_num_is_int_fit_dec_arg_}" in
					[1-4]) continue;;
					5)
						case "${__sx_num_is_int_fit_dec_arg_}" in
							[12]* | 3[01]* | 32[0-6]* | 327[0-5]* | \
							3276[0-${__sx_num_is_int_fit_dec_e_}]) continue;;
						esac
						;;
				esac
				;;
			32)
				case "${#__sx_num_is_int_fit_dec_arg_}" in
					[1-9]) continue;;
					10)
						case "${__sx_num_is_int_fit_dec_arg_}" in
							1* | 20* | 21[0-3]* | 214[0-6]* | 2147[0-3]* | 21474[0-7]* | \
							214748[0-2]* | 2147483[0-5]* | 21474836[0-3]* | \
							214748364[0-${__sx_num_is_int_fit_dec_e_}]) continue;;
						esac
						;;
				esac
				;;
			64)
				case "${#__sx_num_is_int_fit_dec_arg_}" in
					[1-9] | 1[0-8]) continue;;
					19)
						case "${__sx_num_is_int_fit_dec_arg_}" in
							[1-8]* | 9[01]* | 92[01]* | 922[0-2]* | 9223[0-2]* | \
							92233[0-6]* | 922337[01]* | 92233720[0-2]* | 922337203[0-5]* |\
							9223372036[0-7]* | 92233720368[0-4]* | 922337203685[0-3]* | \
							9223372036854[0-6]* | 92233720368547[0-6]* | \
							922337203685477[0-4]* | 9223372036854775[0-7]* | \
							922337203685477580[0-${__sx_num_is_int_fit_dec_e_}]) continue;;
						esac
						;;
				esac
				;;
			128)
				case "${#__sx_num_is_int_fit_dec_arg_}" in
					[1-9] | [12][0-9] | 3[0-8]) continue;;
					39)
						case "${__sx_num_is_int_fit_dec_arg_}" in
							1[0-6]* | 1700* | 1701[0-3]* | 170140* | 1701410* | \
							1701411[0-7]* | 17014118[0-2]* | 170141183[0-3]* | \
							1701411834[0-5]* | 170141183460[0-3]* | 1701411834604[0-5]* | \
							17014118346046[0-8]* | 170141183460469[01]* | \
							1701411834604692[0-2]* | 170141183460469230* | \
							170141183460469231[0-6]* | 1701411834604692317[0-2]* | \
							170141183460469231730* | 170141183460469231731[0-5]* | \
							1701411834604692317316[0-7]* | 17014118346046923173168[0-6]* | \
							170141183460469231731687[0-2]* | \
							17014118346046923173168730[0-2]* | \
							170141183460469231731687303[0-6]* | \
							17014118346046923173168730370* | \
							17014118346046923173168730371[0-4]* | \
							170141183460469231731687303715[0-7]* | \
							1701411834604692317316873037158[0-7]* | \
							17014118346046923173168730371588[0-3]* | \
							1701411834604692317316873037158840* | \
							17014118346046923173168730371588410[0-4]* | \
							170141183460469231731687303715884105[0-6]* | \
							1701411834604692317316873037158841057[01]* | \
							17014118346046923173168730371588410572[0-${__sx_num_is_int_fit_dec_e_}]) continue;;
						esac
						;;
				esac
				;;
		esac

		unset __sx_num_is_int_fit_dec_bit_ __sx_num_is_int_fit_dec_arg_ __sx_num_is_int_fit_dec_e_
		return 1
	done

	unset __sx_num_is_int_fit_dec_bit_ __sx_num_is_int_fit_dec_arg_ __sx_num_is_int_fit_dec_e_
}

### sx_num_is_int_width - すべての引数が指定されたビット幅の符号付き整数の範囲内か確認する
##
## 使い方:
##   sx_num_is_int_width ビット幅 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定されたビット幅 (8, 16, 32, 64, 128) において、
##   後続のすべての引数が、その範囲内の符号付き整数であるか確認する。
##   8進数 (0...)、16進数 (0x...) 形式もサポートする。
##
## 終了ステータス:
##    0  すべて範囲内である (SX_EX_OK)
##    1  範囲外、または整数ではない値が含まれる
##   64  ビット幅指定が不正 (SX_EX_USAGE)
sx_num_is_int_width() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_width "${@}" || return; return 0;; esac

	case "${1-}" in
		8 | 16 | 32 | 64 | 128) ;;
		*) return "${SX_EX_USAGE}";;
	esac

	__sx_num_is_int_width "${@}" || return
}

### __sx_num_is_int_width - すべての引数が指定されたビット幅の符号付き整数の範囲内か確認する（内部用）
__sx_num_is_int_width() {
	__sx_num_is_int_width_bits_="${1}"
	shift

	sx_num_is_int "${@}" || {
		unset __sx_num_is_int_width_bits_
		return 1
	}

	set -- "${__sx_num_is_int_width_bits_}" "${@}"
	unset __sx_num_is_int_width_bits_

	__sx_num_is_int_fit "${@}" || return
}

### sx_num_is_int_fit - すべての引数が指定されたビット幅の符号付き整数の範囲内か確認する
##
## 使い方:
##   sx_num_is_int_fit ビット幅 [整数1 [整数2 ...]]
##
## 説明:
##   第1引数で指定されたビット幅の符号付き整数として、
##   後続のすべての引数が、その範囲内の符号付き整数であるか確認する。
##   8進数 (0...)、16進数 (0x...) 形式もサポートする。
##
## 終了ステータス:
##    0  すべて範囲内である (SX_EX_OK)
##    1  範囲内に収まらない値が含まれる（ビット幅は正しい）
##   64  ビット幅指定が不正、または整数として不正な値が含まれる (SX_EX_USAGE)
sx_num_is_int_fit() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_fit "${@}" || return; return 0;; esac

	case "${1-}" in
		8 | 16 | 32 | 64 | 128) ;;
		*) return "${SX_EX_USAGE}";;
	esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_int "${@}" || return

	__sx_num_is_int_fit "${@}" || return
}

### __sx_num_is_int_fit - 指定されたビット幅の符号付き整数の範囲内か確認する（内部ロジック）
__sx_num_is_int_fit() {
	__sx_num_is_int_fit_bit_="${1}"
	shift

	for __sx_num_is_int_fit_arg_ in "${@}"; do
		# $1: 値（符号正規化）, $2: 数値部分の長さ
		set -- "${__sx_num_is_int_fit_arg_#+}" "${#__sx_num_is_int_fit_arg_}"
		case "${1}" in +* | -*)
			set -- "${1}" "$((${2} - 1))"
		esac

		case "${1}" in
			0[Xx]* | -0[Xx]*)
			# 基数16のパラメータ計算
			: ${__sx_num_is_int_fit_xlen_=$((__sx_num_is_int_fit_bit_ / 4 + 2))}

				if
					M_NUM_LT([|__sx_num_is_int_fit_xlen_|], [|${2}|]) || {
						M_STR_EQ([|"${__sx_num_is_int_fit_xlen_}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[Xx][9ABCDEFabcdef]*|], [|-0[Xx]8*[!0]*|], [|0[Xx][89ABCDEFabcdef]*|])
					}
				then
					unset __sx_num_is_int_fit_arg_ __sx_num_is_int_fit_bit_ __sx_num_is_int_fit_xlen_ __sx_num_is_int_fit_olenn_ __sx_num_is_int_fit_oleadn_ __sx_num_is_int_fit_olenp_ __sx_num_is_int_fit_oleadp_
					return 1
				fi
				;;
			0?* | -0?*)
				# 基数8のパラメータ計算
				: ${__sx_num_is_int_fit_olenn_=$(((__sx_num_is_int_fit_bit_ - 1) / 3 + 2))}
				: ${__sx_num_is_int_fit_oleadn_=$((1 << ((__sx_num_is_int_fit_bit_ - 1) % 3)))}
				: ${__sx_num_is_int_fit_olenp_=$((__sx_num_is_int_fit_olenn_ - (__sx_num_is_int_fit_oleadn_ == 1)))}
				: ${__sx_num_is_int_fit_oleadp_=$((__sx_num_is_int_fit_oleadn_ == 1 ? 7 : __sx_num_is_int_fit_oleadn_ - 1))}

				# $3: 制限長さ, $4: 制限先頭文字
				case "${1}" in
					-*) set -- "${1}" "${2}" "${__sx_num_is_int_fit_olenn_}" "${__sx_num_is_int_fit_oleadn_}";;
					*)  set -- "${1}" "${2}" "${__sx_num_is_int_fit_olenp_}" "${__sx_num_is_int_fit_oleadp_}";;
				esac

				if
					M_NUM_LT([|${3}|], [|${2}|]) || {
						M_STR_EQ([|"${3}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[!1-${4}]*|], [|-0${4}*[!0]*|], [|0[!1-${4}-]*|])
					}
				then
					unset __sx_num_is_int_fit_arg_ __sx_num_is_int_fit_bit_ __sx_num_is_int_fit_xlen_ __sx_num_is_int_fit_olenn_ __sx_num_is_int_fit_oleadn_ __sx_num_is_int_fit_olenp_ __sx_num_is_int_fit_oleadp_
					return 1
				fi
				;;
			*)
				__sx_num_is_int_fit_dec "${__sx_num_is_int_fit_bit_}" "${__sx_num_is_int_fit_arg_}" || {
					unset __sx_num_is_int_fit_arg_ __sx_num_is_int_fit_bit_ __sx_num_is_int_fit_xlen_ __sx_num_is_int_fit_olenn_ __sx_num_is_int_fit_oleadn_ __sx_num_is_int_fit_olenp_ __sx_num_is_int_fit_oleadp_
					return 1
				}
				;;
			esac
	done

	unset __sx_num_is_int_fit_arg_ __sx_num_is_int_fit_bit_ __sx_num_is_int_fit_xlen_ __sx_num_is_int_fit_olenn_ __sx_num_is_int_fit_oleadn_ __sx_num_is_int_fit_olenp_ __sx_num_is_int_fit_oleadp_
}

### sx_num_is_nat0 - すべての引数が 0 以上の自然数（符号なし整数） であるか確認する
##
## 使い方:
##   sx_num_is_nat0 [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる
sx_num_is_nat0() {
	for __sx_num_is_nat0_arg in "${@}"; do
		case "${__sx_num_is_nat0_arg}" in
			0[Xx]*) __sx_num_is_base_nat0 16 "${__sx_num_is_nat0_arg}";;
			0?*) __sx_num_is_base_nat0 8 "${__sx_num_is_nat0_arg}";;
			*) __sx_num_is_base_nat0 10 "${__sx_num_is_nat0_arg}";;
		esac || {
			unset __sx_num_is_nat0_arg
			return 1
		}
	done

	unset __sx_num_is_nat0_arg
}

### sx_num_is_nat1 - すべての引数が 1 以上の自然数（符号なし整数） であるか確認する
##
## 使い方:
##   sx_num_is_nat1 [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて 1 以上の自然数である (SX_EX_OK)
##    1  1 以上の自然数ではない値が含まれる
sx_num_is_nat1() {
	for __sx_num_is_nat1_arg in "${@}"; do
		case "${__sx_num_is_nat1_arg}" in
			0[Xx]*) __sx_num_is_base_nat1 16 "${__sx_num_is_nat1_arg}";;
			0?*) __sx_num_is_base_nat1 8 "${__sx_num_is_nat1_arg}";;
			*) __sx_num_is_base_nat1 10 "${__sx_num_is_nat1_arg}";;
		esac || {
			unset __sx_num_is_nat1_arg
			return 1
		}
	done

	unset __sx_num_is_nat1_arg
}

### sx_num_is_nint - すべての引数が負の整数であるか確認する
##
## 使い方:
##   sx_num_is_nint [文字列1 [文字列2 ...]]
##
## 説明:
##   負の符号（-）を必須で持ち、-1 以下の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて負の整数である (SX_EX_OK)
##    1  負の整数ではない値が含まれる
sx_num_is_nint() {
	for __sx_num_is_nint_arg in "${@}"; do
		case "${__sx_num_is_nint_arg}" in
			-*) sx_num_is_nat1 "${__sx_num_is_nint_arg#-}";;
			*) ! :;;
		esac || {
			unset __sx_num_is_nint_arg
			return 1
		}
	done

	unset __sx_num_is_nint_arg
}

### sx_num_is_nnint - すべての引数が非負整数（0以上の整数）であるか確認する
##
## 使い方:
##   sx_num_is_nnint [文字列1 [文字列2 ...]]
##
## 説明:
##   0（+0, -0 を含む）または正の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて非負整数である (SX_EX_OK)
##    1  非負整数ではない値が含まれる
sx_num_is_nnint() {
	for __sx_num_is_nnint_arg in "${@}"; do
		case "${__sx_num_is_nnint_arg}" in
			00 | [+-]00 | 0 | [+-]0 | 0[Xx]0 | [+-]0[Xx]0) continue;;
		esac

		sx_num_is_pint "${__sx_num_is_nnint_arg}" || {
			unset __sx_num_is_nnint_arg
			return 1
		}
	done

	unset __sx_num_is_nnint_arg
}

### sx_num_is_npint - すべての引数が非正整数（0以下の整数）であるか確認する
##
## 使い方:
##   sx_num_is_npint [文字列1 [文字列2 ...]]
##
## 説明:
##   0（+0, -0 を含む）または負の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて非正整数である (SX_EX_OK)
##    1  非正整数ではない値が含まれる
sx_num_is_npint() {
	for __sx_num_is_npint_arg in "${@}"; do
		case "${__sx_num_is_npint_arg}" in
			00 | [+-]00 | 0 | [+-]0 | 0[Xx]0 | [+-]0[Xx]0) continue;;
		esac

		sx_num_is_nint "${__sx_num_is_npint_arg}" || {
			unset __sx_num_is_npint_arg
			return 1
		}
	done

	unset __sx_num_is_npint_arg
}

### sx_num_is_pint - すべての引数が正の整数であるか確認する
##
## 使い方:
##   sx_num_is_pint [文字列1 [文字列2 ...]]
##
## 説明:
##   任意で正の符号（+）を持つ、1 以上の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて正の整数である (SX_EX_OK)
##    1  正の整数ではない値が含まれる
sx_num_is_pint() {
	for __sx_num_is_pint_arg in "${@}"; do
		sx_num_is_nat1 "${__sx_num_is_pint_arg#+}" || {
			unset __sx_num_is_pint_arg
			return 1
		}
	done

	unset __sx_num_is_pint_arg
}

### sx_num_is_sx_float - すべての引数が安全な範囲の 10 進の実数表記であるか確認する
##
## 使い方:
##   sx_num_is_sx_float [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_float による検証に加えて、セキュリティ上の理由（DoS 対策）から、
##   指数の絶対値を 4 桁（9999）までに制限する。
##
## 終了ステータス:
##    0  すべて安全な 10 進の実数表記である (SX_EX_OK)
##    1  安全ではない、または 10 進の実数表記ではない値が含まれる
sx_num_is_sx_float() {
	for __sx_num_is_sx_float_arg in "${@}"; do
		case "${__sx_num_is_sx_float_arg}" in
			# DoS 対策: 指数の絶対値は 4 桁まで
			*[Ee][+-]?????* | *[Ee][!+-]????*) ! :;;
			*) sx_num_is_float "${__sx_num_is_sx_float_arg}";;
		esac || {
			unset __sx_num_is_sx_float_arg
			return 1
		}
	done

	unset __sx_num_is_sx_float_arg
}

### sx_num_is_sx_int - shcore の標準的な数値範囲（SX_CFG_NUM_RANGE）の整数か確認する
##
## 使い方:
##   sx_num_is_sx_int [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の整数である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_sx_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_sx_int "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_is_sx_int "${@}" || return
}

### __sx_num_is_sx_int - 設定された数値範囲に基づいて検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_sx_int [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_sx_int の内部実装。引数チェックは行わない。
__sx_num_is_sx_int() {
	__sx_num_is_int_width "${SX_CFG_NUM_RANGE}" "${@}" || return
}

### sx_num_is_sx_int_inv - shcore の標準的な数値範囲（SX_CFG_NUM_RANGE）で符号反転可能な整数か確認する
##
## 使い方:
##   sx_num_is_sx_int_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_sx_int と同様に SX_CFG_NUM_RANGE に基づいて整数を検証するが、
##   INT_MIN（符号反転が不可能な最小値）を許可しない。
##   すなわち -(2^(n-1)-1) ～ 2^(n-1)-1 の範囲の整数のみを受理する。
##
## 終了ステータス:
##    0  すべて範囲内の符号反転可能な整数である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_sx_int_inv() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_sx_int_inv "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_is_sx_int_inv "${@}" || return
}

### __sx_num_is_sx_int_inv - 符号反転可能な整数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_sx_int_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_sx_int_inv の内部実装。引数チェックは行わない。
__sx_num_is_sx_int_inv() {
	__sx_num_is_sx_int "${@}" || return

	eval "__sx_num_is_sx_int_inv_min_=\"\${SX_NUM_I${SX_CFG_NUM_RANGE}_MIN}\""

	for __sx_num_is_sx_int_inv_arg_ in "${@}"; do
		case "${__sx_num_is_sx_int_inv_arg_}" in "${__sx_num_is_sx_int_inv_min_}")
			unset __sx_num_is_sx_int_inv_min_ __sx_num_is_sx_int_inv_arg_
			return 1
		esac
	done

	unset __sx_num_is_sx_int_inv_min_ __sx_num_is_sx_int_inv_arg_
}

### sx_num_is_sx_nat0 - shcore の標準的な数値範囲（SX_CFG_NUM_RANGE）の自然数（0以上）か確認する
##
## 使い方:
##   sx_num_is_sx_nat0 [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の自然数である (SX_EX_OK)
##    1  範囲外、または自然数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_sx_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_sx_nat0 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_is_sx_nat0 "${@}" || return
}

### __sx_num_is_sx_nat0 - 設定された数値範囲に基づいて自然数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_sx_nat0 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_sx_nat0 の内部実装。引数チェックは行わない。
__sx_num_is_sx_nat0() {
	sx_num_is_nat0 "${@}" || return
	__sx_num_is_int_fit "${SX_CFG_NUM_RANGE}" "${@}" || return
}

### sx_num_is_sx_nat1 - shcore の標準的な数値範囲（SX_CFG_NUM_RANGE）の自然数（1以上）か確認する
##
## 使い方:
##   sx_num_is_sx_nat1 [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の 1 以上の自然数である (SX_EX_OK)
##    1  範囲外、または 1 以上の自然数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_sx_nat1() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_sx_nat1 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_is_sx_nat1 "${@}" || return
}

### __sx_num_is_sx_nat1 - 設定された数値範囲に基づいて 1 以上の自然数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_sx_nat1 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_sx_nat1 の内部実装。引数チェックは行わない。
__sx_num_is_sx_nat1() {
	sx_num_is_nat1 "${@}" || return
	__sx_num_is_int_fit "${SX_CFG_NUM_RANGE}" "${@}" || return
}

### sx_num_is_sx_num - すべての引数が有効な数値（整数または実数）であるか確認する
##
## 使い方:
##   sx_num_is_sx_num [文字列1 [文字列2 ...]]
##
## 説明:
##   引数が 16進数または 8進数の形式（0x または 0[0-9] で始まる）である場合は
##   sx_num_is_sx_int で、それ以外の場合は sx_num_is_sx_float で検証を行う。
##
## 終了ステータス:
##    0  すべて有効な数値である (SX_EX_OK)
##    1  有効な数値ではない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_sx_num() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_sx_num "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_is_sx_num "${@}" || return
}

### __sx_num_is_sx_num - すべての引数が有効な数値形式であるか検証する（内部用）
##
## 使い方:
##   __sx_num_is_sx_num [文字列1 [文字列2 ...]]
##
## 説明:
##   引数が 16進数または 8進数の形式である場合は __sx_num_is_sx_int で、
##   それ以外の場合は sx_num_is_sx_float で検証を行う。
##
## 終了ステータス:
##    0  すべて有効な数値である (SX_EX_OK)
##    1  有効な数値ではない値が含まれる
__sx_num_is_sx_num() {
	for __sx_num_is_sx_num_arg_ in "${@}"; do
		case "${__sx_num_is_sx_num_arg_}" in
			*[Xx]* | [+-]0[0-9]* | 0[0-9]*) __sx_num_is_sx_int "${__sx_num_is_sx_num_arg_}";;
			*) sx_num_is_sx_float "${__sx_num_is_sx_num_arg_}";;
		esac || {
			unset __sx_num_is_sx_num_arg_
			return 1
		}
	done

	unset __sx_num_is_sx_num_arg_
}

### sx_num_norm - 数値を10進固定小数点形式に正規化する
##
## 使い方:
##   sx_num_norm バインド形式 [数値1 [数値2 ...]]
##
## 説明:
##   引数で指定された各数値を、10進固定小数点形式に正規化し、バインド形式に従って
##   変数に代入する。
##   正規化の内容：
##   - 16進数（0x...）や8進数（0...）を10進整数に変換。
##   - 指数表記（1.2e+3）を固定小数点形式（1200）に展開。
##   - 小数点以下の不要な '0' を削除（6.0 -> 6, 1.20 -> 1.2）。
##   - 符号（+ / -）は維持される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正: 無効なバインド形式、または数値形式が正しくない (SX_EX_USAGE)
##   77  結果変数が読み取り専用 (SX_EX_NOPERM)
sx_num_norm() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_norm "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return

	__sx_num_norm_bind="${1}"
	shift

	sx_num_is_sx_num "${@}" || {
		unset __sx_num_norm_bind
		return "${SX_EX_USAGE}"
	}

	__sx_num_norm "${__sx_num_norm_bind}" "${@}"
	unset __sx_num_norm_bind
}

define([|V|], [|__sx_num_norm_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(arg) V(in) V(mnt) V(dig) V(flen) V(shift) V(dlen) __M_BIND_USEVAR|])dnl

### __sx_num_norm - 数値を10進固定小数点形式に正規化する（内部用）
##
## 使い方:
##   __sx_num_norm バインド形式 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_norm の内部実装。引数の検証は行わない。
__sx_num_norm() {
	__sx_var_bind_init "${1}"
	__sx_num_norm_bind_="${1}"
	__sx_num_norm_out_=

	shift

	for __sx_num_norm_arg_ in "${@}"; do
		__sx_num_norm_in_="${__sx_num_norm_arg_#[+-]}"

		case "${__sx_num_norm_in_}" in
			*[Ee]*)
				# 指数表記の展開
				__sx_num_norm_mnt_="${__sx_num_norm_in_%%[Ee]*}"
				__sx_num_norm_dig_="${__sx_num_norm_mnt_%%.*}"

				case "${__sx_num_norm_mnt_}" in
					*.*)
						__sx_num_norm_flen_=$((${#__sx_num_norm_mnt_} - ${#__sx_num_norm_dig_} - 1))
						__sx_num_norm_dig_="${__sx_num_norm_dig_}${__sx_num_norm_mnt_#*.}"
						;;
					*) __sx_num_norm_flen_=0;;
				esac

				__sx_num_norm_shift_=$((${__sx_num_norm_in_#*[Ee]} - __sx_num_norm_flen_))
					__sx_num_norm_dlen_="${#__sx_num_norm_dig_}"

				if M_NUM_LE([|0|], [|__sx_num_norm_shift_|]); then
					SX_CFG_UNSET_SOFT=2 __sx_str_pad __sx_num_norm_in_ "${__sx_num_norm_dig_}" "-$((__sx_num_norm_dlen_ + __sx_num_norm_shift_))" 0
				else
					: $((__sx_num_norm_shift_ *= -1))

					if M_NUM_LT([|__sx_num_norm_shift_|], [|__sx_num_norm_dlen_|]); then
						SX_CFG_UNSET_SOFT=2 __sx_str_splice __sx_num_norm_in_ "${__sx_num_norm_dig_}" "$((__sx_num_norm_dlen_ - __sx_num_norm_shift_))" 0 .
					else
						SX_CFG_UNSET_SOFT=2 __sx_str_pad __sx_num_norm_in_ "${__sx_num_norm_dig_}" "${__sx_num_norm_shift_}" 0
						__sx_num_norm_in_=".${__sx_num_norm_in_}"
					fi
				fi

				__sx_num_norm_in_="${__sx_num_norm_in_#"${__sx_num_norm_in_%%[!0]*}"}"

				case "${__sx_num_norm_in_}" in .*)
					__sx_num_norm_in_="0${__sx_num_norm_in_}"
				esac
				;;
			*[Xx]* | 0[0-9]*) : "$((__sx_num_norm_in_ += 0))";;
		esac

		# 小数点以下のクリーンアップ
		case "${__sx_num_norm_in_}" in *.*)
			__sx_num_norm_in_="${__sx_num_norm_in_%"${__sx_num_norm_in_##*[!0]}"}"
			__sx_num_norm_in_="${__sx_num_norm_in_%.}"
		esac

		case "${__sx_num_norm_in_}" in '' | 0)
			__sx_num_norm_arg_=
		esac

		__M_BIND_UNQUOTE([|__sx_num_norm|], [|"${__sx_num_norm_arg_%%[!-]*}${__sx_num_norm_in_:-0}"|], CLEANUP)
	done

	eval ${__sx_num_norm_out_:+"${__sx_num_norm_bind_}=\"\${__sx_num_norm_out_}\""}

	unset CLEANUP
}

### sx_num_range - 数値の範囲を生成する (Python range 互換)
##
## 使い方:
##   sx_num_range 結果変数名（またはバインド形式） 終了
##   sx_num_range 結果変数名（またはバインド形式） 開始 終了
##   sx_num_range 結果変数名（またはバインド形式） 開始 終了 増分
##
## 説明:
##   指定された範囲の数値をスペース区切りで生成し、結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   Python の range() と同様に、終了値は含まない (exclusive)。
##   引数が1つの場合は、0 から 終了 - 1 まで増分 1。
##   引数が2つの場合は、開始 から 終了 - 1 まで増分 1。
##   引数が3つの場合は、開始 から 終了 (exclusive) まで指定された 増分 で生成する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  書き込み不可 (SX_EX_NOPERM)
sx_num_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_range "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int "${2-}" ${3+"${3}"} ${4+"${4}"} || return

	case "$((${4-1}))" in 0)
		return "${SX_EX_USAGE}"
	esac

	__sx_num_range "${@}"
}

define([|V|], [|__sx_num_range_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(cur) __M_BIND_USEVAR|])dnl

### __sx_num_range - 数値の範囲を生成する（内部用）
##
## 使い方:
##   __sx_num_range 宛先 [引数...]
##
## 説明:
##   sx_num_range の内部実装。引数チェックを行わない。
__sx_num_range() {
	__sx_var_bind_init "${1}"
	__sx_num_range_bind_="${1}"
	__sx_num_range_out_=
	shift

	case "${#}" in
		1) set -- 0 "${1}" 1;;
		2) set -- "${1}" "${2}" 1;;
		*) set -- "${1}" "${2}" "${3-1}";;
	esac

	__sx_num_range_cur_="${1}"

	if M_NUM_LT([|0|], [|${3}|]); then
		while M_NUM_LT([|__sx_num_range_cur_|], [|${2}|]); do
			__M_BIND_UNQUOTE([|__sx_num_range|], [|"${__sx_num_range_cur_}"|], CLEANUP)
			: $((__sx_num_range_cur_ += ${3}))
		done
	else
		while M_NUM_LT([|${2}|], [|${__sx_num_range_cur_}|]); do
			__M_BIND_UNQUOTE([|__sx_num_range|], [|"${__sx_num_range_cur_}"|], CLEANUP)
			: $((__sx_num_range_cur_ += ${3}))
		done
	fi

	eval ${__sx_num_range_out_:+"${__sx_num_range_bind_}=\"\${__sx_num_range_out_}\""}

	unset CLEANUP
}

### sx_num_rel - 数値間の関係を確認する
##
## 使い方:
##   sx_num_rel [数値1 [演算子1 数値2 ...]]
##
## 説明:
##   数値と演算子を交互に指定し、すべての関係が満たされるかを確認する。
##   演算子には以下が使用可能：
##     eq, ==   : 等しい
##     ne, !=  : 等しくない
##     lt, <   : 未満
##     le, <=  : 以下
##     gt, >   : より大きい
##     ge, >=  : 以上
##
## 終了ステータス:
##    0  すべての条件を満たす (SX_EX_OK)
##    1  条件を満たさない引数が含まれる
##   64  引数不正 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_rel() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_rel "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	for __sx_num_rel_arg in "${@}"; do
		case "${__sx_num_rel_arg}" in
			eq | '==' | ne | '!=' | lt | '<' | le | '<=' | gt | '>' | ge | '>=') continue;;
		esac

		__sx_num_is_sx_num "${__sx_num_rel_arg}" || {
			unset __sx_num_rel_arg
			return "${SX_EX_USAGE}"
		}
	done

	unset __sx_num_rel_arg

	__sx_num_rel "${@}" || return
}

### __sx_num_rel - 数値間の関係を確認する（内部用）
##
## 使い方:
##   __sx_num_rel [数値 | 演算子 ...]
##
## 説明:
##   sx_num_rel の内部実装。
##   引数チェックを行わずに数値と演算子の関係を順次評価する。
__sx_num_rel() {
	__sx_num_rel_op_='eq'

	for __sx_num_rel_arg_ in "${@}"; do
		case "${__sx_num_rel_arg_}" in
			eq | '==') __sx_num_rel_op_=eq;;
			ne | '!=') __sx_num_rel_op_=ne;;
			lt | '<')  __sx_num_rel_op_=lt;;
			le | '<=') __sx_num_rel_op_=le;;
			gt | '>')  __sx_num_rel_op_=gt;;
			ge | '>=') __sx_num_rel_op_=ge;;
			*) ! :;;
		esac && continue

		__sx_num_rel_classify "${__sx_num_rel_arg_}" || __sx_num_rel_rcls_="${?}"

		case "${__sx_num_rel_rcls_}" in
			1) : $((__sx_num_rel_arg_ += 0));;
			2) __sx_num_rel_arg_="${__sx_num_rel_arg_#+}";;
			*)
				SX_CFG_UNSET_SOFT=2 __sx_num_norm __sx_num_rel_arg_ "${__sx_num_rel_arg_}"
				__sx_num_rel_classify "${__sx_num_rel_arg_}" || __sx_num_rel_rcls_="${?}"
				;;
		esac

		case "${__sx_num_rel_lhs_+X}" in X)
			case "${__sx_num_rel_lcls_}:${__sx_num_rel_rcls_}" in
				1:1) __sx_num_cmp_arith "${__sx_num_rel_lhs_}" "${__sx_num_rel_arg_}";;
				*) __sx_num_cmp_fixed "${__sx_num_rel_lhs_}" "${__sx_num_rel_arg_}";;
			esac || case "${__sx_num_rel_op_}:${?}" in
				eq:2 | ne:1 | ne:3 | lt:1 | le:1 | le:2 | gt:3 | ge:2 | ge:3) ;;
				*)
					unset __sx_num_rel_op_ __sx_num_rel_lhs_ __sx_num_rel_lcls_ __sx_num_rel_rcls_ __sx_num_rel_arg_
					return 1
					;;
			esac
		esac

		__sx_num_rel_lcls_="${__sx_num_rel_rcls_}"
		__sx_num_rel_lhs_="${__sx_num_rel_arg_}"
	done

	unset __sx_num_rel_op_ __sx_num_rel_lhs_ __sx_num_rel_lcls_ __sx_num_rel_rcls_ __sx_num_rel_arg_
}

### __sx_num_rel_classify - 比較方式を分類する（内部用）
##
## 終了ステータス:
##   1  arith (算術展開比較)
##   2  dec   (10進整数文字列比較)
##   3  norm  (正規化数値比較)
__sx_num_rel_classify() {
	case "${1}" in
		*.* | *[Ee]*) return 3;;
		*0[Xx]* | 0[0-9]* | [+-]0[0-9]*) return 1;;
	esac

	__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${1}" || return 2

	return 1
}

### sx_num_int_add_abs - 複数の絶対値をチャンク加算する
##
## 使い方:
##   sx_num_int_add_abs 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を加算する。
##   引数の検証を行い、符号なし整数でない場合はエラーとする。
##   逐次方式でアキュムレータに各数値を順次加算する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 数値以外、または符号付き整数が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|V|], [|__sx_num_int_add_abs_$1|])dnl
define([|CLEANUP|], [|V(res)|])dnl

sx_num_int_add_abs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_add_abs "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_add_abs_res="${1}"
	shift

	sx_num_is_base_nat0 10 "${@}" || {
		unset CLEANUP
		return "${SX_EX_USAGE}"
	}

	__sx_num_int_add_abs "${__sx_num_int_add_abs_res}" "${@}"
	unset CLEANUP
}

### __sx_num_int_add_abs - 複数の絶対値をチャンク加算する（内部用）
##
## 使い方:
##   __sx_num_int_add_abs 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を加算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   逐次方式でアキュムレータに各数値を順次加算する。

define([|V|], [|__sx_num_int_add_abs_$1_|])dnl
define([|CLEANUP|], [|V(res) V(qm) V(carry) V(out) V(rem1) V(rem2) V(ch1) V(ch2) V(tmp) V(wlen) V(b)|])dnl

__sx_num_int_add_abs() {
	__sx_num_int_add_abs_res_="${1}"
	__sx_num_int_add_abs_rem1_="${2-0}"
	shift "$((1 + 0${2+1}))"

	# チャンク処理定数（事前定義値から選択）
	eval "__sx_num_int_add_abs_wlen_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_WLEN}\" __sx_num_int_add_abs_qm_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_QM}\" __sx_num_int_add_abs_b_=\"1\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_ZR}\""

	for __sx_num_int_add_abs_rem2_ in "${@}"; do
		# (2) 右端→左端 チャンク処理
		__sx_num_int_add_abs_carry_=0
		__sx_num_int_add_abs_out_=

		while
			# rem1 からチャンク抽出
			case "${__sx_num_int_add_abs_rem1_}" in
				${__sx_num_int_add_abs_qm_}?*)
					__sx_num_int_add_abs_tmp_="${__sx_num_int_add_abs_rem1_%${__sx_num_int_add_abs_qm_}}"
					__sx_num_int_add_abs_ch1_="${__sx_num_int_add_abs_rem1_#"${__sx_num_int_add_abs_tmp_}"}"
					__sx_num_int_add_abs_rem1_="${__sx_num_int_add_abs_tmp_}"

					case "${__sx_num_int_add_abs_ch1_}" in 0*)
						__sx_num_int_add_abs_ch1_="${__sx_num_int_add_abs_ch1_#"${__sx_num_int_add_abs_ch1_%%[!0]*}"}"
					esac
					;;
				*)
					__sx_num_int_add_abs_ch1_="${__sx_num_int_add_abs_rem1_}"
					__sx_num_int_add_abs_rem1_=
					;;
			esac

			# rem2 からチャンク抽出
			case "${__sx_num_int_add_abs_rem2_}" in
				${__sx_num_int_add_abs_qm_}?*)
					__sx_num_int_add_abs_tmp_="${__sx_num_int_add_abs_rem2_%${__sx_num_int_add_abs_qm_}}"
					__sx_num_int_add_abs_ch2_="${__sx_num_int_add_abs_rem2_#"${__sx_num_int_add_abs_tmp_}"}"
					__sx_num_int_add_abs_rem2_="${__sx_num_int_add_abs_tmp_}"

					case "${__sx_num_int_add_abs_ch2_}" in 0*)
						__sx_num_int_add_abs_ch2_="${__sx_num_int_add_abs_ch2_#"${__sx_num_int_add_abs_ch2_%%[!0]*}"}"
					esac
					;;
				*)
					__sx_num_int_add_abs_ch2_="${__sx_num_int_add_abs_rem2_}"
					__sx_num_int_add_abs_rem2_=
					;;
			esac

			__sx_num_int_add_abs_tmp_=$((${__sx_num_int_add_abs_ch1_:-0} + ${__sx_num_int_add_abs_ch2_:-0} + __sx_num_int_add_abs_carry_))
			__sx_num_int_add_abs_carry_=$((__sx_num_int_add_abs_wlen_ < ${#__sx_num_int_add_abs_tmp_}))

			case "${#__sx_num_int_add_abs_rem1_}:${#__sx_num_int_add_abs_rem2_}:${__sx_num_int_add_abs_carry_}" in
				0:0:[01]) __sx_num_int_add_abs_rem1_="${__sx_num_int_add_abs_tmp_}${__sx_num_int_add_abs_out_}" && ! :;;
				[1-9]*:0:0 | 0:[1-9]*:0)
					case "${__sx_num_int_add_abs_tmp_}" in
						${__sx_num_int_add_abs_qm_}) __sx_num_int_add_abs_rem1_="${__sx_num_int_add_abs_rem1_}${__sx_num_int_add_abs_rem2_}${__sx_num_int_add_abs_tmp_}${__sx_num_int_add_abs_out_}";;
						*)
							# ゼロ埋めして前置（片方のチャンクが先頭ゼロ除去で短くなった場合の桁揃え）
							: "$(( __sx_num_int_add_abs_tmp_ += __sx_num_int_add_abs_b_))"
							__sx_num_int_add_abs_rem1_="${__sx_num_int_add_abs_rem1_}${__sx_num_int_add_abs_rem2_}${__sx_num_int_add_abs_tmp_#1}${__sx_num_int_add_abs_out_}"
							;;
						esac && ! :;;
				*:0)
					case "${__sx_num_int_add_abs_tmp_}" in
						${__sx_num_int_add_abs_qm_}) __sx_num_int_add_abs_out_="${__sx_num_int_add_abs_tmp_}${__sx_num_int_add_abs_out_}";;
						*)
							# ゼロ埋めして前置
							: "$((__sx_num_int_add_abs_tmp_ += __sx_num_int_add_abs_b_))"
							__sx_num_int_add_abs_out_="${__sx_num_int_add_abs_tmp_#1}${__sx_num_int_add_abs_out_}"
							;;
					esac
					;;
				*) __sx_num_int_add_abs_out_="${__sx_num_int_add_abs_tmp_#?}${__sx_num_int_add_abs_out_}";;
			esac
		do :; done
	done

	__sx_var_set "${__sx_num_int_add_abs_res_}=${__sx_num_int_add_abs_rem1_}"

	unset CLEANUP
}

### sx_num_int_sub_abs - 2つの絶対値の差（被減数 - 減数）を計算する
##
## 使い方:
##   sx_num_int_sub_abs 結果変数名 被減数 減数
##
## 説明:
##   符号なし10進整数の減算（被減数 - 減数）を行う。
##   引数の検証を行い、すべて符号なし整数（nat0）であることを確認する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 数値以外、符号付き整数、または被減数 &lt; 減数
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|V|], [|__sx_num_int_sub_abs_$1|])dnl
define([|CLEANUP|], [|V(res)|])dnl

sx_num_int_sub_abs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_sub_abs "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_sub_abs_res="${1}"
	shift

	sx_num_is_base_nat0 10 "${@}" || {
		unset CLEANUP
		return "${SX_EX_USAGE}"
	}

	__sx_num_cmp_nat0 "${1}" "${2}" || case "${?}" in 1)
		unset CLEANUP
		return "${SX_EX_USAGE}"
	esac

	__sx_num_int_sub_abs "${__sx_num_int_sub_abs_res}" "${@}"
	unset CLEANUP
}

### __sx_num_int_sub_abs - 絶対値のチャンク減算を行う（内部用）
##
## 使い方:
##   __sx_num_int_sub_abs 結果変数名 被減数 減数
##
## 説明:
##   符号なし10進整数の絶対値（被減数 - 減数）を減算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   被減数 >= 減数 が保証されていること。

define([|V|], [|__sx_num_int_sub_abs_$1_|])dnl
define([|CLEANUP|], [|V(res) V(qm) V(borrow) V(out) V(rem1) V(rem2) V(ch1) V(ch2) V(tmp) V(b)|])dnl

__sx_num_int_sub_abs() {
	__sx_num_int_sub_abs_res_="${1}"
	__sx_num_int_sub_abs_rem1_="${2-0}"
	__sx_num_int_sub_abs_rem2_="${3-0}"
	__sx_num_int_sub_abs_borrow_=0
	__sx_num_int_sub_abs_out_=

	eval "__sx_num_int_sub_abs_qm_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_QM}\" __sx_num_int_sub_abs_b_=\"1\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_ZR}\""

	while
		case "${__sx_num_int_sub_abs_rem1_}" in
			${__sx_num_int_sub_abs_qm_}?*)
				__sx_num_int_sub_abs_tmp_="${__sx_num_int_sub_abs_rem1_%${__sx_num_int_sub_abs_qm_}}"
				__sx_num_int_sub_abs_ch1_="${__sx_num_int_sub_abs_rem1_#"${__sx_num_int_sub_abs_tmp_}"}"
				__sx_num_int_sub_abs_rem1_="${__sx_num_int_sub_abs_tmp_}"
				case "${__sx_num_int_sub_abs_ch1_}" in 0*)
					__sx_num_int_sub_abs_ch1_="${__sx_num_int_sub_abs_ch1_#"${__sx_num_int_sub_abs_ch1_%%[!0]*}"}"
				esac
				;;
			*)
				__sx_num_int_sub_abs_ch1_="${__sx_num_int_sub_abs_rem1_}"
				__sx_num_int_sub_abs_rem1_=
				;;
		esac

		case "${__sx_num_int_sub_abs_rem2_}" in
			${__sx_num_int_sub_abs_qm_}?*)
				__sx_num_int_sub_abs_tmp_="${__sx_num_int_sub_abs_rem2_%${__sx_num_int_sub_abs_qm_}}"
				__sx_num_int_sub_abs_ch2_="${__sx_num_int_sub_abs_rem2_#"${__sx_num_int_sub_abs_tmp_}"}"
				__sx_num_int_sub_abs_rem2_="${__sx_num_int_sub_abs_tmp_}"
				case "${__sx_num_int_sub_abs_ch2_}" in 0*)
					__sx_num_int_sub_abs_ch2_="${__sx_num_int_sub_abs_ch2_#"${__sx_num_int_sub_abs_ch2_%%[!0]*}"}"
				esac
				;;
			*)
				__sx_num_int_sub_abs_ch2_="${__sx_num_int_sub_abs_rem2_}"
				__sx_num_int_sub_abs_rem2_=
				;;
		esac

		__sx_num_int_sub_abs_tmp_=$((${__sx_num_int_sub_abs_ch1_:-0} - ${__sx_num_int_sub_abs_ch2_:-0} - __sx_num_int_sub_abs_borrow_))
		__sx_num_int_sub_abs_borrow_=$((__sx_num_int_sub_abs_tmp_ < 0))

		case "${#__sx_num_int_sub_abs_rem1_}:${#__sx_num_int_sub_abs_rem2_}:${__sx_num_int_sub_abs_borrow_}" in
			0:0:0)
				# 両方の剰余が枯渇 → tmp_ が最上位桁、先頭ゼロ除去のみでゼロ埋め不要
				case "${__sx_num_int_sub_abs_tmp_}" in [!0]*)
					__sx_num_int_sub_abs_out_="${__sx_num_int_sub_abs_tmp_}${__sx_num_int_sub_abs_out_}"
				esac && ! :
				;;
			*:0:0)
				case "${__sx_num_int_sub_abs_tmp_}" in
					${__sx_num_int_sub_abs_qm_}*) __sx_num_int_sub_abs_out_="${__sx_num_int_sub_abs_rem1_}${__sx_num_int_sub_abs_tmp_}${__sx_num_int_sub_abs_out_}";;
					*)
						# rem2 のみ枯渇、rem1 に未処理チャンクあり → ゼロ埋めして桁揃え
						: "$((__sx_num_int_sub_abs_tmp_ += __sx_num_int_sub_abs_b_))"
						__sx_num_int_sub_abs_out_="${__sx_num_int_sub_abs_rem1_}${__sx_num_int_sub_abs_tmp_#1}${__sx_num_int_sub_abs_out_}"
						;;
				esac && ! :
				;;
			*:*:1) : "$((__sx_num_int_sub_abs_tmp_ += ${__sx_num_int_sub_abs_b_}))";&
			*)
				case "${__sx_num_int_sub_abs_tmp_}" in
					${__sx_num_int_sub_abs_qm_}*)  __sx_num_int_sub_abs_out_="${__sx_num_int_sub_abs_tmp_}${__sx_num_int_sub_abs_out_}";;
					*)
						: "$((__sx_num_int_sub_abs_tmp_ += __sx_num_int_sub_abs_b_))"
						__sx_num_int_sub_abs_out_="${__sx_num_int_sub_abs_tmp_#1}${__sx_num_int_sub_abs_out_}"
						;;
				esac
				;;
		esac
	do :; done

	__sx_var_set "${__sx_num_int_sub_abs_res_}=${__sx_num_int_sub_abs_out_:-0}"

	unset CLEANUP
}


### sx_num_int_mul_abs - 複数の絶対値を乗算する
##
## 使い方:
##   sx_num_int_mul_abs 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を乗算する。
##   引数の検証を行い、符号なし整数でない場合はエラーとする。
##   逐次方式でアキュムレータに各数値を順次乗算する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 数値以外、または符号付き整数が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|V|], [|__sx_num_int_mul_abs_$1|])dnl
define([|CLEANUP|], [|V(res)|])dnl

sx_num_int_mul_abs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_mul_abs "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_mul_abs_res="${1}"
	shift

	sx_num_is_base_nat0 10 "${@}" || {
		unset CLEANUP
		return "${SX_EX_USAGE}"
	}

	__sx_num_int_mul_abs "${__sx_num_int_mul_abs_res}" "${@}"
	unset CLEANUP
}

### __sx_num_int_mul_abs - 複数の絶対値を乗算する（内部用）
##
## 使い方:
##   __sx_num_int_mul_abs 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を乗算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   逐次方式でアキュムレータに各数値を順次乗算する。

define([|V|], [|__sx_num_int_mul_abs_$1_|])dnl
define([|CLEANUP|], [|V(res) V(a) V(b) V(endz) V(qm) V(shift) V(tmp) V(ch_a) V(ch_b) V(wlen_mul) V(max_ops) V(a_len) V(b_len) V(max_x) V(min_ops) V(opt_x) V(opt_y) V(x) V(y) V(ops) V(qchunk_a) V(qchunk_b) V(zchunk_a) V(zchunk_b) V(carry) V(g) V(fit) V(safe)|])dnl

__sx_num_int_mul_abs() {
	__sx_num_int_mul_abs_res_="${1}"
	__sx_num_int_mul_abs_a_="${2-1}"
	__sx_num_int_mul_abs_endz_=
	__sx_num_int_mul_abs_fit_=1
	shift "$((1 + 0${2+1}))"

	case "${__sx_num_int_mul_abs_a_}" in 0)
		set --
	esac

	eval "__sx_num_int_mul_abs_qm_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_QM}\" \
	      __sx_num_int_mul_abs_wlen_mul_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_WLEN}\" \
	      __sx_num_int_mul_abs_max_ops_=\"\${SX_NUM_I${SX_CFG_NUM_RANGE}_MAX}\""

	# safe_: 分割探索式の (len + (x - 1)) が INT_MAX を超えないための上限
	__sx_num_int_mul_abs_safe_="$((__sx_num_int_mul_abs_max_ops_ - __sx_num_int_mul_abs_wlen_mul_ + 2))"

	for __sx_num_int_mul_abs_b_ in "${@}"; do
		case "${__sx_num_int_mul_abs_b_}" in 0)
			__sx_num_int_mul_abs_a_=0
			__sx_num_int_mul_abs_endz_=
			break
		esac

		# 高速パス: 両因数が1語に収まればシェル算術で直接乗算
		case "${__sx_num_int_mul_abs_a_}${__sx_num_int_mul_abs_b_}" in
			${__sx_num_int_mul_abs_qm_}?*) ;;
			*)
				: "$((__sx_num_int_mul_abs_a_ *= __sx_num_int_mul_abs_b_))"
				continue
				;;
		esac

		# 末尾のゼロを一時分離し、後で結合する
		case "${__sx_num_int_mul_abs_a_}" in *0)
			__sx_num_int_mul_abs_tmp_="${__sx_num_int_mul_abs_a_##*[!0]}"
			__sx_num_int_mul_abs_a_="${__sx_num_int_mul_abs_a_%${__sx_num_int_mul_abs_tmp_}}"
			__sx_num_int_mul_abs_endz_="${__sx_num_int_mul_abs_endz_}${__sx_num_int_mul_abs_tmp_}"
		esac

		case "${__sx_num_int_mul_abs_b_}" in *0)
			__sx_num_int_mul_abs_tmp_="${__sx_num_int_mul_abs_b_##*[!0]}"
			__sx_num_int_mul_abs_b_="${__sx_num_int_mul_abs_b_%${__sx_num_int_mul_abs_tmp_}}"
			__sx_num_int_mul_abs_endz_="${__sx_num_int_mul_abs_endz_}${__sx_num_int_mul_abs_tmp_}"
		esac

		# 1の乗算をスキップ / 1語に収まらなければ多倍長処理へ
		case "${__sx_num_int_mul_abs_a_}:${__sx_num_int_mul_abs_b_}" in
			1:*) __sx_num_int_mul_abs_a_="${__sx_num_int_mul_abs_b_}";&
			*:1) ! :;;
			${__sx_num_int_mul_abs_qm_}??*) ;;
			*) ! : "$((__sx_num_int_mul_abs_a_ *= __sx_num_int_mul_abs_b_))"
		esac || continue

		# fit_: 桁数そのものが INT_MAX を超えると算術展開できないため、
		#       範囲内に収まる桁数かどうかを確認する
		__sx_num_int_mul_abs_a_len_="${#__sx_num_int_mul_abs_a_}"
		__sx_num_int_mul_abs_b_len_="${#__sx_num_int_mul_abs_b_}"

		case "${__sx_num_int_mul_abs_fit_}" in 1)
			__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${__sx_num_int_mul_abs_a_len_}" "${__sx_num_int_mul_abs_b_len_}" || __sx_num_int_mul_abs_fit_=0
		esac

		# 長い方を a に統一し、分割最適化の効果を最大化
		case "$((__sx_num_int_mul_abs_fit_ && __sx_num_int_mul_abs_a_len_ < __sx_num_int_mul_abs_b_len_))" in 1)
			__sx_num_int_mul_abs_tmp_="${__sx_num_int_mul_abs_b_}"
			__sx_num_int_mul_abs_b_="${__sx_num_int_mul_abs_a_}"
			__sx_num_int_mul_abs_a_="${__sx_num_int_mul_abs_tmp_}"
			__sx_num_int_mul_abs_a_len_="${#__sx_num_int_mul_abs_a_}"
			__sx_num_int_mul_abs_b_len_="${#__sx_num_int_mul_abs_b_}"
		esac

		# 安全: 桁数が算術展開可能な範囲内 → 全分割点を探索
		# 危険: 桁数が算術展開不能 or 範囲超過 → 均等分割にフォールバック
		if M_NUM_BOOL([|__sx_num_int_mul_abs_fit_ && __sx_num_int_mul_abs_a_len_ <= __sx_num_int_mul_abs_safe_ && __sx_num_int_mul_abs_b_len_ <= __sx_num_int_mul_abs_safe_|]); then
			__sx_num_int_mul_abs_max_x_="$((__sx_num_int_mul_abs_b_len_ < __sx_num_int_mul_abs_wlen_mul_ ? __sx_num_int_mul_abs_b_len_ : __sx_num_int_mul_abs_wlen_mul_ - 1))"
			__sx_num_int_mul_abs_min_ops_="${__sx_num_int_mul_abs_max_ops_}"
			__sx_num_int_mul_abs_opt_x_=1
			__sx_num_int_mul_abs_x_=1

			while M_NUM_LE([|__sx_num_int_mul_abs_x_|], [|__sx_num_int_mul_abs_max_x_|]); do
				__sx_num_int_mul_abs_y_=$((__sx_num_int_mul_abs_wlen_mul_ - __sx_num_int_mul_abs_x_))
				__sx_num_int_mul_abs_ops_=$((((__sx_num_int_mul_abs_b_len_ + (__sx_num_int_mul_abs_x_ - 1)) / __sx_num_int_mul_abs_x_) * ((__sx_num_int_mul_abs_a_len_ + (__sx_num_int_mul_abs_y_ - 1)) / __sx_num_int_mul_abs_y_)))

				case "$((__sx_num_int_mul_abs_ops_ < __sx_num_int_mul_abs_min_ops_))" in 1)
					__sx_num_int_mul_abs_min_ops_="${__sx_num_int_mul_abs_ops_}"
					__sx_num_int_mul_abs_opt_x_="${__sx_num_int_mul_abs_x_}"
				esac

				: "$((__sx_num_int_mul_abs_x_ += 1))"
			done
		else
			__sx_num_int_mul_abs_opt_x_=$(((__sx_num_int_mul_abs_wlen_mul_ + 1) / 2))
		fi

		# 最適分割サイズに基づきチャンク用 QM/ZR をロード
		__sx_num_int_mul_abs_opt_y_=$((__sx_num_int_mul_abs_wlen_mul_ - __sx_num_int_mul_abs_opt_x_))

		eval "__sx_num_int_mul_abs_qchunk_a_=\"\${SX_QM_${__sx_num_int_mul_abs_opt_y_}}\" \
		      __sx_num_int_mul_abs_zchunk_a_=\"\${SX_ZR_${__sx_num_int_mul_abs_opt_y_}}\" \
		      __sx_num_int_mul_abs_qchunk_b_=\"\${SX_QM_${__sx_num_int_mul_abs_opt_x_}}\" \
		      __sx_num_int_mul_abs_zchunk_b_=\"\${SX_ZR_${__sx_num_int_mul_abs_opt_x_}}\""

		__sx_num_int_mul_abs_shift_=

		set --

		# a を opt_y 桁ずつ下位からチャンク分割し位置パラメータに格納
		while
			case "${__sx_num_int_mul_abs_a_}" in
				${__sx_num_int_mul_abs_qchunk_a_}?*)
					__sx_num_int_mul_abs_tmp_="${__sx_num_int_mul_abs_a_%${__sx_num_int_mul_abs_qchunk_a_}}"
					__sx_num_int_mul_abs_ch_a_="${__sx_num_int_mul_abs_a_#"${__sx_num_int_mul_abs_tmp_}"}"
					__sx_num_int_mul_abs_a_="${__sx_num_int_mul_abs_tmp_}"
					case "${__sx_num_int_mul_abs_ch_a_}" in
						0*[1-9]*) set -- "${@}" "${__sx_num_int_mul_abs_ch_a_#"${__sx_num_int_mul_abs_ch_a_%%[!0]*}"}";;
						0*) set -- "${@}" 0;;
						*) set -- "${@}" "${__sx_num_int_mul_abs_ch_a_}";;
					esac
					;;
				*) set -- "${@}" "${__sx_num_int_mul_abs_a_}" && ! :;;
			esac
		do :; done

		__sx_num_int_mul_abs_a_=0

		# b を opt_x 桁ずつ分割しながら a の全チャンクと乗算
		while
			case "${__sx_num_int_mul_abs_b_}" in
				${__sx_num_int_mul_abs_qchunk_b_}?*)
					__sx_num_int_mul_abs_tmp_="${__sx_num_int_mul_abs_b_%${__sx_num_int_mul_abs_qchunk_b_}}"
					__sx_num_int_mul_abs_ch_b_="${__sx_num_int_mul_abs_b_#"${__sx_num_int_mul_abs_tmp_}"}"
					__sx_num_int_mul_abs_b_="${__sx_num_int_mul_abs_tmp_}"

					case "${__sx_num_int_mul_abs_ch_b_}" in
						0*[1-9]*) __sx_num_int_mul_abs_ch_b_="${__sx_num_int_mul_abs_ch_b_#"${__sx_num_int_mul_abs_ch_b_%%[!0]*}"}";;
						0*)
							__sx_num_int_mul_abs_shift_="${__sx_num_int_mul_abs_zchunk_b_}${__sx_num_int_mul_abs_shift_}"
							continue
							;;
					esac
					;;
				*)
					__sx_num_int_mul_abs_ch_b_="${__sx_num_int_mul_abs_b_}"
					__sx_num_int_mul_abs_b_=
					;;
			esac

			__sx_num_int_mul_abs_g_=
			__sx_num_int_mul_abs_carry_=

			# チャンク同士の乗算と桁上げ処理
			for __sx_num_int_mul_abs_ch_a_ in "${@}"; do
				__sx_num_int_mul_abs_tmp_=$((__sx_num_int_mul_abs_ch_b_ * __sx_num_int_mul_abs_ch_a_ + ${__sx_num_int_mul_abs_carry_:-0}))

				case "$((__sx_num_int_mul_abs_opt_y_ < ${#__sx_num_int_mul_abs_tmp_}))" in
					1)
						__sx_num_int_mul_abs_carry_="${__sx_num_int_mul_abs_tmp_%${__sx_num_int_mul_abs_qchunk_a_}}"
						__sx_num_int_mul_abs_g_="${__sx_num_int_mul_abs_tmp_#"${__sx_num_int_mul_abs_carry_}"}${__sx_num_int_mul_abs_g_}"
						;;
					*)
						__sx_num_int_mul_abs_carry_=
						case "${__sx_num_int_mul_abs_tmp_}" in
							${__sx_num_int_mul_abs_qchunk_a_}) __sx_num_int_mul_abs_g_="${__sx_num_int_mul_abs_tmp_}${__sx_num_int_mul_abs_g_}";;
							*)
								: "$((__sx_num_int_mul_abs_tmp_ += 1${__sx_num_int_mul_abs_zchunk_a_}))"
								__sx_num_int_mul_abs_g_="${__sx_num_int_mul_abs_tmp_#1}${__sx_num_int_mul_abs_g_}"
								;;
						esac
						;;
				esac
			done

			case "${__sx_num_int_mul_abs_carry_}" in '')
				__sx_num_int_mul_abs_g_="${__sx_num_int_mul_abs_g_#"${__sx_num_int_mul_abs_g_%%[!0]*}"}"
			esac

			# 部分積を結果リストに追加
			SX_CFG_UNSET_SOFT=2 __sx_num_int_add_abs __sx_num_int_mul_abs_a_ "${__sx_num_int_mul_abs_a_}" "${__sx_num_int_mul_abs_carry_}${__sx_num_int_mul_abs_g_}${__sx_num_int_mul_abs_shift_}"

			__sx_num_int_mul_abs_shift_="${__sx_num_int_mul_abs_zchunk_b_}${__sx_num_int_mul_abs_shift_}"
			M_STR_NE([|"${__sx_num_int_mul_abs_b_}"|], [|''|])
		do :; done
	done

	__sx_var_set "${__sx_num_int_mul_abs_res_}=${__sx_num_int_mul_abs_a_}${__sx_num_int_mul_abs_endz_}"
	unset CLEANUP
}

### sx_num_int_add - 複数の符号付き整数を加算する
##
## 使い方:
##   sx_num_int_add 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を加算する。正数群と負数群に分けて絶対値加算を行い、
##   最後に絶対値を比較して符号を決定する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 整数として不正な値が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|V|], [|__sx_num_int_add_$1|])dnl
define([|CLEANUP|], [|V(res)|])dnl

sx_num_int_add() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_add "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_add_res="${1}"
	shift

	sx_num_is_base_int 10 "${@}" || {
		unset CLEANUP
		return "${SX_EX_USAGE}"
	}

	__sx_num_int_add "${__sx_num_int_add_res}" "${@}"
	unset CLEANUP
}

### __sx_num_int_add - 複数の符号付き整数を加算する（内部用）
##
## 使い方:
##   __sx_num_int_add 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を加算する。まず正数と負数に分けてそれぞれ
##   __sx_num_int_add_abs で絶対値加算を行い、最後に絶対値を比較し
##   減算して符号を決定する。

define([|V|], [|__sx_num_int_add_$1_|])dnl
define([|CLEANUP|], [|V(res) V(pos) V(neg) V(pos_sum) V(neg_sum) V(arg) V(acc)|])dnl

__sx_num_int_add() {
	__sx_num_int_add_res_="${1}"
	shift

	# Step 1: 正数と負数に分離
	__sx_num_int_add_pos_=
	__sx_num_int_add_neg_=

	for __sx_num_int_add_arg_ in "${@}"; do
		case "${__sx_num_int_add_arg_}" in
			-*) __sx_num_int_add_neg_="${__sx_num_int_add_neg_} ${__sx_num_int_add_arg_#-}";;
			*)  __sx_num_int_add_pos_="${__sx_num_int_add_pos_} ${__sx_num_int_add_arg_#+}";;
		esac
	done

	# Step 2: 正数の合計
	eval __sx_num_int_add_abs __sx_num_int_add_pos_sum_ "${__sx_num_int_add_pos_}"

	# Step 3: 負数（絶対値）の合計
	eval __sx_num_int_add_abs __sx_num_int_add_neg_sum_ "${__sx_num_int_add_neg_}"

	# Step 4: 絶対値を比較して最終結果を決定
	__sx_num_cmp_nat0 "${__sx_num_int_add_pos_sum_}" "${__sx_num_int_add_neg_sum_}" || case "${?}" in
		1)
			SX_CFG_UNSET_SOFT=2 __sx_num_int_sub_abs __sx_num_int_add_acc_ "${__sx_num_int_add_neg_sum_}" "${__sx_num_int_add_pos_sum_}"
			__sx_num_int_add_acc_="-${__sx_num_int_add_acc_}"
			;;
		2) __sx_num_int_add_acc_=0;;
		3) SX_CFG_UNSET_SOFT=2 __sx_num_int_sub_abs __sx_num_int_add_acc_ "${__sx_num_int_add_pos_sum_}" "${__sx_num_int_add_neg_sum_}";;
	esac

	__sx_var_set "${__sx_num_int_add_res_}=${__sx_num_int_add_acc_}"

	unset CLEANUP
}

### sx_num_int_sub - 複数の符号付き整数を減算する
##
## 使い方:
##   sx_num_int_sub 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を減算する（第1引数から残りの引数を順次減算）。
##   内部で第2引数以降を __sx_num_int_add で合計し、第1引数と符号付き減算する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 整数として不正な値が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|V|], [|__sx_num_int_sub_$1|])dnl
define([|CLEANUP|], [|V(res)|])dnl

sx_num_int_sub() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_sub "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_sub_res="${1}"
	shift

	sx_num_is_base_int 10 "${@}" || {
		unset CLEANUP
		return "${SX_EX_USAGE}"
	}

	__sx_num_int_sub "${__sx_num_int_sub_res}" "${@}"
	unset CLEANUP
}

define([|V|], [|__sx_num_int_sub_$1_|])dnl
define([|CLEANUP|], [|V(res) V(first) V(sign) V(sum) V(tmp)|])dnl

__sx_num_int_sub() {
	__sx_num_int_sub_res_="${1}"
	__sx_num_int_sub_first_="${2-0}"
	__sx_num_int_sub_sign_=

	shift "$((1 + 0${2+1}))"

	# $2...$n の合計（符号付き加算）
	SX_CFG_UNSET_SOFT=2 __sx_num_int_add __sx_num_int_sub_sum_ "${@}"

	# 合計が 0 なら第1引数がそのまま結果
	case "${__sx_num_int_sub_sum_}" in 0)
		__sx_var_set "${__sx_num_int_sub_res_}=${__sx_num_int_sub_first_#+}"
		unset CLEANUP
		return
	esac

	# a - sum を符号の組み合わせ4ケースに分けて直接演算
	case "${__sx_num_int_sub_first_}${__sx_num_int_sub_sum_}" in
		# ケース4: (-a) - (-s) = |s| - |a|
		-*-*)
			__sx_num_cmp_nat0 "${__sx_num_int_sub_first_#-}" "${__sx_num_int_sub_sum_#-}" || case "${?}" in
				1) SX_CFG_UNSET_SOFT=2 __sx_num_int_sub_abs __sx_num_int_sub_tmp_ "${__sx_num_int_sub_sum_#-}" "${__sx_num_int_sub_first_#-}";;
				3)
					__sx_num_int_sub_sign_='-'
					SX_CFG_UNSET_SOFT=2 __sx_num_int_sub_abs __sx_num_int_sub_tmp_ "${__sx_num_int_sub_first_#-}" "${__sx_num_int_sub_sum_#-}"
					;;
			esac
			;;
		# ケース3: (-a) - s = -(a + s)
		-*) __sx_num_int_sub_sign_='-';&
		# ケース2: a - (-s) = a + s
		*-*) SX_CFG_UNSET_SOFT=2 __sx_num_int_add_abs __sx_num_int_sub_tmp_ "${__sx_num_int_sub_first_#[+-]}" "${__sx_num_int_sub_sum_#-}";;
		# ケース1: a - s
		*)
			__sx_num_cmp_nat0 "${__sx_num_int_sub_first_#+}" "${__sx_num_int_sub_sum_}" || case "${?}" in
				1)
					__sx_num_int_sub_sign_='-'
					SX_CFG_UNSET_SOFT=2 __sx_num_int_sub_abs __sx_num_int_sub_tmp_ "${__sx_num_int_sub_sum_}" "${__sx_num_int_sub_first_#+}"
					;;
				3) SX_CFG_UNSET_SOFT=2 __sx_num_int_sub_abs __sx_num_int_sub_tmp_ "${__sx_num_int_sub_first_#+}" "${__sx_num_int_sub_sum_#+}";;
			esac
			;;
	esac

	__sx_var_set "${__sx_num_int_sub_res_}=${__sx_num_int_sub_sign_}${__sx_num_int_sub_tmp_-0}"
	unset CLEANUP
}

### sx_num_int_mul - 複数の符号付き整数を乗算する
##
## 使い方:
##   sx_num_int_mul 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を乗算する。負号の個数で符号を決定し、
##   __sx_num_int_mul_abs で絶対値乗算を行う。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 整数として不正な値が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|V|], [|__sx_num_int_mul_$1|])dnl
define([|CLEANUP|], [|V(res)|])dnl

sx_num_int_mul() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_mul "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_mul_res="${1}"
	shift

	sx_num_is_base_int 10 "${@}" || {
		unset CLEANUP
		return "${SX_EX_USAGE}"
	}

	__sx_num_int_mul "${__sx_num_int_mul_res}" "${@}"
	unset CLEANUP
}

define([|V|], [|__sx_num_int_mul_$1_|])dnl
define([|CLEANUP|], [|V(res) V(qty) V(arg) V(abs_args) V(sign) V(acc)|])dnl

__sx_num_int_mul() {
	__sx_num_int_mul_res_="${1}"
	shift

	__sx_num_int_mul_qty_=0
	__sx_num_int_mul_abs_args_=

	for __sx_num_int_mul_arg_ in "${@}"; do
		case "${__sx_num_int_mul_arg_}" in
			0 | +0 | -0)
				__sx_var_set "${__sx_num_int_mul_res_}=0"
				unset CLEANUP
				return
				;;
			-*) __sx_num_int_mul_qty_="$((~__sx_num_int_mul_qty_))";;
		esac

		__sx_num_int_mul_abs_args_="${__sx_num_int_mul_abs_args_} ${__sx_num_int_mul_arg_#[+-]}"
	done

	case "$((__sx_num_int_mul_qty_ & 1))" in
		1) __sx_num_int_mul_sign_=-;;
		*) __sx_num_int_mul_sign_=;;
	esac

	eval SX_CFG_UNSET_SOFT=2 __sx_num_int_mul_abs __sx_num_int_mul_acc_ "${__sx_num_int_mul_abs_args_}"

	__sx_var_set "${__sx_num_int_mul_res_}=${__sx_num_int_mul_sign_}${__sx_num_int_mul_acc_}"

	unset CLEANUP
}

### sx_num_int_divmod_abs - 絶対値の除算で商と余りを同時に求める
##
## 使い方:
##   sx_num_int_divmod_abs 商変数名 余り変数名 被除数 除数
##
## 説明:
##   符号なし10進整数の絶対値の除算を行い、商と余りを同時に求める。
##   被除数は 0 以上の自然数、除数は 1 以上の自然数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_int_divmod_abs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_divmod_abs "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" "${2-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_divmod_abs_qres="${1}"
	__sx_num_int_divmod_abs_rres="${2}"
	shift 2

	sx_num_is_base_nat0 10 "${1-0}" && sx_num_is_base_nat1 10 "${2-1}" || {
		unset __sx_num_int_divmod_abs_qres __sx_num_int_divmod_abs_rres
		return "${SX_EX_USAGE}"
	}

	__sx_num_int_divmod_abs "${__sx_num_int_divmod_abs_qres}" "${__sx_num_int_divmod_abs_rres}" "${@}"
	unset __sx_num_int_divmod_abs_qres __sx_num_int_divmod_abs_rres
}

### __sx_num_int_divmod_abs - 絶対値の除算で商と余りを同時に求める（内部用）
##
## 使い方:
##   __sx_num_int_divmod_abs 商変数名 余り変数名 被除数 除数
##
## 説明:
##   符号なし10進整数の絶対値の除算を行う。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   除数が 0 でないことが保証されていること。
##   被除数・除数は省略時、それぞれ 0、1 として扱われる。
##
##   アルゴリズム: 語サイズ c = WLEN/2 桁で語分割する融合 Knuth D 法。
##   語の並びは常に「最上位語が先頭」で、v_1 が最上位語、v_n が最下位語。
##   u は先頭にゼロ語 u_1 = 0 を 1 語追加して合計 K 語で持ち、実データは u_2..u_K
##   （u_1 は主ループの最初の窓が参照するために確保するセンチネル語）。
##
##   実行フロー（ステップ 1〜8）:
##   1) 引数の取得（商・余りの結果変数名、被除数 u、除数 v）。
##   2) 高速パス 1〜3: 自明なケースを確定する。
##      v = 1 → 商 = u、余り = 0 ／ u = v → 商 = 1、余り = 0
##      u < v → 商 = 0、余り = u（同桁数は最上位桁から 1 桁ずつ比較する）。
##   3) 語サイズ c の決定（c = WLEN/2。語積 10^(2c) は RANGE の算術幅に収まる）。
##   4) 末尾ゼロ分解: v = m × 10^k に分解し、u も 10^k で縮小する
##      （商は不変、余りは最後に u の下位 k 桁を復元する）。
##   5) 高速パス 4: 被除数全体が RANGE の算術幅（WLEN 桁）以内なら
##      ネイティブ除算で確定する。
##   6) 高速パス 5: 除数が (WLEN-1)*9/10 桁以内なら語幅 m = WLEN - len(v)（約 WLEN/10 + 1）の
##      語単位ネイティブ筆算で O(語数) に確定する。
##   7) 一般パス: 融合 Knuth D 法（u > v、u は 19 桁以上、v は 2 語以上）。
##      7.1 正規化: u、v を 10^d 倍して v の先頭語をちょうど c 桁に揃える。
##      7.2 語分割: v を n 語（v_1..v_n）、u を K 語（u_1..u_K）に分解する。
##      7.3 主ループ: 窓を 1 語ずつ左へずらしながら商を 1 語ずつ確定する。
##          D2 商の見積り → D3 精緻化 → D4 融合 multiply-subtract → D5 加算復帰。
##      7.4 余り抽出: 末尾 n 語（u_{K-n+1}..u_K）を連結する。
##      7.5 逆正規化: 余りの末尾 d 桁を除去して 10^d 倍を戻す。
##   8) 商・余りを結果変数に格納し、内部変数を全て解放する。
##   ネイティブ演算の語積は必ず qhat*v_j < b^2 = 10^(2c) に収まり、
##   c = WLEN/2 より 10^(2c) は SX_CFG_NUM_RANGE の算術幅内に収まる。

define([|V|], [|__sx_num_int_divmod_abs_$1_|])dnl
define([|CLEANUP|], [|V(tmp) V(qres) V(rres) V(u) V(v) V(wlen) V(c) V(b) V(qm) V(zr) V(d) V(qmd) V(zrd) V(vp) V(up) V(n) V(k) V(du) V(rest) V(tail) V(chunk) V(i) V(pad) V(padz) V(q) V(r) V(t) V(qpad) V(s) V(top2) V(qhat) V(rhat) V(lhs) V(rhs) V(uw1) V(uw2) V(uw3) V(uw) V(vv) V(p) V(carry) V(ck) V(ut) V(w) V(zv) V(kz) V(btail) V(m)|])dnl

__sx_num_int_divmod_abs() {
	# ステップ 1: 引数の取得（商・余りの結果変数名と、被除数 u・除数 v の値）
	__sx_num_int_divmod_abs_qres_="${1}"
	__sx_num_int_divmod_abs_rres_="${2}"
	__sx_num_int_divmod_abs_u_="${3-0}"
	__sx_num_int_divmod_abs_v_="${4-1}"

	# ステップ 2: 高速パス 1〜3（自明なケースを即座に確定する）
	#   高速パス 1: 除数が 1 なら商 = 被除数、余り = 0
	case "${__sx_num_int_divmod_abs_v_}" in 1)
		__sx_var_set "${__sx_num_int_divmod_abs_qres_}=${__sx_num_int_divmod_abs_u_}" "${__sx_num_int_divmod_abs_rres_}=0"
		unset CLEANUP
		return "${SX_EX_OK}"
	esac

	# 高速パス 3: 被除数 < 除数なら商 = 0、余り = 被除数
	__sx_num_cmp_nat0 "${__sx_num_int_divmod_abs_u_}" "${__sx_num_int_divmod_abs_v_}" || case "${?}" in
		1) __sx_var_set "${__sx_num_int_divmod_abs_qres_}=0" "${__sx_num_int_divmod_abs_rres_}=${__sx_num_int_divmod_abs_u_}" && ! :;;
		2) __sx_var_set "${__sx_num_int_divmod_abs_qres_}=1" "${__sx_num_int_divmod_abs_rres_}=0" && ! :;;
	esac || {
		unset CLEANUP
		return "${SX_EX_OK}"
	}

	eval "__sx_num_int_divmod_abs_wlen_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_WLEN}\""
	eval "__sx_num_int_divmod_abs_zr_=\"\${SX_NUM_RANGE_${SX_CFG_NUM_RANGE}_ZR}\""

	# ステップ 3: 語サイズ c の決定
	__sx_num_int_divmod_abs_c_="$((__sx_num_int_divmod_abs_wlen_ / 2))"

	# ステップ 4: 末尾ゼロ分解（v = m × 10^k に分解して両者を 10^k で縮小する）
	#   数式: q = (u ÷ 10^k) ÷ m、r = ((u ÷ 10^k) mod m) × 10^k + (u mod 10^k)
	#   商は変化せず、余りには縮小で取り除いた u の下位 k 桁（btail）を最後に復元する。
	#   例: 1234500 ÷ 1200 → m = 12、k = 2、12345 ÷ 12 = 商 1028 余り 9
	#      → 余り = 9 × 100 + 00 = 900（商は縮小の影響を受けない）
	#   適用条件:
	#     kz > WLEN（末尾ゼロが 1 語幅を超える）場合のみ縮小する。
	#     kz は fit_dec によりネイティブ演算の桁数上限に制限される。
	__sx_num_int_divmod_abs_btail_=

	case "${__sx_num_int_divmod_abs_v_}" in *0${__sx_num_int_divmod_abs_zr_})
		__sx_num_int_divmod_abs_zv_="${__sx_num_int_divmod_abs_v_##*[!0]}"
		__sx_num_int_divmod_abs_kz_="${#__sx_num_int_divmod_abs_zv_}"

		if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${__sx_num_int_divmod_abs_kz_}"; then
			if __sx_var_is_set "SX_QM_${__sx_num_int_divmod_abs_kz_}"; then
				eval "__sx_num_int_divmod_abs_qm_=\"\${SX_QM_${__sx_num_int_divmod_abs_kz_}}\""
			else
				SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_num_int_divmod_abs_qm_ '?' "${__sx_num_int_divmod_abs_kz_}"
			fi

			__sx_num_int_divmod_abs_tmp_="${__sx_num_int_divmod_abs_u_%${__sx_num_int_divmod_abs_qm_}}"
			__sx_num_int_divmod_abs_btail_="${__sx_num_int_divmod_abs_u_#"${__sx_num_int_divmod_abs_tmp_}"}"
			__sx_num_int_divmod_abs_v_="${__sx_num_int_divmod_abs_v_%"${__sx_num_int_divmod_abs_zv_}"}"
			__sx_num_int_divmod_abs_u_="${__sx_num_int_divmod_abs_tmp_}"
		fi
	esac

	# ステップ 5: 高速パス 4 — 被除数全体がネイティブ除算で確定できる場合
	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${__sx_num_int_divmod_abs_u_}"; then
		__sx_num_int_divmod_abs_q_="$((__sx_num_int_divmod_abs_u_ / __sx_num_int_divmod_abs_v_))"
		__sx_num_int_divmod_abs_r_="$((__sx_num_int_divmod_abs_u_ % __sx_num_int_divmod_abs_v_))${__sx_num_int_divmod_abs_btail_}"

		# 末尾ゼロ分解で縮小した被除数の下位 k 桁（btail）を余りに復元する
		case "${__sx_num_int_divmod_abs_r_}" in 0*)
			__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_#"${__sx_num_int_divmod_abs_r_%%[!0]*}"}"
		esac

		__sx_var_set "${__sx_num_int_divmod_abs_qres_}=${__sx_num_int_divmod_abs_q_}" "${__sx_num_int_divmod_abs_rres_}=${__sx_num_int_divmod_abs_r_:-0}"
		unset CLEANUP
		return "${SX_EX_OK}"
	fi

	eval "__sx_num_int_divmod_abs_qm_=\"\${SX_QM_$(((__sx_num_int_divmod_abs_wlen_ - 1) * 9 / 10))}\""

	# 以後で使う定数の意味: b = 10^c（語の基数）、qm = c 桁ちょうどに一致するパターン、zr = c 桁のゼロ埋め文字列
	# ステップ 6: 高速パス 5 — 除数が (WLEN-1)*9/10 桁以内なら語単位のネイティブ筆算
	#   語幅 m = WLEN - len(v) は約 WLEN/10 + 1 以上に保たれる。m が小さいと反復回数と
	#   商文字列の連結コスト（O(len(q)^2)）が増え、被除数が長い場合は Knuth D 法に
	#   逆転される（実測では m = 2 で ulen ~ 500 付近から逆転）ため安全マージンを確保する。
	case "${__sx_num_int_divmod_abs_v_}" in
		${__sx_num_int_divmod_abs_qm_}?*) ;;
		*)
			# v の桁数 s に応じて語幅を m = WLEN - s へ拡大する。
			# 余り r は常に r < v なので、1 反復で取る u の桁を s のぶんだけ増やしても
			# nv = r * 10^m + chunk < 10^WLEN が保たれ、ネイティブ演算に収まる。
			__sx_num_int_divmod_abs_m_=$((__sx_num_int_divmod_abs_wlen_ - ${#__sx_num_int_divmod_abs_v_}))
			eval "__sx_num_int_divmod_abs_qm_=\"\${SX_QM_${__sx_num_int_divmod_abs_m_}}\" __sx_num_int_divmod_abs_b_=\"1\${SX_ZR_${__sx_num_int_divmod_abs_m_}}\""
			__sx_num_int_divmod_abs_q_=
			__sx_num_int_divmod_abs_r_=0
			# 筆算の1語分: 前語までの余りを基数倍して次の語を結合し、ネイティブ除算で商1語を確定する
			while
				case "${__sx_num_int_divmod_abs_u_}" in
					'') break;;
					${__sx_num_int_divmod_abs_qm_}?*)
						__sx_num_int_divmod_abs_tmp_="${__sx_num_int_divmod_abs_u_#${__sx_num_int_divmod_abs_qm_}}"
						__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_u_%"${__sx_num_int_divmod_abs_tmp_}"}"
						__sx_num_int_divmod_abs_u_="${__sx_num_int_divmod_abs_tmp_}"
						;;
					*)
						__sx_num_int_divmod_abs_m_="${#__sx_num_int_divmod_abs_u_}"
						eval "__sx_num_int_divmod_abs_qm_=\"\${SX_QM_${__sx_num_int_divmod_abs_m_}}\" __sx_num_int_divmod_abs_b_=\"1\${SX_ZR_${__sx_num_int_divmod_abs_m_}}\""
						__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_u_}"
						__sx_num_int_divmod_abs_u_=
						;;
				esac

				case "${__sx_num_int_divmod_abs_chunk_}" in
					0*[1-9]*) __sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_chunk_#"${__sx_num_int_divmod_abs_chunk_%%[!0]*}"}";;
					0*)
						case "${__sx_num_int_divmod_abs_r_}" in 0)
							__sx_num_int_divmod_abs_q_="${__sx_num_int_divmod_abs_q_}${__sx_num_int_divmod_abs_b_#1}"
							continue
						esac

						__sx_num_int_divmod_abs_chunk_=0
						;;
				esac

				# chunk を nv（r * 10^m + chunk）として再利用する
				: "$((__sx_num_int_divmod_abs_chunk_ += __sx_num_int_divmod_abs_r_ * __sx_num_int_divmod_abs_b_))"
				__sx_num_int_divmod_abs_r_=$((__sx_num_int_divmod_abs_chunk_ % __sx_num_int_divmod_abs_v_))
				# 商1語がちょうど m 桁ならゼロ埋め・切り出しを省略し、それ以外は m 桁に整形する
				__sx_num_int_divmod_abs_tmp_=$((__sx_num_int_divmod_abs_chunk_ / __sx_num_int_divmod_abs_v_))

				case "${__sx_num_int_divmod_abs_tmp_}" in
					${__sx_num_int_divmod_abs_qm_}) __sx_num_int_divmod_abs_q_="${__sx_num_int_divmod_abs_q_}${__sx_num_int_divmod_abs_tmp_}";;
					*)
						: "$((__sx_num_int_divmod_abs_tmp_ += __sx_num_int_divmod_abs_b_))"
						__sx_num_int_divmod_abs_q_="${__sx_num_int_divmod_abs_q_}${__sx_num_int_divmod_abs_tmp_#1}"
						;;
				esac
			do :; done

			case "${__sx_num_int_divmod_abs_q_}" in 0*)
				__sx_num_int_divmod_abs_q_="${__sx_num_int_divmod_abs_q_#"${__sx_num_int_divmod_abs_q_%%[!0]*}"}"
			esac

			# 末尾ゼロ分解で縮小した被除数の下位 k 桁（btail）を余りに復元する
			__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_}${__sx_num_int_divmod_abs_btail_}"

			case "${__sx_num_int_divmod_abs_r_}" in 0*)
				__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_#"${__sx_num_int_divmod_abs_r_%%[!0]*}"}";;
			esac

			__sx_var_set "${__sx_num_int_divmod_abs_qres_}=${__sx_num_int_divmod_abs_q_}" "${__sx_num_int_divmod_abs_rres_}=${__sx_num_int_divmod_abs_r_:-0}"
			unset CLEANUP
			return "${SX_EX_OK}"
			;;
	esac

	eval "__sx_num_int_divmod_abs_qm_=\"\${SX_QM_${__sx_num_int_divmod_abs_c_}}\" __sx_num_int_divmod_abs_zr_=\"\${SX_ZR_${__sx_num_int_divmod_abs_c_}}\""
	__sx_num_int_divmod_abs_b_="1${__sx_num_int_divmod_abs_zr_}"
	# ステップ 7: 一般パス — 融合 Knuth D 法（u > v、u は 19 桁以上、v は 2 語以上）
	# ステップ 7.1: 正規化 — u・v を 10^d 倍し、v の先頭語をちょうど c 桁に揃える
	#   d = c - s（s は v の先頭語の桁数、s = (len(v) - 1) mod c + 1。s がちょうど c なら d = 0）
	#
	#   古典 Knuth D 法の正規化（v1 の値から d = floor(b / (v1 + 1)) を求め、u・v を d 倍して
	#   v1 >= b/2 を保証する方式）とは異なり、ここでは値に依存せず 10^d 倍（末尾へのゼロ付加）
	#   だけで先頭語を c 桁に揃える。保証されるのは v1 >= 10^(c-1) = b/10 であり b/2 には届かない。
	#
	#   正しさの根拠:
	#   - 10^d 倍は文字列連結で実現でき、多倍長乗算を要求しない（u*d、v*d の乗算は
	#     この除数自体を多倍長で扱うことになり、高速除算の利点を失う）。
	#   - D2 の見積りは窓の不変条件 u_{W-n} < v1 より q <= top2/v1 が常に成立し、
	#     過小見積り（qhat < q）は起きない。
	#   - D3 の精緻化テスト（qhat*v2 <= b*rhat + u3）は v1 の大きさに依存せず成立し、
	#     その後は v の最下位 n-2 語の寄与のみが誤差の源泉となる。v1 >= b/10 より
	#     qhat - q < qhat*Lv/v <= b^(n-2)/v <= 1/v1 <= 1 となり（整数性から高々 1）、
	#     D5 加算復帰は実質 1 回で収束する（古典の最悪 2 回と同等以下）。
	#   - D3 が rhat >= b で脱出する場合（先頭語が b/2 より小さいと頻発する）も
	#     qhat*v <= 窓値 が成立し、過大見積り（D5 の反復）は発生しない。
	__sx_num_int_divmod_abs_s_=$((((${#__sx_num_int_divmod_abs_v_} - 1) % __sx_num_int_divmod_abs_c_) + 1))

	__sx_num_int_divmod_abs_d_=$((__sx_num_int_divmod_abs_c_ - __sx_num_int_divmod_abs_s_))
	case "$((__sx_num_int_divmod_abs_d_ > 0))" in
		1)
			eval "__sx_num_int_divmod_abs_zrd_=\"\${SX_ZR_${__sx_num_int_divmod_abs_d_}}\""
			eval "__sx_num_int_divmod_abs_qmd_=\"\${SX_QM_${__sx_num_int_divmod_abs_d_}}\""
			__sx_num_int_divmod_abs_vp_="${__sx_num_int_divmod_abs_v_}${__sx_num_int_divmod_abs_zrd_}"
			__sx_num_int_divmod_abs_up_="${__sx_num_int_divmod_abs_u_}${__sx_num_int_divmod_abs_zrd_}"
			;;
		*)
			__sx_num_int_divmod_abs_vp_="${__sx_num_int_divmod_abs_v_}"
			__sx_num_int_divmod_abs_up_="${__sx_num_int_divmod_abs_u_}"
			;;
	esac

	# ステップ 7.2: 語分割 — v' をちょうど n*c 桁の n 語に分割し v_1..v_n に格納する
	#   （v_1 が最上位語、v_n が最下位語。以後 v の語は動的変数 v_1..v_n で保持する）
	__sx_num_int_divmod_abs_n_=$(( ${#__sx_num_int_divmod_abs_vp_} / __sx_num_int_divmod_abs_c_ ))
	__sx_num_int_divmod_abs_rest_="${__sx_num_int_divmod_abs_vp_}"
	__sx_num_int_divmod_abs_i_=1
	while :; do
		case "${__sx_num_int_divmod_abs_rest_}" in
			'') break;;
			${__sx_num_int_divmod_abs_qm_}?*)
				__sx_num_int_divmod_abs_tail_="${__sx_num_int_divmod_abs_rest_#${__sx_num_int_divmod_abs_qm_}}"
				__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_rest_%"${__sx_num_int_divmod_abs_tail_}"}"
				__sx_num_int_divmod_abs_rest_="${__sx_num_int_divmod_abs_tail_}"
				;;
			*)
				__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_rest_}"
				__sx_num_int_divmod_abs_rest_=
				;;
		esac

		case "${__sx_num_int_divmod_abs_chunk_}" in 0*)
			__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_chunk_#"${__sx_num_int_divmod_abs_chunk_%%[!0]*}"}"
		esac

		eval "__sx_num_int_divmod_abs_v_${__sx_num_int_divmod_abs_i_}=\${__sx_num_int_divmod_abs_chunk_:-0}"
		: "$((__sx_num_int_divmod_abs_i_ += 1))"
	done

	# u' を K 語に分割する。実データは u_2..u_K、u_1 は主ループの最初の窓（D2）が
	# 参照するために先頭に確保するゼロ語（センチネル）。全語を c 桁に揃えるよう上位ゼロをパディングする
	__sx_num_int_divmod_abs_du_="${#__sx_num_int_divmod_abs_up_}"
	__sx_num_int_divmod_abs_k_=$(( (__sx_num_int_divmod_abs_du_ + __sx_num_int_divmod_abs_c_ - 1) / __sx_num_int_divmod_abs_c_ + 1 ))
	eval "__sx_num_int_divmod_abs_u_1=0"
	__sx_num_int_divmod_abs_i_=2
	__sx_num_int_divmod_abs_pad_=$(( (__sx_num_int_divmod_abs_k_ - 1) * __sx_num_int_divmod_abs_c_ - __sx_num_int_divmod_abs_du_ ))
	case "$((__sx_num_int_divmod_abs_pad_ > 0))" in 1)
		eval "__sx_num_int_divmod_abs_padz_=\"\${SX_ZR_${__sx_num_int_divmod_abs_pad_}}\""
		__sx_num_int_divmod_abs_up_="${__sx_num_int_divmod_abs_padz_}${__sx_num_int_divmod_abs_up_}"
	esac
	__sx_num_int_divmod_abs_rest_="${__sx_num_int_divmod_abs_up_}"
	while :; do
		case "${__sx_num_int_divmod_abs_rest_}" in
			'') break;;
			${__sx_num_int_divmod_abs_qm_}?*)
				__sx_num_int_divmod_abs_tail_="${__sx_num_int_divmod_abs_rest_#${__sx_num_int_divmod_abs_qm_}}"
				__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_rest_%"${__sx_num_int_divmod_abs_tail_}"}"
				__sx_num_int_divmod_abs_rest_="${__sx_num_int_divmod_abs_tail_}"
				;;
			*)
				__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_rest_}"
				__sx_num_int_divmod_abs_rest_=
				;;
		esac

		case "${__sx_num_int_divmod_abs_chunk_}" in 0*)
			__sx_num_int_divmod_abs_chunk_="${__sx_num_int_divmod_abs_chunk_#"${__sx_num_int_divmod_abs_chunk_%%[!0]*}"}"
		esac

		eval "__sx_num_int_divmod_abs_u_${__sx_num_int_divmod_abs_i_}=\${__sx_num_int_divmod_abs_chunk_:-0}"
		: "$((__sx_num_int_divmod_abs_i_ += 1))"
	done

	# ステップ 7.3: 主ループ — 窓（u_{W-n}..u_W）を 1 語ずつ左へずらしながら商を 1 語ずつ確定する
	__sx_num_int_divmod_abs_w_=$((__sx_num_int_divmod_abs_n_ + 1))
	__sx_num_int_divmod_abs_q_=
	while M_NUM_LE([|__sx_num_int_divmod_abs_w_|], [|__sx_num_int_divmod_abs_k_|]); do
		# D2: 商の見積り — 窓の先頭 2 語を v_1 で割って qhat を仮定する
		#   top2 = u_{W-n}*b + u_{W-n+1}、qhat = top2 ÷ v_1（b を超えたら b-1 に丸める）
		eval "__sx_num_int_divmod_abs_uw1_=\"\${__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_n_))}\" __sx_num_int_divmod_abs_uw2_=\"\${__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_n_ + 1))}\""
		__sx_num_int_divmod_abs_top2_=$((__sx_num_int_divmod_abs_uw1_ * __sx_num_int_divmod_abs_b_ + __sx_num_int_divmod_abs_uw2_))
		__sx_num_int_divmod_abs_qhat_=$((__sx_num_int_divmod_abs_top2_ / __sx_num_int_divmod_abs_v_1))
		__sx_num_int_divmod_abs_rhat_=$((__sx_num_int_divmod_abs_top2_ % __sx_num_int_divmod_abs_v_1))

		case "$((__sx_num_int_divmod_abs_qhat_ >= __sx_num_int_divmod_abs_b_))" in 1)
			__sx_num_int_divmod_abs_qhat_=$((__sx_num_int_divmod_abs_b_ - 1))
			__sx_num_int_divmod_abs_rhat_=$((__sx_num_int_divmod_abs_top2_ - __sx_num_int_divmod_abs_qhat_ * __sx_num_int_divmod_abs_v_1))
		esac

		# D3: 精緻化 — qhat×v_2 が b×rhat + u_{W-n+2} を超える間 qhat を 1 ずつ減らす
		#   （qhat の過大見積りを補正する。rhat が b 未満である限り繰り返す）
		eval "__sx_num_int_divmod_abs_uw3_=\"\${__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_n_ + 2))}\""
		while M_NUM_LT([|__sx_num_int_divmod_abs_rhat_|], [|__sx_num_int_divmod_abs_b_|]); do
			__sx_num_int_divmod_abs_lhs_=$((__sx_num_int_divmod_abs_qhat_ * __sx_num_int_divmod_abs_v_2))
			__sx_num_int_divmod_abs_rhs_=$((__sx_num_int_divmod_abs_b_ * __sx_num_int_divmod_abs_rhat_ + __sx_num_int_divmod_abs_uw3_))
			case "$((__sx_num_int_divmod_abs_lhs_ <= __sx_num_int_divmod_abs_rhs_))" in 1)
				break
			esac

			: "$((__sx_num_int_divmod_abs_qhat_ -= 1))"
			: "$((__sx_num_int_divmod_abs_rhat_ += __sx_num_int_divmod_abs_v_1))"
		done

		# D4: 融合 multiply-subtract — 窓の語 u_{W-n+1}..u_W から qhat×v を一括減算する
		#   語積 p = qhat×v_j + carry を一度に算出し、下位語から上位語へ繰り上がりを伝搬する
		#   （パフォーマンス最適化: 各語の読み込みと書き込みを 1 本の eval に融合している）
		__sx_num_int_divmod_abs_carry_=0
		__sx_num_int_divmod_abs_i_=1
		eval "__sx_num_int_divmod_abs_uw_=\"\${__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_))}\" __sx_num_int_divmod_abs_vv_=\"\${__sx_num_int_divmod_abs_v_$((__sx_num_int_divmod_abs_n_))}\""
		while :; do
			__sx_num_int_divmod_abs_p_=$((__sx_num_int_divmod_abs_qhat_ * __sx_num_int_divmod_abs_vv_ + __sx_num_int_divmod_abs_carry_))
			__sx_num_int_divmod_abs_t_=$((__sx_num_int_divmod_abs_uw_ - __sx_num_int_divmod_abs_p_ % __sx_num_int_divmod_abs_b_))
			case "$((__sx_num_int_divmod_abs_t_ < 0))" in
				1)
					__sx_num_int_divmod_abs_t_=$((__sx_num_int_divmod_abs_t_ + __sx_num_int_divmod_abs_b_))
					__sx_num_int_divmod_abs_carry_=$((__sx_num_int_divmod_abs_p_ / __sx_num_int_divmod_abs_b_ + 1))
					;;
				*)
					__sx_num_int_divmod_abs_carry_=$((__sx_num_int_divmod_abs_p_ / __sx_num_int_divmod_abs_b_))
					;;
			esac
			case "$((__sx_num_int_divmod_abs_i_ < __sx_num_int_divmod_abs_n_))" in
				1)
					eval "__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_i_ + 1))=\${__sx_num_int_divmod_abs_t_} __sx_num_int_divmod_abs_uw_=\"\${__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_i_))}\" __sx_num_int_divmod_abs_vv_=\"\${__sx_num_int_divmod_abs_v_$((__sx_num_int_divmod_abs_n_ - __sx_num_int_divmod_abs_i_))}\""
					;;
				*)
					eval "__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_i_ + 1))=\${__sx_num_int_divmod_abs_t_}"
					;;
			esac
			__sx_num_int_divmod_abs_i_=$((__sx_num_int_divmod_abs_i_ + 1))
			case "$((__sx_num_int_divmod_abs_i_ <= __sx_num_int_divmod_abs_n_))" in 0) break;; esac
		done
		__sx_num_int_divmod_abs_ut_=$((__sx_num_int_divmod_abs_uw1_ - __sx_num_int_divmod_abs_carry_))

		# D5: 加算復帰 — D4 の減算結果が負（qhat が過大）だった場合に v を加算して qhat を 1 減らす
		#   （通常 0 回、最大 2 回で収束する）
		while M_NUM_LT([|__sx_num_int_divmod_abs_ut_|], [|0|]); do
			__sx_num_int_divmod_abs_ck_=0
			__sx_num_int_divmod_abs_i_=0
			while :; do
				eval "__sx_num_int_divmod_abs_uw_=\"\${__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_i_))}\" __sx_num_int_divmod_abs_vv_=\"\${__sx_num_int_divmod_abs_v_$((__sx_num_int_divmod_abs_n_ - __sx_num_int_divmod_abs_i_))}\""
				__sx_num_int_divmod_abs_t_=$((__sx_num_int_divmod_abs_uw_ + __sx_num_int_divmod_abs_vv_ + __sx_num_int_divmod_abs_ck_))
				case "$((__sx_num_int_divmod_abs_t_ >= __sx_num_int_divmod_abs_b_))" in
					1)
						__sx_num_int_divmod_abs_t_=$((__sx_num_int_divmod_abs_t_ - __sx_num_int_divmod_abs_b_))
						__sx_num_int_divmod_abs_ck_=1
						;;
					*)
						__sx_num_int_divmod_abs_ck_=0
						;;
				esac
				eval "__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_i_))=\${__sx_num_int_divmod_abs_t_}"
				__sx_num_int_divmod_abs_i_=$((__sx_num_int_divmod_abs_i_ + 1))
				case "$((__sx_num_int_divmod_abs_i_ < __sx_num_int_divmod_abs_n_))" in 0) break;; esac
			done
			__sx_num_int_divmod_abs_qhat_=$((__sx_num_int_divmod_abs_qhat_ - 1))
			__sx_num_int_divmod_abs_ut_=$((__sx_num_int_divmod_abs_ut_ + __sx_num_int_divmod_abs_ck_))
		done
		eval "__sx_num_int_divmod_abs_u_$((__sx_num_int_divmod_abs_w_ - __sx_num_int_divmod_abs_n_))=\${__sx_num_int_divmod_abs_ut_}"

		# 商に qhat を c 桁ゼロ埋めで連結
		__sx_num_int_divmod_abs_qpad_="${__sx_num_int_divmod_abs_zr_}${__sx_num_int_divmod_abs_qhat_}"
		__sx_num_int_divmod_abs_qpad_="${__sx_num_int_divmod_abs_qpad_#"${__sx_num_int_divmod_abs_qpad_%${__sx_num_int_divmod_abs_qm_}}"}"
		__sx_num_int_divmod_abs_q_="${__sx_num_int_divmod_abs_q_}${__sx_num_int_divmod_abs_qpad_}"
		__sx_num_int_divmod_abs_w_=$((__sx_num_int_divmod_abs_w_ + 1))
	done

	# ステップ 7.4: 余り抽出 — 末尾 n 語（u_{K-n+1}..u_K）を c 桁ゼロ埋めで連結する
	__sx_num_int_divmod_abs_r_=
	__sx_num_int_divmod_abs_i_=$((__sx_num_int_divmod_abs_k_ - __sx_num_int_divmod_abs_n_ + 1))
	while :; do
		eval "__sx_num_int_divmod_abs_uw_=\"\${__sx_num_int_divmod_abs_u_${__sx_num_int_divmod_abs_i_}}\""
		__sx_num_int_divmod_abs_qpad_="${__sx_num_int_divmod_abs_zr_}${__sx_num_int_divmod_abs_uw_}"
		__sx_num_int_divmod_abs_qpad_="${__sx_num_int_divmod_abs_qpad_#"${__sx_num_int_divmod_abs_qpad_%${__sx_num_int_divmod_abs_qm_}}"}"
		__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_}${__sx_num_int_divmod_abs_qpad_}"
		__sx_num_int_divmod_abs_i_=$((__sx_num_int_divmod_abs_i_ + 1))
		case "$((__sx_num_int_divmod_abs_i_ <= __sx_num_int_divmod_abs_k_))" in 0) break;; esac
	done

	# ステップ 7.5: 逆正規化 — 余りの末尾 d 桁を除去して 10^d 倍を戻す（商は影響を受けない）
	case "$((__sx_num_int_divmod_abs_d_ > 0))" in 1)
		__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_%${__sx_num_int_divmod_abs_qmd_}}"
	esac
	case "${__sx_num_int_divmod_abs_r_}" in 0*)
		__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_#"${__sx_num_int_divmod_abs_r_%%[!0]*}"}"
	esac
	case "${__sx_num_int_divmod_abs_r_}" in '') __sx_num_int_divmod_abs_r_=0;; esac
	# 末尾ゼロ分解で縮小した被除数の下位 k 桁（btail）を余りに復元する
	case "${__sx_num_int_divmod_abs_btail_+x}" in x)
		__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_}${__sx_num_int_divmod_abs_btail_}"
		case "${__sx_num_int_divmod_abs_r_}" in 0*)
			__sx_num_int_divmod_abs_r_="${__sx_num_int_divmod_abs_r_#"${__sx_num_int_divmod_abs_r_%%[!0]*}"}"
		esac
		case "${__sx_num_int_divmod_abs_r_}" in '') __sx_num_int_divmod_abs_r_=0;; esac
	esac
	case "${__sx_num_int_divmod_abs_q_}" in 0*)
		__sx_num_int_divmod_abs_q_="${__sx_num_int_divmod_abs_q_#"${__sx_num_int_divmod_abs_q_%%[!0]*}"}"
	esac
	case "${__sx_num_int_divmod_abs_q_}" in '') __sx_num_int_divmod_abs_q_=0;; esac

	# ステップ 8: 商・余りを結果変数に格納し、内部変数を全て解放する
	__sx_var_set "${__sx_num_int_divmod_abs_qres_}=${__sx_num_int_divmod_abs_q_}" "${__sx_num_int_divmod_abs_rres_}=${__sx_num_int_divmod_abs_r_}"

	# 動的語変数（u_1..u_K、v_1..v_n）を解放
	__sx_num_int_divmod_abs_i_=1
	while :; do
		case "$((__sx_num_int_divmod_abs_i_ <= __sx_num_int_divmod_abs_k_))" in 0) break;; esac
		eval "unset __sx_num_int_divmod_abs_u_${__sx_num_int_divmod_abs_i_}"
		__sx_num_int_divmod_abs_i_=$((__sx_num_int_divmod_abs_i_ + 1))
	done
	__sx_num_int_divmod_abs_i_=1
	while :; do
		case "$((__sx_num_int_divmod_abs_i_ <= __sx_num_int_divmod_abs_n_))" in 0) break;; esac
		eval "unset __sx_num_int_divmod_abs_v_${__sx_num_int_divmod_abs_i_}"
		__sx_num_int_divmod_abs_i_=$((__sx_num_int_divmod_abs_i_ + 1))
	done
	unset CLEANUP
}

### sx_num_int_div_abs - 絶対値の除算で商を求める
##
## 使い方:
##   sx_num_int_div_abs 結果変数名 被除数 除数
##
## 説明:
##   符号なし10進整数の絶対値の除算を行い、商（切り捨て）を求める。
##   除数に 0 を指定した場合はエラーとする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  除数が 0 (SX_EX_DATAERR)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_int_div_abs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_divmod_abs "${1-}" __sx_num_int_div_abs_junk_ "${2-}" "${3-}" || return; unset __sx_num_int_div_abs_junk_; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_div_abs_res="${1}"
	shift

	sx_num_is_base_nat0 10 "${@}" || {
		unset __sx_num_int_div_abs_res
		return "${SX_EX_USAGE}"
	}

	case "${2-}" in
		0 | '')
			unset __sx_num_int_div_abs_res
			return "${SX_EX_DATAERR}"
			;;
	esac

	__sx_num_int_divmod_abs "${__sx_num_int_div_abs_res}" __sx_num_int_div_abs_junk_ "${@}"
	unset __sx_num_int_div_abs_res __sx_num_int_div_abs_junk_
}

### sx_num_int_mod_abs - 絶対値の除算で剰余を求める
##
## 使い方:
##   sx_num_int_mod_abs 結果変数名 被除数 除数
##
## 説明:
##   符号なし10進整数の絶対値の除算を行い、剰余を求める。
##   除数に 0 を指定した場合はエラーとする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  除数が 0 (SX_EX_DATAERR)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_int_mod_abs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_int_divmod_abs __sx_num_int_mod_abs_junk_ "${1-}" "${2-}" "${3-}" || return; unset __sx_num_int_mod_abs_junk_; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return "${SX_EX_CONFIG}"

	__sx_num_int_mod_abs_res="${1}"
	shift

	sx_num_is_base_nat0 10 "${@}" || {
		unset __sx_num_int_mod_abs_res
		return "${SX_EX_USAGE}"
	}

	case "${2-}" in
		0 | '')
			unset __sx_num_int_mod_abs_res
			return "${SX_EX_DATAERR}"
			;;
	esac

	__sx_num_int_divmod_abs __sx_num_int_mod_abs_junk_ "${__sx_num_int_mod_abs_res}" "${@}"
	unset __sx_num_int_mod_abs_res __sx_num_int_mod_abs_junk_
}


# ========================================
#  UUID (UUID Operations)
# ========================================

### sx_uuid_is_uuid - すべての引数が UUID 形式であるか確認する
##
## 使い方:
##   sx_uuid_is_uuid [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、標準的な UUID 形式（8-4-4-4-12 の 16 進数）
##   であるかを確認する。大文字と小文字は区別しない。
##
## 終了ステータス:
##    0  すべて UUID 形式である (SX_EX_OK)
##    1  UUID 形式ではない文字列が含まれる
sx_uuid_is_uuid() {
	for __sx_uuid_is_uuid_arg in "${@}"; do
		case "${__sx_uuid_is_uuid_arg}" in
			[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]) ;;
			*)
				unset __sx_uuid_is_uuid_arg
				return 1
				;;
		esac
	done

	unset __sx_uuid_is_uuid_arg
}

# ========================================
#  STR (String Operations)
# ========================================

### sx_str_any - 第一引数が、後続引数のいずれかの文字列と完全に一致するか確認する
##
## 使い方:
##   sx_str_any [比較元文字列 [比較対象1 [比較対象2 ...]]]
##
## 挙動:
## - 第一引数を比較元文字列として扱う
## - 第二引数以降を比較対象文字列として順に比較する
## - 比較対象文字列が 1 つもない場合は不一致として 1 を返す
## - 引数が 0 個の場合は、比較元文字列を空文字列として扱い、やはり 1 を返す
##
## 終了ステータス:
##    0  いずれかと一致する (SX_EX_OK)
##    1  一つも一致しない
sx_str_any() {
	__sx_str_any_tgt="${1-}"
	shift "$((0 < ${#}))"

	for __sx_str_any_arg in "${@}"; do
		case "${__sx_str_any_tgt}" in "${__sx_str_any_arg}")
			unset __sx_str_any_tgt __sx_str_any_arg
			return "${SX_EX_OK}"
		esac
	done

	unset __sx_str_any_tgt __sx_str_any_arg
	return 1
}

### sx_str_camel - さまざまな命名規則を camelCase に変換する
##
## 使い方:
##   sx_str_camel 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   入力文字列の命名規則を自動検出し、camelCase（先頭単語のみ小文字、
##   以降の単語は先頭大文字、区切りなし）に変換する。
##   内部で sx_str_words と sx_str_title を使用し、単語分割後に
##   各単語をタイトルケース化して結合し、先頭を小文字にする。
##   対応する入力形式:
##   - snake_case: _ で分割
##   - kebab-case: - で分割
##   - camelCase / PascalCase: 大文字の境界で分割
##   - 空白区切り: 空白で分割
##   区切り文字セットの各文字は単語区切りとして扱われる。
##   デフォルトの区切り文字セットは "_-/.:${SX_STR_SPACE}"。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_camel() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_camel "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_str_camel "${@}"
}

### __sx_str_camel - さまざまな命名規則を camelCase に変換する（内部用）
##
## 使い方:
##   __sx_str_camel 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   sx_str_camel の内部実装。引数チェックは行わない。
##   sx_str_words で単語分割し、先頭に _ を前置して sx_str_title で
##   タイトルケース化した後、_ を除去して sx_str_squish で空白を除去する。
__sx_str_camel() {
	set -- "${1}" "${2-}" "${3:-"_-/.:${SX_STR_SPACE}"}"

	SX_CFG_UNSET_SOFT=2 __sx_str_words __sx_str_camel_tmp_ "${2}" ' ' "${3}"
	SX_CFG_UNSET_SOFT=2 __sx_str_title __sx_str_camel_tmp_ "_${__sx_str_camel_tmp_}" ' '
	__sx_str_squish "${1}" "${__sx_str_camel_tmp_#?}" ' ' ''

	unset __sx_str_camel_tmp_
}

### sx_str_center - 文字列を指定された幅で中央寄せする
##
## 使い方:
##   sx_str_center 結果変数名 文字列 幅 [左埋め文字列 [右埋め文字列]]
##
## 説明:
##   文字列の長さが「幅」の絶対値に満たない場合、埋め込み文字列で中央寄せするように埋める。
##   幅が正の場合、余り（奇数の場合）は右側に振る。
##   幅が負の場合、余りは左側に振る。
##   左埋め文字列のみ指定された場合は右側にも同じ文字列を使用する（後方互換）。
##   左埋め文字列も右埋め文字列も指定されない場合は半角スペースを使用する。
##   左埋め文字列が明示的に空の場合は左側に何も埋めない。
##   右埋め文字列が明示的に空の場合は右側に何も埋めない。
##   両方とも明示的に空の場合は何もせずそのまま返す。
##   元の文字列が既に指定された幅以上の場合は、そのまま返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_center() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_center "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} ${4+"${#4}"} ${5+"${#5}"} || return

	__sx_num_is_sx_int_inv ${3+"${3}"} || return "${SX_EX_USAGE}"

	__sx_str_center "${@}"
}

### __sx_str_center - 文字列を指定された幅で中央寄せする（内部用）
##
## 使い方:
##   __sx_str_center 結果変数名 文字列 幅 [左埋め文字列 [右埋め文字列]]
##
## 説明:
##   sx_str_center の内部実装。
##   引数チェックは行わないが、左右の埋め文字が両方とも空の場合は何もせず成功を返す。
##   $5 が未指定の場合、最適化パス（左と同じfillで1回のstr_rep）を使用する。
__sx_str_center() {
	set -- "${1}" "${2-}" "${3-0}" "${4- }" "${5-${4- }}"

	__sx_str_center_needed_=$((${3#-} - ${#2}))

	case "$((0 < __sx_str_center_needed_))${4}${5}" in 0* | 1)
		__sx_var_set "${1}=${2}"
		unset __sx_str_center_needed_
		return "${SX_EX_OK}"
	esac

	__sx_str_center_lpad_=$(( (__sx_str_center_needed_ + (${3} < 0)) / 2 ))
	__sx_str_center_rpad_=$(( __sx_str_center_needed_ - __sx_str_center_lpad_ ))

	case "${4}" in ?*)
		SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_center_lrep_ "${4}" "$((((__sx_str_center_needed_ + 1) / 2 - 1) / ${#4} + 1))"
	esac

	case "${5}" in
		"${4}") __sx_str_center_rrep_="${__sx_str_center_lrep_}";;
		?*) SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_center_rrep_ "${5}" "$(((__sx_str_center_rpad_ - 1) / ${#5} + 1))";;
	esac

	SX_CFG_UNSET_SOFT=2 __sx_str_substr __sx_str_center_spad_ "${__sx_str_center_lrep_-}" 0 "${__sx_str_center_lpad_}"
	SX_CFG_UNSET_SOFT=2 __sx_str_substr __sx_str_center_epad_ "${__sx_str_center_rrep_-}" 0 "${__sx_str_center_rpad_}"

	__sx_var_set "${1}=${__sx_str_center_spad_}${2}${__sx_str_center_epad_}"

	unset __sx_str_center_needed_ __sx_str_center_lpad_ __sx_str_center_rpad_ __sx_str_center_lrep_ __sx_str_center_rrep_ __sx_str_center_spad_ __sx_str_center_epad_
}

### sx_str_chunk - 文字列を一定の長さで区切って結果変数（またはバインドチェーン）に格納する
##
## 使い方:
##   sx_str_chunk スキーマ [文字列 [長さ [分割回数 [フラグ]]]]
##
## 説明:
##   指定された文字列を、指定された長さ（文字数）ごとに区切る。
##   長さが正の場合は前方から、負の場合は後方から区切る。
##   分割回数が指定された場合、最大でその回数分だけ分割を行う。
##   長さが 0 または省略された場合は、エラー (SX_EX_USAGE) となる。
##
##   スキーマ (第一引数) には、単一の変数名またはバインドチェーン (v1:v2:rest) を指定できる。
##   - 単一変数名: 各要素をシングルクォートで囲み、スペース区切りで結合した文字列を格納する。
##   - バインドチェーン: 分割された要素を順番に変数に代入する。
##     - 要素数が変数より多い場合、最後の変数は残りの全要素をクォート結合した文字列として保持する。
##     - 変数名が空 (v1::v3) の要素はスキップされる。
##     - スキーマがコロンで終わる (v1:v2:) 形式の場合、指定された変数への代入が完了した時点で
##       処理を早期終了する（巨大な文字列の部分取得に有効）。
##
##   格納される値およびクォート結合される文字列は、メタ文字が適切にエスケープされており、
##   eval 等を用いて安全に位置パラメータとして復元できる。
##
##   フラグ (第五引数) には SX_STR_CHUNK_SKIP_SHORT / SX_STR_CHUNK_SKIP_LONG
##   をビットマスクで指定する。指定された条件に該当する残余チャンクは
##   結果に含めずスキップする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  スキーマに含まれる変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_chunk() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_chunk "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_num_is_sx_nat0 ${4:+"${4}"} ${5:+"${5}"} || return "${SX_EX_USAGE}"

	case "${3:-1}" in
		*[1-9ABCDEFabcdef]*) ;;
		*) return "${SX_EX_USAGE}";;
	esac

	SX_CFG_UNSET_SOFT=2 __sx_str_split __sx_str_chunk_ints "${3:-1}" :
	if ! eval __sx_num_is_sx_int_inv "${__sx_str_chunk_ints}"; then
		unset __sx_str_chunk_ints
		return "${SX_EX_USAGE}"
	fi

	unset __sx_str_chunk_ints

	__sx_str_chunk "${@}"
}

define([|V|], [|__sx_str_chunk_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(str) V(cycle) V(lim) V(len) V(bwd) V(out) V(newcycle) V(cur) V(qm) V(abs) V(next) V(chunk) __M_BIND_USEVAR|])dnl

### __sx_str_chunk - 文字列を一定の長さで区切って結果変数に格納する（内部用）
##
## 使い方:
##   __sx_str_chunk 結果変数名 [文字列 [長さ [分割回数]]]
##
## 説明:
##   sx_str_chunk の内部実装。
##   引数チェックは行わない。
__sx_str_chunk() {
	set -- "${1}" "${2-}" "${3-1}" "${4:-${SX_NUM_I32_MAX}}" "${5:-0}"
	__sx_var_bind_init "${1}"
	__sx_str_chunk_bind_="${1}"
	__sx_str_chunk_str_="${2-}"
	__sx_str_chunk_cycle_="${3}:"
	__sx_str_chunk_lim_="${4}"
	__sx_str_chunk_len_="${#__sx_str_chunk_str_}"
	__sx_str_chunk_bwd_=
	__sx_str_chunk_out_=

	# プリパス: interval に ? パターンを埋め込む (1:-2:3 → 1?:-2??:3???:)
	__sx_str_chunk_newcycle_=
	while M_STR_HAS([|"${__sx_str_chunk_cycle_}"|], [|:|]); do
		__sx_str_chunk_cur_="${__sx_str_chunk_cycle_%%:*}"
		__sx_str_chunk_cycle_="${__sx_str_chunk_cycle_#*:}"

		SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_chunk_qm_ '?' "${__sx_str_chunk_cur_#-}"
		__sx_str_chunk_newcycle_="${__sx_str_chunk_newcycle_}$((0 <= __sx_str_chunk_cur_))${__sx_str_chunk_qm_}:"
	done

	__sx_str_chunk_cycle_="${__sx_str_chunk_newcycle_}"

	# 第1パス: 文字列長・limit から切り取りサイズリストを構築
	while
		__sx_str_chunk_cur_="${__sx_str_chunk_cycle_%%:*}" &&
		__sx_str_chunk_qm_="${__sx_str_chunk_cur_#?}" &&
		__sx_str_chunk_abs_="${#__sx_str_chunk_qm_}" &&
		M_NUM_BOOL([|${__sx_str_chunk_abs_} <= __sx_str_chunk_len_ && 0 < __sx_str_chunk_lim_|])
	do
		__sx_str_chunk_cycle_="${__sx_str_chunk_cycle_#*:}${__sx_str_chunk_cur_}:"
		: $((__sx_str_chunk_len_ -= __sx_str_chunk_abs_))
		: $((__sx_str_chunk_lim_ -= 1))

		case "${__sx_str_chunk_cur_}" in 0*)
			__sx_str_chunk_bwd_="'${__sx_str_chunk_qm_}' ${__sx_str_chunk_bwd_}"
			continue
		esac

		__sx_str_chunk_next_="${__sx_str_chunk_str_#${__sx_str_chunk_qm_}}"

		__M_BIND_QUOTE([|__sx_str_chunk|], [|"${__sx_str_chunk_str_%"${__sx_str_chunk_next_}"}"|], CLEANUP)

		__sx_str_chunk_str_="${__sx_str_chunk_next_}"
	done

	# 余り処理: limit 到達 or 文字列不足
	if M_NUM_LT([|0|], [|__sx_str_chunk_len_|]); then
		SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_chunk_qm_ '?' "${__sx_str_chunk_len_}"

		case "$((
			(__sx_str_chunk_len_ < __sx_str_chunk_abs_ && ${5} & SX_STR_CHUNK_SKIP_SHORT) ||
			(__sx_str_chunk_abs_ < __sx_str_chunk_len_ && ${5} & SX_STR_CHUNK_SKIP_LONG)
		))" in
			0) eval set -- '"${__sx_str_chunk_qm_}"' "${__sx_str_chunk_bwd_}";;
		*)
			__sx_str_chunk_str_="${__sx_str_chunk_str_#${__sx_str_chunk_qm_}}"
			eval set -- "${__sx_str_chunk_bwd_}"
			;;
		esac
	else
		eval set -- "${__sx_str_chunk_bwd_}"
	fi

	# 第2パス: 切り取りリストを左から処理
	for __sx_str_chunk_qm_ in "${@}"; do
		__sx_str_chunk_next_="${__sx_str_chunk_str_#${__sx_str_chunk_qm_}}"
		__sx_str_chunk_chunk_=""

		__M_BIND_QUOTE([|__sx_str_chunk|], [|"${__sx_str_chunk_str_%"${__sx_str_chunk_next_}"}"|], CLEANUP)

		__sx_str_chunk_str_="${__sx_str_chunk_next_}"
	done

	eval ${__sx_str_chunk_out_:+"${__sx_str_chunk_bind_}=\"\${__sx_str_chunk_out_}\""}

	unset CLEANUP
}

### sx_str_count - 文字列から指定された文字列の出現回数を取得する
##
## 使い方:
##   sx_str_count 結果変数名 [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   元文字列から検索文字列の出現回数を数え、結果変数に非負整数で格納する。
##   フラグの意味は sx_str_find と同一（SX_STR_COUNT_GLOB / SX_STR_COUNT_OVERLAP）。
##   実質的に __sx_str_find に委譲し、結果のスペース区切り件数を __sx_arg_len で取得する。
##
##   バインド形式はサポートしない。結果変数名には単一の変数名のみ指定可能。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_count() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_count "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} ${4+"${4}"} || return

	__sx_str_count "${@}" || return
}

### __sx_str_count - 文字列から指定された文字列の出現回数を取得する（内部用）
##
## 使い方:
##   __sx_str_count 結果変数名 [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_count の内部実装。引数チェックは行わない。
__sx_str_count() {
	SX_CFG_UNSET_SOFT=2 __sx_str_find __sx_str_count_tmp_ "${2-}" "${3-}" "${4:-0}" || :
	eval __sx_arg_len '"${1}"' "${__sx_str_count_tmp_}"
	unset __sx_str_count_tmp_
}

### sx_str_eq - すべての引数が文字列として一致するか確認する
##
## 使い方:
##   sx_str_eq [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて一致する (または引数が1つ以下)
##    1  一致しない文字列が含まれる
sx_str_eq() {
	__sx_str_eq_first="${1-}"
	shift "$((0 < ${#}))"

	for __sx_str_eq_arg in "${@}"; do
		case "${__sx_str_eq_arg}" in
			"${__sx_str_eq_first}") ;;
			*)
				unset __sx_str_eq_first __sx_str_eq_arg
				return 1
				;;
		esac
	done

	unset __sx_str_eq_first __sx_str_eq_arg
}

### sx_str_escape - 文字列内の指定された文字をエスケープする
##
## 使い方:
##   sx_str_escape 結果変数名 [元文字列 [エスケープ対象文字集合 [開始エスケープ文字列 [終了エスケープ文字列]]]]
##
## 説明:
##   元文字列の中に含まれるエスケープ対象文字の各文字を、
##   開始エスケープ文字列 + その文字 + 終了エスケープ文字列 で置換する。
##   エスケープ対象文字集合が空の場合は、元の文字列をそのまま結果変数に格納する。
##   s=\, e=空 の場合はバックスラッシュエスケープ（シェルエスケープ）として動作する。
##   s=[, e=] の場合は glob ブラケット式による quoting として動作する。
##   s=', e=' の場合は SQL LIKE エスケープとして動作する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_escape() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_escape "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_str_escape "${@}"
}

### __sx_str_escape - 文字列内の指定された文字をエスケープする（内部用）
##
## 使い方:
##   __sx_str_escape 結果変数名 [元文字列 [エスケープ対象文字集合 [開始エスケープ文字列 [終了エスケープ文字列]]]]
##
## 説明:
##   sx_str_escape の内部実装。引数チェックは行わない。
__sx_str_escape() {
	set -- "${1}" "${2-}" "${3-}" "${4:-\\}" "${5:-}"

	case "${3}" in '')
		__sx_var_set "${1}=${2}"
		return "${SX_EX_OK}"
	esac

	SX_CFG_UNSET_SOFT=2 __sx_glob_bracket __sx_str_escape_gs_ "${3}"

	__sx_str_escape_cb_se_="${4}" __sx_str_escape_cb_ee_="${5}" SX_CFG_UNSET_SOFT=2 __sx_str_sub "${1}" "${2}" "${__sx_str_escape_gs_}" __sx_str_escape_cb '' "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"

	unset __sx_str_escape_gs_
}

### __sx_str_escape_cb - sx_str_escape 用コールバック（内部用）
##
## 使い方:
##   __sx_str_escape_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
__sx_str_escape_cb() {
	eval "${1}=\"\${__sx_str_escape_cb_se_}\${2}\${__sx_str_escape_cb_ee_}\""
}

### sx_str_etrim - 文字列の末尾から指定された文字セットを削除する
##
## 使い方:
##   sx_str_etrim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   文字列の末尾にある、指定された文字セットに含まれる文字をすべて削除して結果変数に格納する。
##   文字セットが省略された場合は、SX_STR_SPACE（空白文字すべて）が使用される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_etrim() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_etrim "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_str_etrim "${@}"
}

### __sx_str_etrim - 文字列の末尾から指定された文字セットを削除する（内部用）
##
## 使い方:
##   __sx_str_etrim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   sx_str_etrim の内部実装。
##   引数チェックは行わない。
__sx_str_etrim() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}"

	case "${3}" in '')
		__sx_var_set "${1}=${2}"
		return "${SX_EX_OK}"
	esac

	__sx_var_set "${1}=${2%"${2##*[!"${3}"]}"}"
}

### sx_str_ew - 第一引数が、第二引数以降のいずれかの文字列で終わっているか確認する
##
## 使い方:
##   sx_str_ew [検索対象文字列 [終了文字列1 [終了文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 終了文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列の接尾辞であれば成功する
## - 終了文字列が 1 つも指定されなかった場合は失敗する
## - 終了文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかの終了文字列で終わっている (SX_EX_OK)
##    1  一致する終了文字列がない
sx_str_ew() {
	__sx_str_ew_tgt="${1-}"
	shift "$((0 < ${#}))"

	for __sx_str_ew_arg in "${@}"; do
		case "${__sx_str_ew_tgt}" in *"${__sx_str_ew_arg}")
			unset __sx_str_ew_tgt __sx_str_ew_arg
			return "${SX_EX_OK}"
		esac
	done

	unset __sx_str_ew_tgt __sx_str_ew_arg
	return 1
}

### sx_str_has - 第一引数に、第二引数以降のいずれかの文字列が含まれているか確認する
##
## 使い方:
##   sx_str_has [検索対象文字列 [含まれるべき文字列1 [含まれるべき文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 含まれるべき文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列に含まれていれば成功する
## - 含まれるべき文字列が 1 つも指定されなかった場合は失敗する
## - 含まれるべき文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかが含まれている (SX_EX_OK)
##    1  一致する文字列がない
sx_str_has() {
	__sx_str_has_tgt="${1-}"
	shift "$((0 < ${#}))"

	for __sx_str_has_arg in "${@}"; do
		case "${__sx_str_has_tgt}" in *"${__sx_str_has_arg}"*)
			unset __sx_str_has_tgt __sx_str_has_arg
			return "${SX_EX_OK}"
		esac
	done

	unset __sx_str_has_tgt __sx_str_has_arg
	return 1
}

### sx_str_find - 文字列から指定された文字列を前方一致で探し、位置を取得する
##
## 使い方:
##   sx_str_find 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   元文字列から検索文字列をリテラル前方一致で探し、見つかったすべての位置を
##   "index:len" 形式で結果変数に格納する。複数一致する場合はスペース区切りで並べる。
##   検索文字列が空の場合は、各文字境界位置（長さ0）を出力する。
##   第一引数には sx_arg_find と同様のバインド形式を指定できる。
##   例: res（全件）、3res:（最大3件）、a:b（分配）
##
##   フラグに SX_STR_FIND_GLOB (1) を指定すると、検索文字列を glob パターンとして扱う。
##   例: "hello world" から "w*" を検索すると "6:1" を返す。
##   例: "abc" から "?b" を検索すると "0:2" を返す。
##   グロブモードでは一致長にマッチした文字列（最短一致）の長さを使用する。
##
##   フラグに SX_STR_FIND_OVERLAP (2) を指定すると、重なり合う一致も検出する。
##   例: "aaa" から "aa" を重複検索すると "0:2 1:2" を返す。
##
##   フラグに SX_STR_FIND_TEXT (4) を指定すると、出力が "index:len" の代わりに
##   実際にマッチした文字列になる。分配モード（a:b）と併用するのが安全。
##   例: "hello world" から "l" を検索すると "l l l" を返す。
##   例: "abc" から "?b" を glob 検索すると "ab" を返す。
##   注意: 全件モード（res）ではマッチテキストにスペースが含まれると
##   パースが曖昧になるため、分配モードの使用を推奨する。
##
## 出力形式:
##   index:len  — 各一致を "位置(0-based):一致長" のペアで表現（デフォルト）
##   文字列     — SX_STR_FIND_TEXT 指定時はマッチした文字列そのもの
##   空文字列   — 一致なし（終了ステータス 1）
##
## 終了ステータス:
##    0  1件以上一致 (SX_EX_OK)
##    1  不一致
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_find() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_find "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} ${4+"${4}"} || return

	__sx_str_find "${@}" || return
}

define([|V|], [|__sx_str_find_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(tgt) V(off) V(pre) V(out) V(sts) V(match) V(after) V(text) V(overlap) __M_BIND_USEVAR|])dnl

### __sx_str_find - 文字列から指定された文字列を前方一致で探す（内部用）
##
## 使い方:
##   __sx_str_find 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_find の内部実装。引数チェックは行わない。
__sx_str_find() {
	set -- "${1}" "${2-}" "${3-}" "${4:-0}"
	__sx_var_bind_init "${1}"
	__sx_str_find_bind_="${1}"
	__sx_str_find_tgt_="${2}"
	__sx_str_find_text_=$((${4} & SX_STR_FIND_TEXT))
	__sx_str_find_overlap_=$((${4} & SX_STR_FIND_OVERLAP))
	__sx_str_find_off_=0
	__sx_str_find_out_=

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${4} & SX_STR_FIND_GLOB|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		__sx_str_find_sts_="${SX_EX_OK}"

		# 空 needle: 全境界位置（0 〜 len）に長さ0で出力
		while M_NUM_LE([|${__sx_str_find_off_}|], [|${#__sx_str_find_tgt_}|]); do
			case "${__sx_str_find_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_str_find|], [|"${__sx_str_find_off_}:0"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_str_find|], [|''|], CLEANUP);;
			esac

			: $((__sx_str_find_off_ += 1))
		done
	elif M_NUM_BOOL([|${4} & SX_STR_FIND_GLOB|]); then
		# ==== グロブモード ====
		while M_STR_HAS([|"${__sx_str_find_tgt_}"|], [|${3}|]); do
			# マッチ文字列を抽出（__sx_str_sub_cb と同じ手法）
			__sx_str_find_pre_="${__sx_str_find_tgt_%%${3}*}"
			__sx_str_find_after_="${__sx_str_find_tgt_#*${3}}"
			__sx_str_find_match_="${__sx_str_find_tgt_#"${__sx_str_find_pre_}"}"
			__sx_str_find_match_="${__sx_str_find_match_%"${__sx_str_find_after_}"}"
			: "$((__sx_str_find_off_ += ${#__sx_str_find_pre_}))" "${__sx_str_find_sts_=${SX_EX_OK}}"

			case "${__sx_str_find_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_str_find|], [|"${__sx_str_find_off_}:${#__sx_str_find_match_}"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_str_find|], [|"${__sx_str_find_match_}"|], CLEANUP);;
			esac

			case "${__sx_str_find_overlap_}" in
				0)
					: $((__sx_str_find_off_ += ${#__sx_str_find_match_}))
					__sx_str_find_tgt_="${__sx_str_find_tgt_#"${__sx_str_find_pre_}${__sx_str_find_match_}"}"
					;;
				*)
					: $((__sx_str_find_off_ += 1))
					__sx_str_find_tgt_="${__sx_str_find_tgt_#"${__sx_str_find_pre_}"?}"
					;;
			esac
		done
	else
		# ==== リテラルモード ====
		while M_STR_HAS([|"${__sx_str_find_tgt_}"|], [|"${3}"|]); do
			__sx_str_find_pre_="${__sx_str_find_tgt_%%"${3}"*}"
			: "$((__sx_str_find_off_ += ${#__sx_str_find_pre_}))" "${__sx_str_find_sts_=${SX_EX_OK}}"

			case "${__sx_str_find_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_str_find|], [|"${__sx_str_find_off_}:${#3}"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_str_find|], [|"${3}"|], CLEANUP);;
			esac

			case "${__sx_str_find_overlap_}" in
				0)
					: $((__sx_str_find_off_ += ${#3}))
					__sx_str_find_tgt_="${__sx_str_find_tgt_#*"${3}"}"
					;;
				*)
					: $((__sx_str_find_off_ += 1))
					__sx_str_find_tgt_="${__sx_str_find_tgt_#"${__sx_str_find_pre_}"?}"
					;;
			esac
		done
	fi

	eval ${__sx_str_find_out_:+"${__sx_str_find_bind_}=\"\${__sx_str_find_out_# }\""}

	set -- "${__sx_str_find_sts_-1}"
	unset CLEANUP
	return "${1}"
}

### sx_str_is_alnum - すべての引数が英数字（A-Z, a-z, 0-9）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_alnum [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて英数字のみで構成されている (SX_EX_OK)
##    1  英数字以外が含まれる、または空文字列が含まれる
sx_str_is_alnum() {
	sx_str_is_of "${SX_STR_ALNUM}" "${@}" || return
}

### sx_str_is_alpha - すべての引数が英字（A-Z, a-z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_alpha [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて英字のみで構成されている (SX_EX_OK)
##    1  英字以外が含まれる、または空文字列が含まれる
sx_str_is_alpha() {
	sx_str_is_of "${SX_STR_ALPHA}" "${@}" || return
}

### sx_str_is_ascii - すべての引数がASCII文字（0x00-0x7F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_ascii [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべてASCII文字のみで構成されている (SX_EX_OK)
##    1  ASCII文字以外が含まれる、または空文字列が含まれる
sx_str_is_ascii() {
	sx_str_is_of "${SX_STR_ASCII}" "${@}" || return
}

### sx_str_is_blank - すべての引数が空白文字（タブ, スペース）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_blank [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて空白文字のみで構成されている (SX_EX_OK)
##    1  空白文字以外が含まれる、または空文字列が含まれる
sx_str_is_blank() {
	sx_str_is_of "${SX_STR_BLANK}" "${@}" || return
}

### sx_str_is_cntrl - すべての引数が制御文字（0x01-0x1F, 0x7F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_cntrl [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて制御文字のみで構成されている (SX_EX_OK)
##    1  制御文字以外が含まれる、または空文字列が含まれる
sx_str_is_cntrl() {
	sx_str_is_of "${SX_STR_CNTRL}" "${@}" || return
}

### sx_str_is_digit - すべての引数が数字のみで構成されている（空でない）か確認する
##
## 使い方:
##   sx_str_is_digit [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて数字のみで構成されている (SX_EX_OK)
##    1  数字以外が含まれる、または空文字列が含まれる
sx_str_is_digit() {
	sx_str_is_of "${SX_STR_DIGIT}" "${@}" || return
}

### sx_str_is_hex - すべての引数が16進数文字（0-9, a-f, A-F）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_hex [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて16進数文字のみで構成されている (SX_EX_OK)
##    1  16進数文字以外が含まれる、または空文字列が含まれる
sx_str_is_hex() {
	sx_str_is_of "${SX_STR_XDIGIT}" "${@}" || return
}

### sx_str_is_graph - すべての引数が図形文字（英数字 + 区切り記号）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_graph [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて図形文字のみで構成されている (SX_EX_OK)
##    1  図形文字以外が含まれる、または空文字列が含まれる
sx_str_is_graph() {
	sx_str_is_of "${SX_STR_GRAPH}" "${@}" || return
}

### sx_str_is_lower - すべての引数が小文字英字（a-z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_lower [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて小文字英字のみで構成されている (SX_EX_OK)
##    1  小文字英字以外が含まれる、または空文字列が含まれる
sx_str_is_lower() {
	sx_str_is_of "${SX_STR_LOWER}" "${@}" || return
}

### sx_str_is_oct - すべての引数が8進数文字（0-7）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_oct [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて8進数文字のみで構成されている (SX_EX_OK)
##    1  8進数文字以外が含まれる、または空文字列が含まれる
sx_str_is_oct() {
	sx_str_is_of "${SX_STR_OCT}" "${@}" || return
}

### sx_str_is_of - すべての引数が指定された文字集合のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_of 文字集合 [文字列1 [文字列2 ...]]
##
## 説明:
##   第2引数以降のすべての文字列が、第1引数で指定された文字集合の文字のみで
##   構成されているかを確認する。
##   空文字列は条件を満たさないものとして扱われる。
##
## 終了ステータス:
##    0  すべて指定された文字集合のみで構成されている (SX_EX_OK)
##    1  指定された文字集合以外が含まれる、または空文字列が含まれる
sx_str_is_of() {
	__sx_str_is_of_charset="${1}"
	shift

	for __sx_str_is_of_arg in "${@}"; do
		case "${__sx_str_is_of_arg}" in '' | *[!"${__sx_str_is_of_charset}"]*)
			unset __sx_str_is_of_charset __sx_str_is_of_arg
			return 1
		esac
	done

	unset __sx_str_is_of_charset __sx_str_is_of_arg
}

### sx_str_is_print - すべての引数が表示可能文字（図形文字 + スペース）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_print [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて表示可能文字のみで構成されている (SX_EX_OK)
##    1  表示可能文字以外が含まれる、または空文字列が含まれる
sx_str_is_print() {
	sx_str_is_of "${SX_STR_PRINT}" "${@}" || return
}

### sx_str_is_punct - すべての引数が区切り記号（!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_punct [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて区切り記号のみで構成されている (SX_EX_OK)
##    1  区切り記号以外が含まれる、または空文字列が含まれる
sx_str_is_punct() {
	sx_str_is_of "${SX_STR_PUNCT}" "${@}" || return
}

### sx_str_is_space - すべての引数が空白文字（タブ, 改行, 垂直タブ, 改ページ, 復帰, スペース）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_space [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて空白文字のみで構成されている (SX_EX_OK)
##    1  空白文字以外が含まれる、または空文字列が含まれる
sx_str_is_space() {
	sx_str_is_of "${SX_STR_SPACE}" "${@}" || return
}

### sx_str_is_upper - すべての引数が大文字英字（A-Z）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_upper [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて大文字英字のみで構成されている (SX_EX_OK)
##    1  大文字英字以外が含まれる、または空文字列が含まれる
sx_str_is_upper() {
	sx_str_is_of "${SX_STR_UPPER}" "${@}" || return
}

### sx_str_is_word - すべての引数が単語構成文字（英数字 + _）のみで構成されているか確認する
##
## 使い方:
##   sx_str_is_word [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて単語構成文字のみで構成されている (SX_EX_OK)
##    1  単語構成文字以外が含まれる、または空文字列が含まれる
sx_str_is_word() {
	sx_str_is_of "${SX_STR_WORD}" "${@}" || return
}

### sx_str_isep - 文字列に一定の間隔でセパレータを挿入する
##
## 使い方:
##   sx_str_isep 結果変数名 文字列 セパレータ [インターバル [リミット [フラグ]]]
##
## 説明:
##   指定された文字列に対して、指定された間隔（インターバル）ごとにセパレータを挿入して結合する。
##   インターバルが正の場合は前方から、負の場合は後方から数えて挿入する。
##   リミットを指定すると、セパレータの挿入回数を制限できる。
##   インターバルに 0 は指定できない。デフォルトのインターバルは 1。
##
##   フラグに以下の値をビット和で指定できる：
##   - SX_STR_ISEP_CB (1): 第3引数をセパレータではなくコールバック関数名として扱う。
##   - SX_STR_ISEP_PRE (2): インターバルの境界が先頭と一致する場合に挿入を許可する。
##   - SX_STR_ISEP_POST (4): インターバルの境界が末尾と一致する場合に挿入を許可する。
##
##   コールバックのシグネチャ: callback 結果変数名 left right count
##     left: 挿入箇所より左側の文字列 (Left)
##     right: 挿入箇所より右側の文字列 (Right)
##     count: マッチカウンター (1から始まる)
##   コールバックが非0を返すと、現在の結果を挿入した後に処理を中断する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_isep "${@}" || return; return; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_num_is_sx_int_inv ${4:+"${4}"} && __sx_num_is_sx_nat0 ${5:+"${5}"} ${6:+"${6}"} || return "${SX_EX_USAGE}"

	case "$((${4:-1}))" in 0)
		return "${SX_EX_USAGE}"
	esac

	__sx_str_isep "${@}" || return
}

### __sx_str_isep - 文字列に一定の間隔でセパレータを挿入する（内部用）
##
## 使い方:
##   __sx_str_isep 結果変数名 文字列 セパレータ [インターバル [リミット [フラグ]]]
##
## 説明:
##   sx_str_isep の内部実装。
##   引数チェックは行わない。
__sx_str_isep() {
	# 位置パラメータ構成:
	# ${1}: res, ${2}: str, ${3}: sep/cb, ${4}: int, ${5}: lim, ${6}: flags
	# ${7}: out, ${8}: qm, ${9}: count, ${10}: ctx, ${11}: stat
	# 文字列が空の場合は、重複防止のため POST (int>0) または PRE (int<0) フラグを無効化する
	set -- "${1}" "${2-}" "${3-}" "${4:-1}" "${5:-${SX_NUM_I32_MAX}}" "$((${6:-0} & (${#2} != 0 ? ~0 : (${4:-1} > 0 ? ~SX_STR_ISEP_POST : ~SX_STR_ISEP_PRE))))" "" "" 0 ""

	case "$((${6} & SX_STR_ISEP_CB))" in
		0) __sx_str_isep_lit "${@}";;
		*) __sx_str_isep_cb "${@}";;
	esac || return
}

### __sx_str_isep_cb - 文字列に一定の間隔でセパレータを挿入する（コールバックモード、内部用）
##
## 使い方:
##   __sx_str_isep_cb 結果変数名 文字列 セパレータ インターバル リミット フラグ out qm count ctx stat
##
## 説明:
##   __sx_str_isep からコールバックモードを抽出した内部関数。
__sx_str_isep_cb() {
	# 位置パラメータ構成:
	# ${1}: res, ${2}: str, ${3}: cb, ${4}: int, ${5}: lim, ${6}: flags
	# ${7}: out, ${8}: qm, ${9}: count, ${10}: ctx, ${11}: stat
	#
	# コールバックモードではセパレータの代わりに $3 をコールバック関数名として扱う。
	# 各挿入位置で callback "結果変数" left right count を呼び出し、
	# 戻り値（__sx_str_isep_cb_ret_）を挿入文字列として使用する。
	# コールバックが非0を返した場合、stat=$? に記録し以降のループを抑制する。

	if M_NUM_LT([|0|], [|${4}|]); then
		# === Forward: 先頭から interval 文字ごとに区切る ===
		# PRE: callback("", str, count+1) → 戻り値を追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_PRE && ${9} < ${5}|]); then
			"${3}" __sx_str_isep_cb_ret_ "" "${2}" "$((${9} + 1))" || {
				set -- "${@}" "${?}"
				__sx_str_isep_cb_ret_=
			}

			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${__sx_str_isep_cb_ret_-}" "${8}" "$((${11-0} ? ${5} : ${9} + 1))" "${10}" ${11+"${11}"}
			unset __sx_str_isep_cb_ret_
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_BOOL([|${4} < ${#2} && ${9} < ${5}|]); then
			SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_isep_qm_ '?' "${4}"
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${__sx_str_isep_qm_}" "${9}" "${10}" ${11+"${11}"}
			unset __sx_str_isep_qm_

			while M_NUM_BOOL([|${4} < ${#2} && ${9} < ${5}|]); do
				set -- "${@}" "${2#${8}}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "$((${9} + 1))" "${10}" "${2%"${11}"}"

				"${3}" __sx_str_isep_cb_ret_ "${10}${11}" "${2}" "${9}" || {
					set -- "${@}" "${?}"
					__sx_str_isep_cb_ret_=
				}

				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${11}${__sx_str_isep_cb_ret_-}" "${8}" "$((${12-0} ? ${5} : ${9}))" "${10}${11}" ${12+"${12}"}
				unset __sx_str_isep_cb_ret_
			done
		fi

		# 残り文字列
		set -- "${1}" "" "${3}" "${4}" "${5}" "${6}" "${7}${2}" "${8}" "${9}" "${10}${2}" ${11+"${11}"}

		# POST: callback(ctx, "", count+1) → 戻り値を追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_POST && ${9} < ${5} && (${#10} % ${4}) == 0|]); then
			"${3}" __sx_str_isep_cb_ret_ "${10}" "" "$((${9} + 1))" || {
				set -- "${@}" "${?}"
				__sx_str_isep_cb_ret_=
			}

			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${__sx_str_isep_cb_ret_-}" "${8}" "$((${11-0} ? ${5} : ${9} + 1))" "${10}" ${11+"${11}"}
			unset __sx_str_isep_cb_ret_
		fi
	else
		# === Backward: 末尾から interval 文字ごとに区切る ===
		# POST: callback(str, "", count+1) → 戻り値を前に追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_POST && ${9} < ${5}|]); then
			"${3}" __sx_str_isep_cb_ret_ "${2}" "" "$((${9} + 1))" || {
				set -- "${@}" "${?}"
				__sx_str_isep_cb_ret_=
			}

			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${__sx_str_isep_cb_ret_-}${7}" "${8}" "$((${11-0} ? ${5} : ${9} + 1))" "${10}" ${11+"${11}"}
			unset __sx_str_isep_cb_ret_
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_BOOL([|(0 - ${#2}) < ${4} && ${5} != 0|]); then
			SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_isep_qm_ '?' "${4#-}"
			set -- "${1}" "${2}" "${3}" "${4#-}" "${5}" "${6}" "${7}" "${__sx_str_isep_qm_}" "${9}" "${10}" ${11+"${11}"}
			unset __sx_str_isep_qm_

			while M_NUM_BOOL([|${4} < ${#2} && ${9} < ${5}|]); do
				set -- "${@}" "${2%${8}}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "$((${9} + 1))" "${10}" "${2#"${11}"}"

				"${3}" __sx_str_isep_cb_ret_ "${2}" "${11}${10}" "${9}" || {
					set -- "${@}" "${?}"
					__sx_str_isep_cb_ret_=
				}

				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${__sx_str_isep_cb_ret_-}${11}${7}" "${8}" "$((${12-0} ? ${5} : ${9}))" "${11}${10}" ${12+"${12}"}
				unset __sx_str_isep_cb_ret_
			done
		fi

		# 残り文字列
		set -- "${1}" "" "${3}" "${4}" "${5}" "${6}" "${2}${7}" "${8}" "${9}" "${2}${10}" ${11+"${11}"}

		# PRE: callback("", ctx, count+1) → 戻り値を前に追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_PRE && ${9} < ${5} && (${#10} % ${4}) == 0|]); then
			"${3}" __sx_str_isep_cb_ret_ "" "${10}" "$((${9} + 1))" || {
				set -- "${@}" "${?}"
				__sx_str_isep_cb_ret_=
			}

			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${__sx_str_isep_cb_ret_-}${7}" "${8}" "$((${11-0} ? ${5} : ${9} + 1))" "${10}" ${11+"${11}"}
			unset __sx_str_isep_cb_ret_
		fi
	fi

	__sx_var_set "${1}=${7}"
	return "${11-0}"
}

### __sx_str_isep_lit - 文字列に一定の間隔でセパレータを挿入する（リテラルモード、内部用）
##
## 使い方:
##   __sx_str_isep_lit 結果変数名 文字列 セパレータ インターバル 残リミット フラグ out qm
##
## 説明:
##   __sx_str_isep からリテラルモードを抽出した内部関数。
__sx_str_isep_lit() {
	# 位置パラメータ構成:
	# ${1}: res, ${2}: str, ${3}: sep, ${4}: int, ${5}: lim, ${6}: flags
	# ${7}: out, ${8}: qm

	if M_NUM_LT([|0|], [|${4}|]); then
		# === Forward: 先頭から interval 文字ごとに区切る ===
		# PRE: 先頭の境界
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_PRE && ${5} != 0|]); then
			set -- "${1}" "${2}" "${3}" "${4}" "$((${5} - 1))" "${6}" "${7}${3}" "${8}"
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_BOOL([|${4} < ${#2} && ${5} != 0|]); then
			SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_isep_qm_ '?' "${4}"
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${__sx_str_isep_qm_}"
			unset __sx_str_isep_qm_

			while M_NUM_BOOL([|${4} < ${#2} && ${5} != 0|]); do
				set -- "${1}" "${2#${8}}" "${3}" "${4}" "$((${5} - 1))" "${6}" "${7}${2%"${2#${8}}"}${3}" "${8}"
			done
		fi

		# 残り文字列を末尾に追加
		set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${2}" "${8}"

		# POST: 末尾の境界（count < lim かつ 残り文字列長 % interval == 0）
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_POST && ${5} != 0 && (${#2} % ${4}) == 0|]); then
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${3}" "${8}"
		fi
	else
		# === Backward: 末尾から interval 文字ごとに区切る ===
		# POST: 末尾の境界（後方処理では最初に処理する境界）
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_POST && ${5} != 0|]); then
			set -- "${1}" "${2}" "${3}" "${4}" "$((${5} - 1))" "${6}" "${3}${7}" "${8}"
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_BOOL([|(0 - ${#2}) < ${4} && ${5} != 0|]); then
			SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_isep_qm_ '?' "${4#-}"
			set -- "${1}" "${2}" "${3}" "${4#-}" "${5}" "${6}" "${7}" "${__sx_str_isep_qm_}"
			unset __sx_str_isep_qm_

			while M_NUM_BOOL([|${4} < ${#2} && ${5} != 0|]); do
				set -- "${1}" "${2%${8}}" "${3}" "${4}" "$((${5} - 1))" "${6}" "${3}${2#"${2%${8}}"}${7}" "${8}"
			done
		fi

		# 残り文字列を先頭に追加
		set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${2}${7}" "${8}"

		# PRE: 先頭の境界（後方処理では最後に処理する境界）
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_PRE && ${5} != 0 && (${#2} % ${4}) == 0|]); then
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${3}${7}" "${8}"
		fi
	fi

	__sx_var_set "${1}=${7}"
}

### sx_str_lower - 文字列内のラテン大文字を小文字に変換する
##
## 使い方:
##   sx_str_lower 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   指定された文字列内のラテン大文字 (A-Z) を小文字 (a-z) に変換し、
##   結果を結果変数に格納する。既に小文字の文字や非アルファベット文字は
##   そのまま保持される。
##   回数制限が正の値の場合は前方から、負の値の場合は後方から
##   指定された回数分だけ変換を行う。省略時は無制限。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_lower() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_lower "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int_inv ${3:+"${3}"} || return

	__sx_str_lower "${@}"
}

### __sx_str_lower - 文字列内のラテン大文字を小文字に変換する（内部用）
##
## 使い方:
##   __sx_str_lower 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   sx_str_lower の内部実装。引数チェックは行わない。
__sx_str_lower() {
	__sx_str_tr "${1}:" "${2-}" "${SX_STR_UPPER}" "${SX_STR_LOWER}" "${3:-${SX_NUM_I32_MAX}}"
}

### __sx_str_lower_cb - sx_str_lower 用コールバック（内部用）
##
## 使い方:
##   __sx_str_lower_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   マッチした大文字1文字を小文字に変換して結果変数に格納する。
__sx_str_lower_cb() {
	case "${2}" in
		A) eval "${1}=a";; B) eval "${1}=b";;
		C) eval "${1}=c";; D) eval "${1}=d";;
		E) eval "${1}=e";; F) eval "${1}=f";;
		G) eval "${1}=g";; H) eval "${1}=h";;
		I) eval "${1}=i";; J) eval "${1}=j";;
		K) eval "${1}=k";; L) eval "${1}=l";;
		M) eval "${1}=m";; N) eval "${1}=n";;
		O) eval "${1}=o";; P) eval "${1}=p";;
		Q) eval "${1}=q";; R) eval "${1}=r";;
		S) eval "${1}=s";; T) eval "${1}=t";;
		U) eval "${1}=u";; V) eval "${1}=v";;
		W) eval "${1}=w";; X) eval "${1}=x";;
		Y) eval "${1}=y";; Z) eval "${1}=z";;
		*) eval "${1}=\"\${2}\"";;
	esac
}

### sx_str_match - 第一引数が、後続引数のいずれかのパターンにマッチするか確認する
##
## 使い方:
##   sx_str_match [検索対象文字列 [パターン1 [パターン2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - パターンはシェル標準の glob 形式（*, ?, [...]）を使用できる
## - 第二引数以降のいずれかが検索対象文字列にマッチすれば成功する
## - パターンが 1 つも指定されなかった場合は失敗する
##
## 終了ステータス:
##    0  いずれかのパターンにマッチする (SX_EX_OK)
##    1  マッチするパターンがない
sx_str_match() {
	__sx_str_match_tgt="${1-}"
	shift "$((0 < ${#}))"

	for __sx_str_match_arg in "${@}"; do
		case "${__sx_str_match_tgt}" in ${__sx_str_match_arg})
			unset __sx_str_match_tgt __sx_str_match_arg
			return "${SX_EX_OK}"
		esac
	done

	unset __sx_str_match_tgt __sx_str_match_arg
	return 1
}

### sx_str_pad - 文字列を指定された長さになるように埋める
##
## 使い方:
##   sx_str_pad 結果変数名 文字列 長さ [埋め込み文字列]
##
## 説明:
##   文字列の長さが「長さ」の絶対値に満たない場合、埋め込み文字列で埋める。
##   長さが正の場合、左側に埋める（右寄せ）。
##   長さが負の場合、右側に埋める（左寄せ）。
##   埋め込み文字列が指定されない場合は半角スペースを使用する。
##   埋め込み文字列が明示的に空の場合は何もせずそのまま返す。
##   埋め込み文字列が複数文字の場合、必要な長さ分だけ使用される。
##   元の文字列が既に指定された長さ以上の場合は、そのまま返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_pad() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_pad "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} ${4+"${#4}"} || return

	__sx_num_is_sx_int_inv ${3+"${3}"} || return "${SX_EX_USAGE}"

	__sx_str_pad "${@}"
}

### __sx_str_pad - 文字列を指定された長さになるように埋める（内部用）
##
## 使い方:
##   __sx_str_pad 結果変数名 文字列 長さ [埋め込み文字列]
##
## 説明:
##   sx_str_pad の内部実装。
##   引数チェックは行わないが、埋め込み文字列が空の場合は何もせず成功を返す。
__sx_str_pad() {
	set -- "${1}" "${2-}" "${3-0}" "${4- }"

	__sx_str_pad_needed_=$((${3#-} - ${#2}))

	M_NUM_LT([|0|], [|__sx_str_pad_needed_|]) && M_STR_NE([|"${4}"|], [|''|]) || {
		__sx_var_set "${1}=${2}"
		unset __sx_str_pad_needed_
		return "${SX_EX_OK}"
	}

	SX_CFG_UNSET_SOFT=2 __sx_str_rep __sx_str_pad_rep_ "${4}" "$(((__sx_str_pad_needed_ - 1) / ${#4} + 1))"
	SX_CFG_UNSET_SOFT=2 __sx_str_substr __sx_str_pad_fill_ "${__sx_str_pad_rep_}" 0 "${__sx_str_pad_needed_}"

	case "${3}" in
		-*) __sx_var_set "${1}=${2}${__sx_str_pad_fill_}";;
		*) __sx_var_set "${1}=${__sx_str_pad_fill_}${2}";;
	esac

	unset __sx_str_pad_needed_ __sx_str_pad_rep_ __sx_str_pad_fill_
}

### sx_str_pascal - さまざまな命名規則を PascalCase に変換する
##
## 使い方:
##   sx_str_pascal 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   入力文字列の命名規則を自動検出し、PascalCase（各単語先頭大文字、
##   残り小文字、区切りなし）に変換する。
##   内部で sx_str_words と sx_str_title を使用し、単語分割後に
##   各単語をタイトルケース化して結合する。
##   対応する入力形式:
##   - snake_case: _ で分割
##   - kebab-case: - で分割
##   - camelCase / PascalCase: 大文字の境界で分割
##   - 空白区切り: 空白で分割
##   区切り文字セットの各文字は単語区切りとして扱われる。
##   デフォルトの区切り文字セットは "_-/.:${SX_STR_SPACE}"。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_pascal() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_pascal "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_str_pascal "${@}"
}

### __sx_str_pascal - さまざまな命名規則を PascalCase に変換する（内部用）
##
## 使い方:
##   __sx_str_pascal 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   sx_str_pascal の内部実装。引数チェックは行わない。
##   sx_str_words で単語分割し、sx_str_title でタイトルケース化し、
##   sx_str_squish で空白を除去して結合する。
__sx_str_pascal() {
	set -- "${1}" "${2-}" "${3:-"_-/.:${SX_STR_SPACE}"}"

	SX_CFG_UNSET_SOFT=2 __sx_str_words __sx_str_pascal_tmp_ "${2}" ' ' "${3}"
	SX_CFG_UNSET_SOFT=2 __sx_str_title __sx_str_pascal_tmp_ "${__sx_str_pascal_tmp_}" ' '
	__sx_str_squish "${1}" "${__sx_str_pascal_tmp_}" ' ' ''

	unset __sx_str_pascal_tmp_
}

### sx_str_rep - 文字列を繰り返す
##
## 使い方:
##   sx_str_rep 結果変数名 [元文字列 [繰り返し回数]]
##
## 説明:
##   元文字列を指定された回数だけ繰り返して、結果変数に格納する。
##   省略された引数は、元文字列が空文字列、繰り返し回数が 1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rep "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 ${3+"${3}"} || return

	__sx_str_rep "${@}"
}

### __sx_str_rep - 文字列を繰り返す（内部用）
##
## 使い方:
##   __sx_str_rep 結果変数名 [元文字列 [繰り返し回数]]
##
## 説明:
##   sx_str_rep の内部実装。
##   引数チェックは行わない。
__sx_str_rep() {
	set -- "${1}" "${2-}" "$((${3-1}))"

	__sx_str_rep_out_=

	while :; do
		case "$((${3} % 2))" in 1)
			__sx_str_rep_out_="${__sx_str_rep_out_}${2}"
		esac

		set -- "${1}" "${2}" "$((${3} / 2))"
		M_STR_NE([|"${3}"|], [|0|]) || break
		set -- "${1}" "${2}${2}" "${3}"
	done

	__sx_var_set "${1}=${__sx_str_rep_out_}"
	unset __sx_str_rep_out_
}

### sx_str_rev - 文字列を反転する
##
## 使い方:
##   sx_str_rev 結果変数名 [元文字列 [チャンクサイズ]]
##
## 説明:
##   指定された文字列を反転（逆順）して結果変数に格納する。
##   空文字列が渡された場合は空文字列を格納する。
##   チャンクサイズが正の場合は先頭基準、負の場合は末尾基準でチャンク単位の反転を行う。
##   チャンクサイズが 1 または省略された場合は従来通りの文字単位の反転を行う。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_rev() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rev "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_num_is_sx_int_inv ${3:+"${3}"} || return "${SX_EX_USAGE}"
	case "$((${3:-1}))" in 0)
		return "${SX_EX_USAGE}"
	esac

	__sx_str_rev "${@}"
}

### __sx_str_rev - 文字列を反転する（内部用）
##
## 使い方:
##   __sx_str_rev 結果変数名 [元文字列 [チャンクサイズ]]
##
## 説明:
##   sx_str_rev の内部実装。引数チェックは行わない。
##   チャンクサイズが正の場合は先頭基準、負の場合は末尾基準でチャンク単位の反転を行う。
__sx_str_rev() {
	set -- "${1}" "${2-}" "${3:-1}"

	__sx_str_rev_src_="${2-}"
	__sx_str_rev_out_=
	__sx_str_rep __sx_str_rev_pat_ '?' "${3#-}"

	if M_NUM_LT([|${3}|], [|0|]); then
		set -- "${1}" "${2}" "${3#-}"

		while M_NUM_BOOL([|${3} < ${#__sx_str_rev_src_}|]); do
			__sx_str_rev_tmp_="${__sx_str_rev_src_%${__sx_str_rev_pat_}}"
			__sx_str_rev_out_="${__sx_str_rev_out_}${__sx_str_rev_src_#${__sx_str_rev_tmp_}}"
			__sx_str_rev_src_="${__sx_str_rev_tmp_}"
		done

		__sx_var_set "${1}=${__sx_str_rev_out_}${__sx_str_rev_src_}"
	else
		while M_NUM_BOOL([|${3} < ${#__sx_str_rev_src_}|]); do
			__sx_str_rev_tmp_="${__sx_str_rev_src_#${__sx_str_rev_pat_}}"
			__sx_str_rev_out_="${__sx_str_rev_src_%"${__sx_str_rev_tmp_}"}${__sx_str_rev_out_}"
			__sx_str_rev_src_="${__sx_str_rev_tmp_}"
		done

		__sx_var_set "${1}=${__sx_str_rev_src_}${__sx_str_rev_out_}"
	fi

	unset __sx_str_rev_src_ __sx_str_rev_out_ __sx_str_rev_pat_ __sx_str_rev_tmp_
}

### sx_str_rfind - 文字列から指定された文字列を後方一致で探し、位置を取得する
##
## 使い方:
##   sx_str_rfind 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   元文字列から検索文字列をリテラル後方一致で探し、見つかったすべての位置を
##   "index:len" 形式で結果変数に格納する。複数一致する場合はスペース区切りで並べる。
##   検索文字列が空の場合は、各文字境界位置（長さ0）を末尾から順に出力する。
##   第一引数には sx_arg_find と同様のバインド形式を指定できる。
##
##   フラグに SX_STR_RFIND_GLOB (1) を指定すると、検索文字列を glob パターンとして扱う。
##   フラグに SX_STR_RFIND_OVERLAP (2) を指定すると、重なり合う一致も検出する。
##   フラグに SX_STR_RFIND_TEXT (4) を指定すると、出力が "index:len" の代わりに
##   実際にマッチした文字列になる。
##
## 終了ステータス:
##    0  1件以上一致 (SX_EX_OK)
##    1  不一致
##   64  引数不正 (SX_EX_USAGE)
sx_str_rfind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rfind "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} ${4+"${4}"} || return

	__sx_str_rfind "${@}" || return
}

define([|V|], [|__sx_str_rfind_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(tgt) V(off) V(pre) V(out) V(sts) V(match) V(after) V(text) V(overlap) __M_BIND_USEVAR|])dnl

### __sx_str_rfind - 文字列から指定された文字列を後方一致で探す（内部用）
##
## 使い方:
##   __sx_str_rfind 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_rfind の内部実装。引数チェックは行わない。
__sx_str_rfind() {
	set -- "${1}" "${2-}" "${3-}" "${4:-0}"
	__sx_var_bind_init "${1}"
	__sx_str_rfind_bind_="${1}"
	__sx_str_rfind_tgt_="${2}"
	__sx_str_rfind_text_=$((${4} & SX_STR_RFIND_TEXT))
	__sx_str_rfind_overlap_=$((${4} & SX_STR_RFIND_OVERLAP))
	__sx_str_rfind_out_=

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${4} & SX_STR_RFIND_GLOB|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		__sx_str_rfind_off_="${#__sx_str_rfind_tgt_}"
		__sx_str_rfind_sts_="${SX_EX_OK}"

		# 空 needle: len から 0 へ
		while M_NUM_GE([|${__sx_str_rfind_off_}|], [|0|]); do
			case "${__sx_str_rfind_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_str_rfind|], [|"${__sx_str_rfind_off_}:0"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_str_rfind|], [|''|], CLEANUP);;
			esac

			: $((__sx_str_rfind_off_ -= 1))
		done
	elif M_NUM_BOOL([|${4} & SX_STR_RFIND_GLOB|]); then
		# ==== グロブモード ====
		while M_STR_HAS([|"${__sx_str_rfind_tgt_}"|], [|${3}|]); do
			__sx_str_rfind_pre_="${__sx_str_rfind_tgt_%${3}*}"
			__sx_str_rfind_match_="${__sx_str_rfind_tgt_#${__sx_str_rfind_pre_}}"
			__sx_str_rfind_after_="${__sx_str_rfind_match_#${3}}"
			__sx_str_rfind_match_="${__sx_str_rfind_match_%${__sx_str_rfind_after_}}"
			__sx_str_rfind_sts_="${SX_EX_OK}"

			case "${__sx_str_rfind_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_str_rfind|], [|"${#__sx_str_rfind_pre_}:${#__sx_str_rfind_match_}"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_str_rfind|], [|"${__sx_str_rfind_match_}"|], CLEANUP);;
			esac

			case "${__sx_str_rfind_overlap_}" in
				0) __sx_str_rfind_tgt_="${__sx_str_rfind_pre_}";;
				*) __sx_str_rfind_tgt_="${__sx_str_rfind_pre_}${__sx_str_rfind_match_%?}";;
			esac
		done
	else
		# ==== リテラルモード ====
		while M_STR_HAS([|"${__sx_str_rfind_tgt_}"|], [|"${3}"|]); do
			__sx_str_rfind_pre_="${__sx_str_rfind_tgt_%"${3}"*}"
			__sx_str_rfind_sts_="${SX_EX_OK}"

			case "${__sx_str_rfind_text_}" in
				0) __M_BIND_UNQUOTE([|__sx_str_rfind|], [|"${#__sx_str_rfind_pre_}:${#3}"|], CLEANUP);;
				*) __M_BIND_QUOTE([|__sx_str_rfind|], [|"${3}"|], CLEANUP);;
			esac

			case "${__sx_str_rfind_overlap_}" in
				0) __sx_str_rfind_tgt_="${__sx_str_rfind_pre_}";;
				*) __sx_str_rfind_tgt_="${__sx_str_rfind_pre_}${3%?}";;
			esac
		done
	fi

	eval ${__sx_str_rfind_out_:+"${__sx_str_rfind_bind_}=\"\${__sx_str_rfind_out_# }\""}

	set -- "${__sx_str_rfind_sts_-1}"
	unset CLEANUP
	return "${1}"
}

### sx_str_rot - 文字セット内で文字をシフトして変換する
##
## 使い方:
##   sx_str_rot 結果変数名 [元文字列 [文字セット [シフト量]]]
##
## 説明:
##   指定された文字セット内で各文字をシフト量だけ移動させる暗号変換を行う。
##   デフォルトは ROT13（SX_STR_ALPHA を13シフト）。
##   シフト量が正の場合は前方に、負の場合は後方に移動する。
##   文字セットに含まれない文字はそのまま保持される。
##
##   使用例:
##     sx_str_rot res "HELLO"              # → URYYB (ROT13)
##     sx_str_rot res "ABC" SX_STR_UPPER 3 # → DEF (Caesar)
##     sx_str_rot res "999" SX_STR_DIGIT 1 # → 000 (数字シフト)
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_rot() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rot "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int_inv ${4:+"${4}"} || return

	__sx_str_rot "${@}"
}

### __sx_str_rot - sx_str_rot の内部実装（内部用）
##
## 使い方:
##   __sx_str_rot 結果変数名 [元文字列 [文字セット [シフト量]]]
##
## 説明:
##   sx_str_rot の内部実装。引数チェックは行わない。
__sx_str_rot() {
	set -- "${1}" "${2-}" "${3-${SX_STR_ALPHA}}" "${4:-13}"

	case '' in "${2}" | "${3}")
		__sx_var_set "${1}=${2}"
		return "${SX_EX_OK}"
	esac

	SX_CFG_UNSET_SOFT=2 __sx_str_cycle __sx_str_rot_rotated_ "${3}" "${4}"
	__sx_str_tr "${1}:" "${2}" "${3}" "${__sx_str_rot_rotated_}"

	unset __sx_str_rot_rotated_
}

### sx_str_splice - 文字列の一部を削除し、そこに新しい文字列を挿入する
##
## 使い方:
##   sx_str_splice 結果変数名 文字列 開始位置 削除数 挿入文字列
##
## 説明:
##   文字列の「開始位置」（0開始）から「削除数」分の文字を取り除き、
##   そこに「挿入文字列」を挿入した結果を結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_splice() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_splice "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_num_is_sx_int_inv ${3+"${3}"} ${4+"${4}"} || return "${SX_EX_USAGE}"

	__sx_str_splice "${@}"
}

define([|V|], [|__sx_str_splice_$1_|]) dnl
define([|CLEANUP|], [|unset V(res) V(str) V(off) V(len) V(add) V(left) V(right) V(suffix) V(del)|]) dnl

### __sx_str_splice - 文字列の一部を削除し、そこに新しい文字列を挿入する（内部用）
##
## 使い方:
##   __sx_str_splice 結果変数名 文字列 開始位置 削除数 挿入文字列
##
## 説明:
##   sx_str_splice の内部実装。引数チェックは行わない。
__sx_str_splice() {
	V(res)="${1}"
	V(str)="${2-}"
	V(off)="${3-0}"
	V(len)="${4-${SX_NUM_I32_MAX}}"
	V(add)="${5-}"

	# 1. 前半部分を取得 (sx_str_substr は負数 off をサポート済み)
	__sx_str_substr V(left) "${V(str)}" 0 "${V(off)}"

	# 2. 残りの部分（suffix）を抽出
	V(suffix)="${V(str)#"${V(left)}"}"

	# 3. 削除される部分を取得（sx_str_substr の負数 len を利用）
	__sx_str_substr V(del) "${V(suffix)}" 0 "${V(len)}"

	# 4. 後半部分（削除範囲より後ろ）を抽出
	V(right)="${V(suffix)#"${V(del)}"}"

	# 5. 結合して格納
	__sx_var_set "${V(res)}=${V(left)}${V(add)}${V(right)}"

	CLEANUP
}

### sx_str_split - 文字列を分割して結果変数に格納する
##
## 使い方:
##   sx_str_split 結果変数名（またはバインド形式） [文字列 [区切り文字 [分割回数 [フラグ]]]]
##
## 説明:
##   指定された文字列を区切り文字で分割し、
##   各要素をシングルクォートで囲み、スペース区切りで結合した文字列として結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##   区切り文字に空文字列を指定した場合は、文字列を一文字ずつに分割する（境界線モデル）。
##   分割回数（limit）が指定された場合、最大でその回数分だけ分割を行う。
##   分割回数が正の場合は前方から、負の場合は後方から分割する。
##   フラグに SX_STR_SPLIT_GLOB を指定すると、区切り文字を glob パターンとして扱う。
##   フラグに SX_STR_SPLIT_INC を指定すると、分割に使用した区切り文字を結果に含める。
##   SX_STR_SPLIT_GLOB と併用した場合は、glob パターンに一致した実際の文字列を結果に含める。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_split() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_split "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_num_is_sx_int_inv ${4+"${4}"} ${5+"${5}"} || return "${SX_EX_USAGE}"

	__sx_str_split "${@}"
}

define([|V|], [|__sx_str_split_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(str) V(sep) V(lim) V(flg) V(inc) V(out) V(rem) V(mid) V(val) __M_BIND_USEVAR|])dnl

### __sx_str_split - 文字列を分割して結果変数に格納する（内部用）
##
## 使い方:
##   __sx_str_split 結果変数名 [文字列 [区切り文字 [分割回数 [フラグ]]]]
##
## 説明:
##   指定された文字列を区切り文字で分割し、結果変数に格納する。
##   分割回数（limit）が指定された場合、最大でその回数分だけ分割を行う。
##   分割回数が正の場合は前方から、負の場合は後方から分割する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_str_split() {
	__sx_var_bind_init "${1}"
	__sx_str_split_bind_="${1}"
	__sx_str_split_str_="${2-}"
	__sx_str_split_sep_="${3-}"
	__sx_str_split_lim_="$((${4-${SX_NUM_I32_MAX}}))"
	__sx_str_split_flg_="$((${5-0}))"
	__sx_str_split_inc_=$(((__sx_str_split_flg_ & SX_STR_SPLIT_INC) != 0))
	__sx_str_split_out_=

	set --

	# 空区切り文字（一文字ずつ分割）の処理
	if
		M_STR_EQ([|"${__sx_str_split_sep_}"|], [|''|]) ||
		{ M_NUM_BOOL([|__sx_str_split_flg_ & SX_STR_SPLIT_GLOB|]) && ! M_STR_HAS([|"${__sx_str_split_sep_}"|], [|*[!*]*|]); }
	then
		if M_NUM_LT([|0|], [|__sx_str_split_lim_|]); then
			# 前方から制限数分だけ分割
			SX_CFG_UNSET_SOFT=2 __sx_str_chunk __sx_str_split_out_ "${__sx_str_split_str_}" 1 "$((__sx_str_split_lim_ - 1))"

			case "$((${#__sx_str_split_str_} < __sx_str_split_lim_))" in 1)
				__sx_str_split_out_="${__sx_str_split_out_} ''"
			esac

			__sx_str_split_out_="'' ${__sx_str_split_out_# }"
		elif M_NUM_LT([|__sx_str_split_lim_|], [|0|]); then
			# 後方から制限数分だけ分割
			: $((__sx_str_split_lim_ *= -1))
			SX_CFG_UNSET_SOFT=2 __sx_str_chunk __sx_str_split_out_ "${__sx_str_split_str_}" -1 "$((__sx_str_split_lim_ - 1))"

			case "$((${#__sx_str_split_str_} < __sx_str_split_lim_))" in 1)
				__sx_str_split_out_="'' ${__sx_str_split_out_}"
			esac

			__sx_str_split_out_="${__sx_str_split_out_% } ''"
		else
			# 制限なし：文字列全体をクォートして格納
			SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_str_split_out_ "${__sx_str_split_str_}"
		fi

		case "${__sx_str_split_inc_}" in 1)
			eval SX_CFG_UNSET_SOFT=2 __sx_arg_isep __sx_str_split_out_ '"${SX_CFG_SEP}"' "${__sx_str_split_out_}"
		esac

		eval __sx_arg_quote '"${__sx_str_split_bind_}"' "${__sx_str_split_out_}"
	elif M_NUM_LE([|0|], [|__sx_str_split_lim_|]); then
		# 前方から分割
		if M_STR_NE([|$((__sx_str_split_flg_ & SX_STR_SPLIT_GLOB))|], [|0|]); then
			# グロブ（パターン）による前方分割
			while
				M_STR_HAS([|"${__sx_str_split_str_}"|], [|${__sx_str_split_sep_}|]) &&
				M_STR_NE([|"${__sx_str_split_lim_}"|], [|0|])
			do
				__sx_str_split_val_="${__sx_str_split_str_%%${__sx_str_split_sep_}*}"

				__M_BIND_QUOTE([|__sx_str_split|], [|"${__sx_str_split_val_}"|], CLEANUP)

				__sx_str_split_rem_="${__sx_str_split_str_#*${__sx_str_split_sep_}}"

				# 区切り文字を含めるフラグがある場合
				case "${__sx_str_split_inc_}" in 1)
					__sx_str_split_mid_="${__sx_str_split_str_#${__sx_str_split_val_}}"
					__M_BIND_QUOTE([|__sx_str_split|], [|"${__sx_str_split_mid_%${__sx_str_split_rem_}}"|], CLEANUP)
				esac

				__sx_str_split_str_="${__sx_str_split_rem_}"
				: $((__sx_str_split_lim_ -= 1))
			done
		else
			# 通常の文字列による前方分割
			while
				M_STR_HAS([|"${__sx_str_split_str_}"|], [|"${__sx_str_split_sep_}"|]) &&
				M_STR_NE([|"${__sx_str_split_lim_}"|], [|0|])
			do
				__M_BIND_QUOTE([|__sx_str_split|], [|"${__sx_str_split_str_%%"${__sx_str_split_sep_}"*}"|], CLEANUP)

				case "${__sx_str_split_inc_}" in 1)
					__M_BIND_QUOTE([|__sx_str_split|], [|"${__sx_str_split_sep_}"|], CLEANUP)
				esac

				__sx_str_split_str_="${__sx_str_split_str_#*"${__sx_str_split_sep_}"}"
				: $((__sx_str_split_lim_ -= 1))
			done
		fi

		__M_BIND_QUOTE([|__sx_str_split|], [|"${__sx_str_split_str_}"|], CLEANUP)

		eval ${__sx_str_split_out_:+"${__sx_str_split_bind_}=\"\${__sx_str_split_out_}\""}
	else
		# 後方から分割
		if M_STR_NE([|$((__sx_str_split_flg_ & SX_STR_SPLIT_GLOB))|], [|0|]); then
			# グロブ（パターン）による後方分割
			while
				M_STR_HAS([|"${__sx_str_split_str_}"|], [|${__sx_str_split_sep_}|]) &&
				M_STR_NE([|"${__sx_str_split_lim_}"|], [|0|])
			do
				set -- "${__sx_str_split_str_##*${__sx_str_split_sep_}}" "${@}"
				__sx_str_split_rem_="${__sx_str_split_str_%${__sx_str_split_sep_}*}"

				# 区切り文字を含めるフラグがある場合
				case "${__sx_str_split_inc_}" in 1)
					__sx_str_split_mid_="${__sx_str_split_str_%${1}}"
					set -- "${__sx_str_split_mid_#${__sx_str_split_rem_}}" "${@}"
				esac

				__sx_str_split_str_="${__sx_str_split_rem_}"
				: $((__sx_str_split_lim_ += 1))
			done
		else
			# 通常の文字列による後方分割
			while
				M_STR_HAS([|"${__sx_str_split_str_}"|], [|"${__sx_str_split_sep_}"|]) &&
				M_STR_NE([|"${__sx_str_split_lim_}"|], [|0|])
			do
				set -- "${__sx_str_split_str_##*"${__sx_str_split_sep_}"}" "${@}"

				case "${__sx_str_split_inc_}" in 1)
					set -- "${__sx_str_split_sep_}" "${@}"
				esac

				__sx_str_split_str_="${__sx_str_split_str_%"${__sx_str_split_sep_}"*}"
				: $((__sx_str_split_lim_ += 1))
			done
		fi

		__sx_arg_quote "${__sx_str_split_bind_}" "${__sx_str_split_str_}" "${@}"
	fi

	unset CLEANUP
}

### sx_str_split_ifs - 現在の IFS を使用して文字列を単語分割し、結果を変数に格納する
##
## 使い方:
##   IFS=',' sx_str_split_ifs 結果変数名 [文字列 ...]
##
## 説明:
##   現在の IFS（内部フィールド区切り文字）を用いて、第2引数以降の文字列を
##   単語分割（Word Splitting）し、各単語をシングルクォートで囲み、
##   スペース区切りで結合した文字列として結果変数に格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_split_ifs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_split_ifs "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_str_split_ifs "${@}" || return
}

### __sx_str_split_ifs - 現在の IFS を使用して文字列を単語分割し、結果を変数に格納する（内部用）
##
## 使い方:
##   __sx_str_split_ifs 結果変数名 [文字列 ...]
##
## 説明:
##   引数チェックを行わずに単語分割処理を行う。
__sx_str_split_ifs() {
	__sx_str_split_ifs_res_="${1}"
	__sx_str_split_ifs_opts_="${-}"
	shift

	set -f
	set -- ${*}

	case "${__sx_str_split_ifs_opts_}" in *f*) ;; *)
		set +f
	esac

	__sx_arg_quote "${__sx_str_split_ifs_res_}" "${@}"

	unset __sx_str_split_ifs_res_ __sx_str_split_ifs_opts_
}

### sx_str_squish - XSLT normalize-space 相当（trim + collapse）
##
## 使い方:
##   sx_str_squish 結果変数名 [文字列 [文字セット [区切り文字]]]
##
## 説明:
##   文字列の先頭と末尾から文字セットに含まれる文字を削除し、
##   内部の連続する文字セット文字を指定された区切り文字で置き換える。
##   文字セット省略時は SX_STR_SPACE（空白文字すべて）、
##   区切り文字省略時は半角スペース。
##   XSLT/XPath の normalize-space() 相当の機能。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_squish() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_squish "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_str_squish "${@}"
}

### __sx_str_squish - XSLT normalize-space 相当（内部用）
##
## 使い方:
##   __sx_str_squish 結果変数名 [文字列 [文字セット [区切り文字]]]
##
## 説明:
##   sx_str_squish の内部実装。
##   引数チェックは行わない。
__sx_str_squish() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}" "${4- }"

	case "${3}" in '')
		__sx_var_set "${1}=${2}"
		return
	esac

	SX_CFG_UNSET_SOFT=2 __sx_str_trim __sx_str_squish_str_ "${2}" "${3}"

	__sx_str_squish_out_=
	while M_STR_HAS([|"${__sx_str_squish_str_}"|], [|["${3}"]|]); do
		__sx_str_squish_out_="${__sx_str_squish_out_}${__sx_str_squish_str_%%["${3}"]*}${4}"
		__sx_str_squish_str_="${__sx_str_squish_str_#*["${3}"]}"
		__sx_str_squish_str_="${__sx_str_squish_str_#"${__sx_str_squish_str_%%[!"${3}"]*}"}"
	done

	__sx_var_set "${1}=${__sx_str_squish_out_}${__sx_str_squish_str_}"
	unset __sx_str_squish_str_ __sx_str_squish_out_
}

### sx_str_strim - 文字列の先頭から指定された文字セットを削除する
##
## 使い方:
##   sx_str_strim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   文字列の先頭にある、指定された文字セットに含まれる文字をすべて削除して結果変数に格納する。
##   文字セットが省略された場合は、SX_STR_SPACE（空白文字すべて）が使用される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_strim() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_strim "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_str_strim "${@}"
}

### __sx_str_strim - 文字列の先頭から指定された文字セットを削除する（内部用）
##
## 使い方:
##   __sx_str_strim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   sx_str_strim の内部実装。
##   引数チェックは行わない。
__sx_str_strim() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}"

	case "${3}" in '')
		__sx_var_set "${1}=${2}"
		return "${SX_EX_OK}"
	esac

	__sx_var_set "${1}=${2#"${2%%[!"${3}"]*}"}"
}

### sx_str_sub - 文字列内のパターンを置換する
##
## 使い方:
##   sx_str_sub 結果変数名 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   元文字列の中に含まれる検索パターンを、置換文字列に置き換えて結果変数に格納する。
##   省略された引数は、元文字列・検索パターン・置換文字列が空文字列、
##   回数制限が 2147483647（無制限）として扱われる。
##   検索パターンが空文字列の場合は、各文字の間および両端に置換文字列を挿入する。
##   回数制限（limit）が正の場合は前方から、負の場合は後方から指定された回数分だけ置換を行う。
##   フラグに SX_STR_SUB_GLOB を指定すると、検索パターンを glob パターンとして扱う。
##   フラグに SX_STR_SUB_CB を指定すると、第4引数を置換文字列ではなくコールバック関数名として扱う。
##   コールバック関数は以下の形式で呼び出される:
##     関数名 結果変数名 マッチ文字列 left(未置換) right(未置換) マッチ回数(1〜)
##     left: マッチ箇所より左側の文字列 (Left context)
##     right: マッチ箇所より右側の文字列 (Right context)
##   その実行結果（第1引数の変数に格納された値）が置換後の文字列として使用される。
##   コールバック関数が非0の値を返した場合、そこで置換処理を中断する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_sub() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_sub "${@}" || return; return; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_num_is_sx_int_inv ${5:+"${5}"} && __sx_num_is_sx_nat0 ${6:+"${6}"} || return "${SX_EX_USAGE}"

	__sx_str_sub "${@}" || return
}

### __sx_str_sub - 文字列内のパターンを置換する（ディスパッチャ）
##
## 使い方:
##   __sx_str_sub 結果変数名 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   sx_str_sub の内部実装。フラグに応じてリテラル/Glob 置換または
##   コールバック置換を __sx_str_sub_lit / __sx_str_sub_cb に委譲する。
##   引数チェックは行わない。
__sx_str_sub() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "$((${5:-${SX_NUM_I32_MAX}}))" "${6-0}"

	case "$((${6} & SX_STR_SUB_CB))" in
		0) __sx_str_sub_lit "${@}";;
		*) __sx_str_sub_cb "${@}";;
	esac || return
}

### __sx_str_sub_isep_adapt - sx_str_isep のコールバックを sx_str_sub の形式に変換する
##
## 使い方:
##   __sx_str_sub_isep_adapt 結果変数名 left right count
##
## 説明:
##   sx_str_isep のコールバック形式 (ret_var, left, right, count) を
##   sx_str_sub のコールバック形式 (ret_var, match, left, right, count) に変換する。
##   空パターン時の match は常に空文字列となる。
##   実際の呼び出し先は変数 __sx_str_sub_isep_adapt_cb_ で指定する。
__sx_str_sub_isep_adapt() {
	"${__sx_str_sub_isep_adapt_cb_}" "${1}" '' "${2}" "${3}" "${4}"
}

### __sx_str_sub_cb - 文字列内のパターンをコールバック置換する（内部用）
##
## 使い方:
##   __sx_str_sub_cb 結果変数名 [元文字列 [検索パターン [コールバック [回数制限 [フラグ]]]]]
##
## 説明:
##   __sx_str_sub からコールバックモードを抽出した内部関数。
##   パターンが空の場合は __sx_str_isep に委譲する。
__sx_str_sub_cb() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "${5-}" "$((${6-0} & SX_STR_SUB_GLOB))" "" 0 ""

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${6}|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		__sx_str_sub_isep_adapt_cb_="${4}" SX_CFG_UNSET_SOFT=2 __sx_str_isep "${1}" "${2}" __sx_str_sub_isep_adapt "$((${5} < 0 ? -1 : 1))" "$((${5} < 0 ? 0 - ${5} : ${5}))" "$((SX_STR_ISEP_PRE | SX_STR_ISEP_POST | SX_STR_ISEP_CB))" || return
	elif M_NUM_LE([|0|], [|${5}|]); then
		if M_STR_EQ([|"${6}"|], [|0|]); then
			while M_STR_HAS([|"${2}"|], [|"${3}"|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2%%"${3}"*}"
				set -- "${1}" "${2#*"${3}"}" "${3}" "${4}" "${5}" "${6}" "${7}${10}" "$((${8} + 1))" "${9}${10}"

				"${4}" __sx_str_sub_cb_ret_ "${3}" "${9}" "${2}" "${8}" || {
					set -- "${@}" "${?}"
					__sx_str_sub_cb_ret_="${3}"
				}

				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${__sx_str_sub_cb_ret_-${3}}" "$((${10-0} ? ${5} : ${8}))" "${9}${3}" ${10+"${10}"}
				unset __sx_str_sub_cb_ret_
			done
		else
			while M_STR_HAS([|"${2}"|], [|${3}|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2%%${3}*}" "${2#*${3}}"
				set -- "${@}" "${2#"${10}"}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${7}${10}" "$((${8} + 1))" "${9}${10}" "${12%"${11}"}"

				"${4}" __sx_str_sub_cb_ret_ "${10}" "${9}" "${2}" "${8}" || {
					set -- "${@}" "${?}"
					__sx_str_sub_cb_ret_="${10}"
				}

				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${__sx_str_sub_cb_ret_-${10}}" "$((${11-0} ? ${5} : ${8}))" "${9}${10}" ${11+"${11}"}
				unset __sx_str_sub_cb_ret_
			done
		fi

		__sx_var_set "${1}=${7}${2}"
	else
		set -- "${1}" "${2}" "${3}" "${4}" "${5#-}" "${6}" "${7}" "${8}" "${9}"

		if M_STR_EQ([|"${6}"|], [|0|]); then
			while M_STR_HAS([|"${2}"|], [|"${3}"|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2##*"${3}"}"
				set -- "${1}" "${2%"${3}"*}" "${3}" "${4}" "${5}" "${6}" "${10}${7}" "$((${8} + 1))" "${10}${9}"

				"${4}" __sx_str_sub_cb_ret_ "${3}" "${2}" "${9}" "${8}" || {
					set -- "${@}" "${?}"
					__sx_str_sub_cb_ret_="${3}"
				}

				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${__sx_str_sub_cb_ret_-${3}}${7}" "$((${10-0} ? ${5} : ${8}))" "${3}${9}" ${10+"${10}"}
				unset __sx_str_sub_cb_ret_
			done
		else
			while M_STR_HAS([|"${2}"|], [|${3}|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2##*${3}}" "${2%${3}*}"
				set -- "${@}" "${2%"${10}"}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${10}${7}" "$((${8} + 1))" "${10}${9}" "${12#"${11}"}"

				"${4}" __sx_str_sub_cb_ret_ "${10}" "${2}" "${9}" "${8}" || {
					set -- "${@}" "${?}"
					__sx_str_sub_cb_ret_="${10}"
				}

				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${__sx_str_sub_cb_ret_-${10}}${7}" "$((${11-0} ? ${5} : ${8}))" "${10}${9}" ${11+"${11}"}
				unset __sx_str_sub_cb_ret_
			done
		fi

		__sx_var_set "${1}=${2}${7}"
	fi

	return "${10-0}"
}

### __sx_str_sub_lit - 文字列内のパターンをリテラル/Glob置換する（内部用）
##
## 使い方:
##   __sx_str_sub_lit 結果変数名 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   __sx_str_sub からリテラル/Globモードを抽出した内部関数。
##   パターンが空の場合は __sx_str_isep に委譲する。
__sx_str_sub_lit() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "${5-}" "$((${6-0} & SX_STR_SUB_GLOB))" ""

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${6}|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		SX_CFG_UNSET_SOFT=2 __sx_str_isep "${1}" "${2}" "${4}" "$((${5} < 0 ? -1 : 1))" "$((${5} < 0 ? 0 - ${5} : ${5}))" "$((SX_STR_ISEP_PRE | SX_STR_ISEP_POST))"
	elif M_NUM_LE([|0|], [|${5}|]); then
		if M_STR_EQ([|"${6}"|], [|0|]); then
			while M_STR_HAS([|"${2}"|], [|"${3}"|]) && M_NUM_NE([|${5}|], [|0|]); do
				set -- "${1}" "${2#*"${3}"}" "${3}" "${4}" "$((${5} - 1))" "${6}" "${7}${2%%"${3}"*}${4}"
			done
		else
			while M_STR_HAS([|"${2}"|], [|${3}|]) && M_NUM_NE([|${5}|], [|0|]); do
				set -- "${1}" "${2#*${3}}" "${3}" "${4}" "$((${5} - 1))" "${6}" "${7}${2%%${3}*}${4}"
			done
		fi

		__sx_var_set "${1}=${7}${2}"
	elif M_NUM_LT([|${5}|], [|0|]); then
		if M_STR_EQ([|"${6}"|], [|0|]); then
			while M_STR_HAS([|"${2}"|], [|"${3}"|]) && M_NUM_NE([|${5}|], [|0|]); do
				set -- "${1}" "${2%"${3}"*}" "${3}" "${4}" "$((${5} + 1))" "${6}" "${4}${2##*"${3}"}${7}"
			done
		else
			while M_STR_HAS([|"${2}"|], [|${3}|]) && M_NUM_NE([|${5}|], [|0|]); do
				set -- "${1}" "${2%${3}*}" "${3}" "${4}" "$((${5} + 1))" "${6}" "${4}${2##*${3}}${7}"
			done
		fi

		__sx_var_set "${1}=${2}${7}"
	fi
}

### sx_str_substr - 文字列の指定した位置から指定した長さの部分文字列を取得する
##
## 使い方:
##   sx_str_substr 結果変数名 [元文字列 [オフセット [長さ]]]
##
## 説明:
##   元文字列のオフセット（0開始）から指定された長さ分だけ抽出し、結果変数に格納する。
##   オフセットが負の場合は、文字列末尾からの位置として扱う。
##   負のオフセットが文字列長を超える場合は先頭から抽出する。
##   長さが省略された場合、または末尾を超える場合は末尾まで抽出する。
##   長さが負の場合は、抽出対象の末尾から指定文字数を除外する。
##   オフセットが文字列長以上の場合は空文字列を返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_substr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_substr "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_num_is_sx_int_inv ${3+"${3}"} ${4+"${4}"} || return "${SX_EX_USAGE}"

	__sx_str_substr "${@}"
}

define([|V|], [|__sx_str_substr_$1_|]) dnl
define([|CLEANUP|], [|unset V(res) V(str) V(off) V(len) V(total) V(drop) V(qm)|]) dnl

### __sx_str_substr - 文字列の部分文字列を取得する（内部用）
##
## 使い方:
##   __sx_str_substr 結果変数名 [元文字列 [オフセット [長さ]]]
##
## 説明:
##   sx_str_substr の内部実装。
##   引数チェックは行わない。
__sx_str_substr() {
	V(res)="${1}"
	V(str)="${2-}"
	V(off)="$((${3-0}))"
	V(len)="$((${4-${SX_NUM_I32_MAX}}))"
	V(total)="${#V(str)}"

	# オフセットの正規化 (負数は末尾から)
	case "$((V(off) < 0))" in 1)
		V(off)=$(((V(off) * -1) < V(total) ? V(total) + V(off) : 0))
	esac

	# 1. オフセット分をスキップ
	if M_NUM_LE([|V(total)|], [|V(off)|]); then
		V(str)=
	else
		__sx_str_rep V(qm) '?' "${V(off)}"
		V(str)="${V(str)#${V(qm)}}"
	fi

	# 長さの正規化 (負数は末尾から削る)
	V(total)="${#V(str)}"
	if M_NUM_LE([|0|], [|V(len)|]); then
		V(drop)=$((V(len) < V(total) ? V(total) - V(len) : 0))
	else
		V(drop)=$((V(len) * -1))
	fi

	# 2. 指定長に切り詰め
	if M_NUM_LT([|V(drop)|], [|V(total)|]); then
		__sx_str_rep V(qm) '?' "${V(drop)}"
		V(str)="${V(str)%${V(qm)}}"
	else
		V(str)=
	fi

	__sx_var_set "${V(res)}=${V(str)}"
	CLEANUP
}

### sx_str_sw - 第一引数が、第二引数以降のいずれかの文字列で始まっているか確認する
##
## 使い方:
##   sx_str_sw [検索対象文字列 [開始文字列1 [開始文字列2 ...]]]
##
## 挙動:
## - 検索対象文字列が省略された場合は空文字列とみなす
## - 開始文字列は 0 個以上指定できる
## - 第二引数以降のいずれかが検索対象文字列の接頭辞であれば成功する
## - 開始文字列が 1 つも指定されなかった場合は失敗する
## - 開始文字列に空文字列が含まれる場合は常に成功する
##
## 終了ステータス:
##    0  いずれかの開始文字列で始まっている (SX_EX_OK)
##    1  一致する開始文字列がない
sx_str_sw() {
	__sx_str_sw_tgt="${1-}"
	shift "$((0 < ${#}))"

	for __sx_str_sw_arg in "${@}"; do
		case "${__sx_str_sw_tgt}" in "${__sx_str_sw_arg}"*)
			unset __sx_str_sw_tgt __sx_str_sw_arg
			return "${SX_EX_OK}"
		esac
	done

	unset __sx_str_sw_tgt __sx_str_sw_arg
	return 1
}

### sx_str_tr - 文字列内の文字を対応する文字で変換する
##
## 使い方:
##   sx_str_tr 結果変数名 [文字列 [from文字列 [to文字列 [limit]]]]
##
## 説明:
##   文字列中の from に含まれる各文字を、to の対応する位置の文字で置換する。
##   from が空の場合は何もせずそのまま返す。
##   to に含まれない位置の文字（from が to より長い場合の超過分）は削除する。
##   to が from より長い場合、余剰の to の文字は無視される。
##   from に同一文字が複数ある場合、最初の出現位置が使用される。
##   limit で最大置換回数を指定できる。デフォルトは SX_NUM_I32_MAX（無制限）。
##   0 を指定すると置換を行わない。
##   負の値を指定すると末尾から置換する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_tr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_tr "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int_inv ${5:+"${5}"} || return

	__sx_str_tr "${@}"
}

### __sx_str_tr - 文字列内の文字を対応する文字で変換する（内部用）
##
## 使い方:
##   __sx_str_tr バインド形式 [文字列 [from文字列 [to文字列 [limit]]]]
##
## 説明:
##   sx_str_tr の内部実装。引数チェックは行わない。
##   バインド形式で置換結果と置換回数を取得できる。
##   例: res:（結果のみ）、res:cnt:（結果と回数）
__sx_str_tr() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "${5-}"

	__sx_var_bind_init "${1}"
	__sx_str_tr_bind_="${1}"
	__sx_str_tr_str_="${2}"
	__sx_str_tr_from_="${3}"
	__sx_str_tr_out_=
	__sx_str_tr_lim_="${5:-${SX_NUM_I32_MAX}}"
	__sx_str_tr_cnt_=0

	case "${3}" in
		'') __sx_var_bind __sx_str_tr_bind_ "${__sx_str_tr_bind_}" "${__sx_str_tr_str_}";;
		*)
			SX_CFG_UNSET_SOFT=2 __sx_str_chunk __sx_str_tr_to_ "${4}" 1
			eval set -- "${__sx_str_tr_to_}"

			if M_NUM_LT([|${__sx_str_tr_lim_}|], [|0|]); then
				__sx_str_tr_lim_="${__sx_str_tr_lim_#-}"

				while M_STR_HAS([|"${__sx_str_tr_str_}"|], [|["${__sx_str_tr_from_}"]|]) && M_NUM_LT([|__sx_str_tr_cnt_|], [|__sx_str_tr_lim_|]); do
					__sx_str_tr_suf_="${__sx_str_tr_str_##*["${__sx_str_tr_from_}"]}"
					__sx_str_tr_str_="${__sx_str_tr_str_%"${__sx_str_tr_suf_}"}"
					__sx_str_tr_pre_="${__sx_str_tr_str_%?}"
					__sx_str_tr_from_pre_="${__sx_str_tr_from_%%"${__sx_str_tr_str_#"${__sx_str_tr_pre_}"}"*}"
					__sx_str_tr_idx_="${#__sx_str_tr_from_pre_}"

					case "$((__sx_str_tr_idx_ < ${#}))" in
						1) eval "__sx_str_tr_out_=\"\${$((${__sx_str_tr_idx_} + 1))}\${__sx_str_tr_suf_}\${__sx_str_tr_out_}\"";;
						*) __sx_str_tr_out_="${__sx_str_tr_suf_}${__sx_str_tr_out_}";;
					esac

					__sx_str_tr_str_="${__sx_str_tr_pre_}"
					: $((__sx_str_tr_cnt_ += 1))
				done

				__sx_var_bind __sx_str_tr_bind_ "${__sx_str_tr_bind_}" "${__sx_str_tr_str_}${__sx_str_tr_out_}" "${SX_VAR_BIND_QUOTE}"
			else
				while M_STR_HAS([|"${__sx_str_tr_str_}"|], [|["${__sx_str_tr_from_}"]|]) && M_NUM_LT([|__sx_str_tr_cnt_|], [|__sx_str_tr_lim_|]); do
					__sx_str_tr_pre_="${__sx_str_tr_str_%%["${__sx_str_tr_from_}"]*}"
					__sx_str_tr_str_="${__sx_str_tr_str_#"${__sx_str_tr_pre_}"}"
					__sx_str_tr_suf_="${__sx_str_tr_str_#?}"
					__sx_str_tr_from_pre_="${__sx_str_tr_from_%%"${__sx_str_tr_str_%"${__sx_str_tr_suf_}"}"*}"
					__sx_str_tr_idx_="${#__sx_str_tr_from_pre_}"

					case "$((__sx_str_tr_idx_ < ${#}))" in
						1) eval "__sx_str_tr_out_=\"\${__sx_str_tr_out_}\${__sx_str_tr_pre_}\${$((${__sx_str_tr_idx_} + 1))}\"";;
						*) __sx_str_tr_out_="${__sx_str_tr_out_}${__sx_str_tr_pre_}";;
					esac

					__sx_str_tr_str_="${__sx_str_tr_suf_}"
					: $((__sx_str_tr_cnt_ += 1))
				done

				__sx_var_bind __sx_str_tr_bind_ "${__sx_str_tr_bind_}" "${__sx_str_tr_out_}${__sx_str_tr_str_}" "${SX_VAR_BIND_QUOTE}"
			fi
			;;
	esac && __sx_var_bind __sx_str_tr_bind_ "${__sx_str_tr_bind_}" "${__sx_str_tr_cnt_}" "${SX_VAR_BIND_QUOTE}" || :

	unset __sx_str_tr_bind_ __sx_str_tr_str_ __sx_str_tr_from_ __sx_str_tr_to_ __sx_str_tr_out_ __sx_str_tr_lim_ __sx_str_tr_cnt_ __sx_str_tr_pre_ __sx_str_tr_suf_ __sx_str_tr_from_pre_ __sx_str_tr_idx_
}

### sx_str_trim - 文字列の前後から指定された文字セットを削除する
##
## 使い方:
##   sx_str_trim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   文字列の前後にある、指定された文字セットに含まれる文字をすべて削除して結果変数に格納する。
##   文字セットが省略された場合は、SX_STR_SPACE（空白文字すべて）が使用される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_trim() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_trim "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_str_trim "${@}"
}

### __sx_str_trim - 文字列の前後から指定された文字セットを削除する（内部用）
##
## 使い方:
##   __sx_str_trim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   sx_str_trim の内部実装。
##   引数チェックは行わない。
__sx_str_trim() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}"

	SX_CFG_UNSET_SOFT=2 __sx_str_strim __sx_str_trim_tmp_ "${2}" "${3}"
	__sx_str_etrim "${1}" "${__sx_str_trim_tmp_}" "${3}"

	unset __sx_str_trim_tmp_
}

### sx_str_upper - 文字列内のラテン小文字を大文字に変換する
##
## 使い方:
##   sx_str_upper 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   指定された文字列内のラテン小文字 (a-z) を大文字 (A-Z) に変換し、
##   結果を結果変数に格納する。既に大文字の文字や非アルファベット文字は
##   そのまま保持される。
##   回数制限が正の値の場合は前方から、負の値の場合は後方から
##   指定された回数分だけ変換を行う。省略時は無制限。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_upper() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_upper "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int_inv ${3:+"${3}"} || return

	__sx_str_upper "${@}"
}

### __sx_str_upper - 文字列内のラテン小文字を大文字に変換する（内部用）
##
## 使い方:
##   __sx_str_upper 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   sx_str_upper の内部実装。引数チェックは行わない。
__sx_str_upper() {
	__sx_str_tr "${1}:" "${2-}" "${SX_STR_LOWER}" "${SX_STR_UPPER}" "${3:-${SX_NUM_I32_MAX}}"
}

### __sx_str_upper_cb - sx_str_upper 用コールバック（内部用）
##
## 使い方:
##   __sx_str_upper_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   マッチした小文字1文字を大文字に変換して結果変数に格納する。
__sx_str_upper_cb() {
	case "${2}" in
		a) eval "${1}=A";; b) eval "${1}=B";;
		c) eval "${1}=C";; d) eval "${1}=D";;
		e) eval "${1}=E";; f) eval "${1}=F";;
		g) eval "${1}=G";; h) eval "${1}=H";;
		i) eval "${1}=I";; j) eval "${1}=J";;
		k) eval "${1}=K";; l) eval "${1}=L";;
		m) eval "${1}=M";; n) eval "${1}=N";;
		o) eval "${1}=O";; p) eval "${1}=P";;
		q) eval "${1}=Q";; r) eval "${1}=R";;
		s) eval "${1}=S";; t) eval "${1}=T";;
		u) eval "${1}=U";; v) eval "${1}=V";;
		w) eval "${1}=W";; x) eval "${1}=X";;
		y) eval "${1}=Y";; z) eval "${1}=Z";;
		*) eval "${1}=\"\${2}\"";;
	esac
}

### sx_str_swapcase - ラテン文字の大文字と小文字を反転する
##
## 使い方:
##   sx_str_swapcase 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   指定された文字列内のラテン大文字 (A-Z) を小文字 (a-z) に、
##   ラテン小文字 (a-z) を大文字 (A-Z) に変換し、
##   結果を結果変数に格納する。アルファベット以外の文字はそのまま保持される。
##   回数制限が正の値の場合は前方から、負の値の場合は後方から
##   指定された回数分だけ変換を行う。省略時は無制限。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_swapcase() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_swapcase "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int_inv ${3:+"${3}"} || return

	__sx_str_swapcase "${@}"
}

### __sx_str_swapcase - ラテン文字の大文字と小文字を反転する（内部用）
##
## 使い方:
##   __sx_str_swapcase 結果変数名 [元文字列 [回数制限]]
##
## 説明:
##   sx_str_swapcase の内部実装。引数チェックは行わない。
__sx_str_swapcase() {
	__sx_str_tr "${1}:" "${2-}" "${SX_STR_UPPER}${SX_STR_LOWER}" "${SX_STR_LOWER}${SX_STR_UPPER}" "${3:-${SX_NUM_I32_MAX}}"
}


### sx_str_title - 各単語の先頭を大文字、残りを小文字に変換する
##
## 使い方:
##   sx_str_title 結果変数名 [元文字列 [単語区切り文字セット]]

## 説明:
##   指定された文字列内の各単語の先頭文字を大文字に、残りの文字を小文字に変換する。
##   単語の区切りは単語区切り文字セットで判断する。デフォルトは ${SX_STR_SPACE}
##   （空白文字すべて）。文字セット内の各文字が単語区切りとして扱われる。
##   文字列先頭も単語の先頭として扱う。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_title() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_title "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_str_title "${@}"
}

### __sx_str_title - 各単語の先頭を大文字、残りを小文字に変換する（内部用）
##
## 使い方:
##   __sx_str_title 結果変数名 [元文字列 [単語区切り文字セット]]
##
## 説明:
##   sx_str_title の内部実装。sx_str_tr で一括小文字化した後、
##   セパレータ+小文字のペアを sx_str_sub のコールバックモードで検出して大文字化する。
__sx_str_title() {
	set -- "${1}" "${2-}" "${3:-${SX_STR_SPACE}}"

	SX_CFG_UNSET_SOFT=2 __sx_glob_bracket __sx_str_title_gs_ "${3}"
	SX_CFG_UNSET_SOFT=2 __sx_str_tr __sx_str_title_tmp_: "${2-}" "${SX_STR_UPPER}" "${SX_STR_LOWER}" "${SX_NUM_I32_MAX}"
	SX_CFG_UNSET_SOFT=2 __sx_str_sub __sx_str_title_tmp_ "${3%"${3#?}"}${__sx_str_title_tmp_}" "${__sx_str_title_gs_}[${SX_STR_LOWER}]" __sx_str_title_cb "${SX_NUM_I32_MAX}" "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"

	__sx_var_set "${1}=${__sx_str_title_tmp_#?}"
	unset __sx_str_title_tmp_ __sx_str_title_gs_
}

### __sx_str_title_cb - sx_str_title 用コールバック（内部用）
##
## 使い方:
##   __sx_str_title_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   マッチ文字列（セパレータ文字+小文字）の小文字部分を大文字に変換する。
__sx_str_title_cb() {
	__sx_str_upper_cb "${1}" "${2#?}"
	eval "${1}=\"\${2%?}\${${1}}\""
}

### sx_str_capital - 文頭または最初のアルファベットを大文字化し、他を小文字化する
##
## 使い方:
##   sx_str_capital 結果変数名 [元文字列 [フラグ]]
##
## 説明:
##   指定された文字列のアルファベットを大文字化・小文字化する。
##   デフォルトでは、文字列の先頭（インデックス0）がアルファベットの場合のみ
##   それを大文字にし、以降のアルファベットをすべて小文字にする。
##
## フラグ:
##   1 (SX_STR_CAPITAL_KEEP):
##     大文字化（または維持）のみを行い、他の文字のケースを維持する。
##   2 (SX_STR_CAPITAL_SENT):
##     文字列の先頭に限らず、最初に出現したアルファベットを大文字化の対象とする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_capital() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_capital "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 ${3:+"${3}"} || return

	__sx_str_capital "${@}"
}

### __sx_str_capital - sx_str_capital の内部実装（内部用）
##
## 使い方:
##   __sx_str_capital 結果変数名 [元文字列 [フラグ]]
##
## 説明:
##   sx_str_capital の内部実装。引数チェックは行わない。
__sx_str_capital() {
	set -- "${1}" "${2-}" "${3:-0}"
	__sx_str_capital_str_="${2}"
	__sx_str_capital_out_=

	case "$(((${3} & SX_STR_CAPITAL_SENT) != 0))${2}" in 0["${SX_STR_ALPHA}"]* | 1*["${SX_STR_ALPHA}"]*)
		__sx_str_capital_out_="${2%%["${SX_STR_ALPHA}"]*}"
		__sx_str_capital_str_="${2#"${__sx_str_capital_out_}"}"
		__sx_str_upper_cb __sx_str_capital_tmp_ "${__sx_str_capital_str_%"${__sx_str_capital_str_#?}"}"
		__sx_str_capital_out_="${__sx_str_capital_out_}${__sx_str_capital_tmp_}"
		__sx_str_capital_str_="${__sx_str_capital_str_#?}"
	esac

	case "$((${3} & SX_STR_CAPITAL_KEEP))" in 0)
		SX_CFG_UNSET_SOFT=2 __sx_str_lower __sx_str_capital_str_ "${__sx_str_capital_str_}"
	esac

	__sx_var_set "${1}=${__sx_str_capital_out_}${__sx_str_capital_str_}"
	unset __sx_str_capital_str_ __sx_str_capital_out_ __sx_str_capital_tmp_
}

### sx_str_cycle - 文字列を指定された位置だけ循環させる
##
## 使い方:
##   sx_str_cycle 結果変数名 [元文字列 [シフト量]]
##
## 説明:
##   元文字列を指定されたシフト量だけ左方向に循環シフトする。
##   シフト量が負の場合は右方向に循環シフトする。
##   例えば "ABCDE" を 2 シフトすると "CDEAB"、-1 シフトすると "EABCD" となる。
##   シフト量が文字列長を超える場合は、文字列長で割った余りを使用する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_cycle() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_cycle "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int_inv ${3:+"${3}"} || return

	__sx_str_cycle "${@}"
}

### __sx_str_cycle - sx_str_cycle の内部実装（内部用）
##
## 使い方:
##   __sx_str_cycle 結果変数名 [元文字列 [シフト量]]
##
## 説明:
##   sx_str_cycle の内部実装。引数チェックは行わない。
__sx_str_cycle() {
	set -- "${1}" "${2-}" "${3:-1}"
	set -- "${@}" "${#2}"
	set -- "${1}" "${2}" "$((${3} % (${4} ? ${4} : 1)))" "${4}"

	case ${3} in 0)
		__sx_var_set "${1}=${2}"
		return "${SX_EX_OK}"
	esac

	SX_CFG_UNSET_SOFT=2 __sx_str_chunk __sx_str_cycle_head_:__sx_str_cycle_tail_: "${2}" "$((0 < ${3} ? ${3} : ${3} + ${4}))" 1
	__sx_var_set "${1}=${__sx_str_cycle_tail_}${__sx_str_cycle_head_}"

	unset __sx_str_cycle_head_ __sx_str_cycle_tail_
}

### sx_str_words - 命名規則を自動検出して単語に分割する
##
## 使い方:
##   sx_str_words 結果変数名 [文字列]
##
## 説明:
##   入力文字列の命名規則を自動検出し、単語をスペース区切りの小文字で
##   結果変数に格納する。
##   以下の命名規則に対応:
##   - snake_case: _ で分割
##   - kebab-case: - で分割
##   - camelCase / PascalCase: 大文字の境界で分割
##   - 連続大文字（頭字語）も適切に扱う
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_words() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_words "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_DATAERR}" sx_num_is_sx_nat0 ${2+"${#2}"} || return

	__sx_str_words "${@}"
}

### __sx_str_words - 命名規則を自動検出して単語に分割する（内部用）
##
## 使い方:
##   __sx_str_words 結果変数名 [文字列 [区切り文字 [区切り文字セット]]]
##
## 説明:
##   sx_str_words の内部実装。引数チェックは行わない。
##   sx_str_sub のコールバックモードで大文字位置を検出し、
##   区切り文字セットの先頭文字を挿入した後、小文字化、
##   区切り文字セット内の文字を区切り文字に置換する。
__sx_str_words() {
	set -- "${1}" "${2-}" "${3:- }" "${4:-"_-/.:${SX_STR_SPACE}"}"

	__sx_str_words_cb_c_="${4%"${4#?}"}" SX_CFG_UNSET_SOFT=2 __sx_str_sub __sx_str_words_tmp_ "${2}" "[${SX_STR_UPPER}]" __sx_str_words_cb '' "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"
	SX_CFG_UNSET_SOFT=2 __sx_str_squish __sx_str_words_tmp_ "${__sx_str_words_tmp_}" "${4}" "${3}"
	__sx_str_lower "${1}" "${__sx_str_words_tmp_}"

	unset __sx_str_words_tmp_
}

### __sx_str_words_cb - sx_str_words 用コールバック（内部用）
##
## 使い方:
##   __sx_str_words_cb 結果変数名 マッチ文字列 left right count
##
## 説明:
##   sx_str_sub のコールバックモードから呼び出される。
##   大文字の前後を判定し、単語境界なら _ を挿入する。
__sx_str_words_cb() {
	case "${3}" in
		'') eval "${1}=\"\${2}\"";;
		*[a-z]) eval "${1}=\"\${__sx_str_words_cb_c_}\${2}\"";;
		*[A-Z])
			case "${4}" in
				[a-z]*) eval "${1}=\"\${__sx_str_words_cb_c_}\${2}\"";;
				*) eval "${1}=\"\${2}\"";;
			esac
			;;
		*) eval "${1}=\"\${2}\"";;
	esac
}

# ========================================
#  GLOB (Glob Pattern Operations)
# ========================================

### sx_glob_bracket - 文字セットを glob ブラケット式で安全な形に並べ替える
##
## 使い方:
##   sx_glob_bracket 結果変数名 [文字セット]
##
## 説明:
##   指定された文字セットを、glob のブラケット式 [...] 内で安全に使用できる
##   順序に並べ替える。以下の処理を行う:
##   - ] は必ず先頭に配置
##   - - は末尾に配置
##   - ! = . : は末尾に配置（先頭にあると否定・等価クラス・照合記号・文字クラスと解釈されるため）
##   結果は [...] で囲まれたブラケット式として返される。
##   ただし、文字セットが ! のみの場合はブラケット式として表現できないため ! をそのまま返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_glob_bracket() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_bracket "${@}"; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return
	case "${2-}" in '')
		__sx_ex_remap "1:${SX_EX_USAGE}" false || return
	esac

	__sx_glob_bracket "${@}"
}

### __sx_glob_bracket - 文字セットを glob ブラケット式で安全な形に並べ替える（内部用）
##
## 使い方:
##   __sx_glob_bracket 結果変数名 文字セット
##
## 説明:
##   sx_glob_bracket の内部実装。引数チェックは行わない。
##
## 終了ステータス:
##   常に 0 (SX_EX_OK)
__sx_glob_bracket() {
	case "${2}" in
		*[!^!]*) ;;
		!*^* | ^*!*)
			__sx_var_set "${1}=[[.!.]^]"
			return "${SX_EX_OK}"
			;;
		*)
			__sx_var_set "${1}=${2%"${2#?}"}"
			return "${SX_EX_OK}"
	esac

	case "${2}" in *']'*)
		__sx_glob_bracket_pre_=']'
	esac

	case "${2}" in *'\'*)
		__sx_glob_bracket_suf_='\\'
	esac

	for __sx_glob_bracket_c_ in = . : '!' '^' -; do
		case "${2}" in *"${__sx_glob_bracket_c_}"*)
			__sx_glob_bracket_suf_="${__sx_glob_bracket_suf_-}${__sx_glob_bracket_c_}"
		esac
	done

	SX_CFG_UNSET_SOFT=2  __sx_str_tr __sx_glob_bracket_rest_: "${2}" ']\.:=!^-'

	__sx_glob_bracket_rest_="${__sx_glob_bracket_pre_-}${__sx_glob_bracket_rest_}${__sx_glob_bracket_suf_-}"

	case "${__sx_glob_bracket_rest_}" in '!-' | '^-' | '!^-')
		__sx_glob_bracket_rest_="-${__sx_glob_bracket_rest_%-}"
	esac

	__sx_var_set "${1}=[${__sx_glob_bracket_rest_}]"

	unset __sx_glob_bracket_pre_ __sx_glob_bracket_suf_ __sx_glob_bracket_c_ __sx_glob_bracket_rest_
}

### sx_glob_escape - 文字列内の glob 特殊文字をエスケープする
##
## 使い方:
##   sx_glob_escape 結果変数名 [文字列]
##
## 説明:
##   指定された文字列に含まれる glob 特殊文字（* ? [）を、
##   glob ブラケット式 [*] [?] [[] に変換する。
##   これにより、エスケープ後の文字列を case のパターン内で
##   安全に使用できる（リテラルマッチ）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_glob_escape() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_escape "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_glob_escape "${@}" || return
}

### __sx_glob_escape - 文字列内の glob 特殊文字をエスケープする（内部用）
##
## 使い方:
##   __sx_glob_escape 結果変数名 文字列
##
## 説明:
##   sx_glob_escape の内部実装。引数チェックは行わない。
__sx_glob_escape() {
	__sx_str_escape "${1}" "${2-}" '*?[' '[' ']' || return
}

# ========================================
#  ARR (Array Operations)
# ========================================

### sx_arr_at - 配列の要素を取得または存在確認する
##
## 使い方:
##   sx_arr_at 配列名 [結果変数名=インデックス | =インデックス | インデックス ...]
##
## 説明:
##   指定された sx 配列から要素を取得または存在確認を行う。
##   引数の形式によって挙動が異なる：
##     1. 結果変数名=インデックス : 指定したインデックスの値を結果変数に格納する。
##     2. インデックス           : そのインデックスが範囲内にあるか確認のみ行う。
##   複数の引数を指定した場合、それらすべてが有効なインデックスであれば 0 を返し、
##   代入も行われる。一つでも範囲外があれば 1 を返し、代入は一切行わない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  一つ以上のインデックスが範囲外
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  結果変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_at() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_at "${@}" || return; return 0;; esac

	# 1. 配列の妥当性チェック
	sx_var_is_arr "${1-}" || case "${?}" in
		1) return "${SX_EX_DATAERR}";;
		*) return "${?}";;
	esac

	__sx_arr_at_arr="${1}"
	eval "__sx_arr_at_len=\"\${${1}_len}\""
	shift

	__sx_arr_at_chk=
	for __sx_arr_at_pair in "${@}"; do
		__sx_arr_at_dest="${__sx_arr_at_pair%%=*}"
		__sx_arr_at_i="${__sx_arr_at_pair#*=}"

		__sx_num_is_base_nat0 10 "${__sx_arr_at_i}" || {
			unset __sx_arr_at_arr __sx_arr_at_len __sx_arr_at_chk __sx_arr_at_pair __sx_arr_at_dest __sx_arr_at_i
			return "${SX_EX_USAGE}"
		}

		# 範囲チェック
		case "$((__sx_arr_at_i < __sx_arr_at_len))" in 0)
			__sx_arr_at_err=
		esac

		case "${__sx_arr_at_pair}" in *?=*)
			# 変数名としての妥当性、および自己参照（ソース配列内への上書き）の禁止
			if
				! sx_var_is_name "${__sx_arr_at_dest}" ||
				M_STR_MATCH([|"${__sx_arr_at_dest}"|], [|"${__sx_arr_at_arr}"|], [|"${__sx_arr_at_arr}"_*|])
			then
				unset __sx_arr_at_arr __sx_arr_at_len __sx_arr_at_chk __sx_arr_at_pair __sx_arr_at_dest __sx_arr_at_i
				return "${SX_EX_USAGE}"
			fi

			# コピー連鎖式の構築 (src-dest)
			__sx_arr_at_chk="${__sx_arr_at_chk} ${__sx_arr_at_arr}_${__sx_arr_at_i}-${__sx_arr_at_dest}"
		esac
	done

	case "${__sx_arr_at_err+X}" in X)
		unset __sx_arr_at_arr __sx_arr_at_len __sx_arr_at_chk __sx_arr_at_pair __sx_arr_at_dest __sx_arr_at_i __sx_arr_at_err
		return 1
	esac

	eval set -- "${__sx_arr_at_chk}"
	unset __sx_arr_at_arr __sx_arr_at_len __sx_arr_at_chk __sx_arr_at_pair __sx_arr_at_dest __sx_arr_at_i

	case "${#}" in
		0) return "${SX_EX_OK}";;
	esac

	# 2. 書き込み可能性（構造を含む）の一括チェック
	eval __sx_var_is_copyable "${@}" || {
		return "${SX_EX_NOPERM}"
	}

	__sx_var_copy "${@}"
}

### __sx_arr_at - 配列の要素を取得または存在確認する（内部用）
##
## 使い方:
##   __sx_arr_at 配列名 [結果変数名=インデックス | =インデックス | インデックス ...]
##
## 説明:
##   sx_arr_at の内部実装。
##   引数チェックは行わない。
__sx_arr_at() {
	__sx_arr_at_chk_=
	__sx_arr_at_arr_="${1}"
	eval "__sx_arr_at_len_=\"\${${1}_len}\""
	shift

	for __sx_arr_at_pair_ in "${@}"; do
		__sx_arr_at_i_="${__sx_arr_at_pair_#*=}"

		# 範囲チェック
		case "$((__sx_arr_at_i_ < __sx_arr_at_len_))" in 0)
			unset __sx_arr_at_chk_ __sx_arr_at_arr_ __sx_arr_at_len_ __sx_arr_at_pair_ __sx_arr_at_i_
			return 1
		esac

		case "${__sx_arr_at_pair_}" in *?=*)
			__sx_arr_at_chk_="${__sx_arr_at_chk_} ${__sx_arr_at_arr_}_${__sx_arr_at_i_}-${__sx_arr_at_pair_%%=*}"
		esac
	done

	case "${__sx_arr_at_chk_}" in
		'')
			unset __sx_arr_at_chk_ __sx_arr_at_arr_ __sx_arr_at_len_ __sx_arr_at_pair_ __sx_arr_at_i_
			return "${SX_EX_OK}"
		;;
	esac

	eval __sx_var_copy "${__sx_arr_at_chk_}"
	unset __sx_arr_at_chk_ __sx_arr_at_arr_ __sx_arr_at_len_ __sx_arr_at_pair_ __sx_arr_at_i_
}
### sx_arr_gen - 配列を初期化し、要素を追加する
##
## 使い方:
##   sx_arr_gen 配列名 [値 ...]
##
## 説明:
##   指定された配列を新規に作成（または既存の配列を削除して再作成）し、
##   引数で指定された値を要素として追加する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_gen() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_gen "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return "${SX_EX_USAGE}"
	sx_arr_is_rw "${1}" 0 "$((${#} - 1))" || return "${SX_EX_NOPERM}"

	__sx_arr_gen "${@}"
}

### __sx_arr_gen - 配列を初期化し、要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_gen 配列名 [値 ...]
##
## 説明:
##   指定された配列を新規に作成し、引数で指定された値を要素として追加する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_arr_gen() {
	__sx_var_set "${1}=${SX_CFG_SIG_ARR}:" "${1}_len=0"
	__sx_arr_push "${@}"
}

### sx_arr_is_rw - 配列の指定範囲が書き込み可能か確認する
##
## 使い方:
##   sx_arr_is_rw 配列名 [[開始インデックス [個数]] ...]
##
## 説明:
##   指定された名前に対応する配列要素範囲および長さ保持変数 (${配列名}_len) が
##   書き込み可能か確認する。
##   実体が sx 配列でない場合でも確認自体は可能で、その場合は指定された範囲の変数名と
##   ${配列名}_len の書き込み可否を検査する。
##   引数なしの場合: 配列名と ${配列名}_len に加え、sx 配列であれば 0 から末尾までの全要素を確認する。
##   個数が省略された場合: sx 配列であれば開始インデックスから末尾までを確認し、
##   sx 配列でなければその開始インデックス単体を確認する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_arr_is_rw() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_rw "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return "${SX_EX_USAGE}"

	__sx_arr_is_rw_name="${1}"
	shift

	sx_num_is_sx_nat0 "${@}" || {
		unset __sx_arr_is_rw_name
		return "${SX_EX_USAGE}"
	}

	set -- "${__sx_arr_is_rw_name}" "${@}"
	unset __sx_arr_is_rw_name

	__sx_arr_is_rw "${@}" || return
}

### __sx_arr_is_rw - 配列の指定範囲が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_rw 配列名 [開始インデックス [個数]]
##
## 説明:
##   sx_arr_is_rw の内部実装。
##   引数チェックは行わない。
__sx_arr_is_rw() {
	__sx_var_is_rw "${1}" "${1}_len" || return 1
	__sx_arr_is_rw_name_="${1}"
	__sx_arr_is_rw_chk_=
	shift

	M_STR_NE([|"${#}"|], [|0|]) || set -- 0

	if M_STR_EQ([|"$((${#} % 2))"|], [|0|]); then
		:
	elif sx_var_is_arr "${__sx_arr_is_rw_name_}"; then
		# 個数が省略された場合は末尾まで
		eval set -- '"${@}"' "\$((${__sx_arr_is_rw_name_}_len - \${${#}}))"
	else
		set -- "${@}" 0
	fi

	while M_STR_NE([|"${#}"|], [|0|]); do
		eval 'shift 2;' set -- "${1}" "$((${1} + ${2}))" '"${@}"'

		while M_NUM_LT([|${1}|], [|${2}|]); do
			__sx_arr_is_rw_chk_="${__sx_arr_is_rw_chk_}${__sx_arr_is_rw_name_}_${1} "
			eval 'shift 2;' set -- "$((${1} + 1))" "${2}" '"${@}"'
		done

		shift 2
	done

	eval set -- "${__sx_arr_is_rw_chk_}"
	unset __sx_arr_is_rw_name_ __sx_arr_is_rw_chk_

	sx_var_is_rw_all "${@}" || return
}

### sx_arr_pop - 配列の末尾から要素を取り出す
##
## 使い方:
##   sx_arr_pop 配列名 [結果変数名 | ポップ数 ...]
##
## 説明:
##   指定された sx 配列の末尾から要素を取り出し、結果変数に格納または破棄する。
##   結果変数名が指定された場合は、その変数に値を格納してポップする。
##   正の整数（ポップ数）が指定された場合は、その個数分だけ連続してポップし、値は破棄する。
##   引数が複数指定された場合は、指定された順に末尾から順次処理を行う。
##   引数が省略された場合は、1 つの要素をポップして破棄する。
##   - が結果変数名として指定された場合も、値を破棄して 1 つポップする。
##   配列名が結果変数名に含まれている場合はエラーを返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  配列が空、または要素数が不足している
##   64  配列名が無効、または結果変数名と重複している (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_pop() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_pop "${@}" || return; return 0;; esac

	sx_var_is_arr "${1-}" || case "${?}" in
		1) return "${SX_EX_DATAERR}";;
		*) return;;
	esac

	__sx_arr_pop_arr="${1}"
	eval "__sx_arr_pop_len=\"\${${1}_len}\""
	shift

	M_STR_NE([|"${#}"|], [|0|]) || set -- -
	SX_CFG_UNSET_SOFT=2 __sx_arg_norm __sx_arr_pop_args - "${@}"
	eval set -- "${__sx_arr_pop_args}"
	unset __sx_arr_pop_args

	# 要素数チェック
	case "$((${#} <= __sx_arr_pop_len))" in 0)
		unset __sx_arr_pop_arr __sx_arr_pop_len
		return 1
	esac

	# 配列の書き込み権限チェック
	sx_arr_is_rw "${__sx_arr_pop_arr}" "$((__sx_arr_pop_len - ${#}))" "${#}" || {
		case "${?}" in
			1) set -- "${SX_EX_NOPERM}";;
			*) set -- "${?}";;
		esac

		unset __sx_arr_pop_arr __sx_arr_pop_len
		return "${1}"
	}

	__sx_arr_pop_chk=
	__sx_arr_pop_i="${__sx_arr_pop_len}"
	for __sx_arr_pop_dest in "${@}"; do
		: $((__sx_arr_pop_i -= 1))

		M_STR_NE([|"${__sx_arr_pop_dest}"|], [|-|]) || continue

		# pop中に配列以下の更新を禁止
		if
			! sx_var_is_name "${__sx_arr_pop_dest}" ||
			M_STR_MATCH([|"${__sx_arr_pop_dest}"|], [|"${__sx_arr_pop_arr}"|], [|"${__sx_arr_pop_arr}"_*|])
		then
			unset __sx_arr_pop_arr __sx_arr_pop_len __sx_arr_pop_chk __sx_arr_pop_i __sx_arr_pop_dest
			return "${SX_EX_USAGE}"
		fi

		__sx_arr_pop_chk="${__sx_arr_pop_chk} ${__sx_arr_pop_arr}_${__sx_arr_pop_i}-${__sx_arr_pop_dest}"
	done

	eval __sx_var_is_copyable "${__sx_arr_pop_chk}" || {
		case "${?}" in
			1) set -- "${SX_EX_NOPERM}";;
			*) set -- "${?}";;
		esac

		unset __sx_arr_pop_arr __sx_arr_pop_len __sx_arr_pop_chk __sx_arr_pop_i __sx_arr_pop_dest
		return "${1}"
	}

	set -- "${__sx_arr_pop_arr}" "${@}"
	unset __sx_arr_pop_arr __sx_arr_pop_len __sx_arr_pop_chk __sx_arr_pop_i __sx_arr_pop_dest
	__sx_arr_pop0 "${@}" || return
}

### __sx_arr_pop - 配列の末尾から要素を取り出す（内部用）
##
## 使い方:
##   __sx_arr_pop 配列名 [結果変数名 | ポップ数 ...]
##
## 説明:
##   指定された配列の末尾から要素を取り出し、結果変数に格納または破棄する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_arr_pop() {
	M_STR_NE([|"${#}"|], [|1|]) || set -- -
	SX_CFG_UNSET_SOFT=2 __sx_arg_norm __sx_arr_pop_args_ - "${@}"
	eval set -- "${__sx_arr_pop_args_}"
	unset __sx_arr_pop_args_

	__sx_arr_pop0 "${@}" || return
}

### __sx_arr_pop0 - 配列の末尾から要素をポップする実処理（内部用）
##
## 使い方:
##   __sx_arr_pop0 配列名 [結果変数名 | - ...]
##
## 説明:
##   配列の要素数チェック、コピー、削除、および長さとリビジョンの更新を行う。
##   引数チェック（配列の存在確認や書き込み権限等）は事前に行われていることを前提とする。
__sx_arr_pop0() {
	__sx_arr_pop0_arr_="${1}"
	eval "__sx_arr_pop0_len_=\"\${${1}_len}\""
	shift

	case "$((${#} <= __sx_arr_pop0_len_))" in 0)
		unset __sx_arr_pop0_arr_ __sx_arr_pop0_len_
		return 1
	esac

	for __sx_arr_pop0_dest_ in "${@}"; do
		: $((__sx_arr_pop0_len_ -= 1))
		__sx_arr_pop0_src_="${__sx_arr_pop0_arr_}_${__sx_arr_pop0_len_}"

		if M_STR_NE([|"${__sx_arr_pop0_dest_}"|], [|-|]); then
			__sx_var_copy "${__sx_arr_pop0_src_}-${__sx_arr_pop0_dest_}"
		fi

		__sx_var_unset "${__sx_arr_pop0_src_}"
	done

	eval "${__sx_arr_pop0_arr_}_len=${__sx_arr_pop0_len_}"
	__sx_var_touch "${__sx_arr_pop0_arr_}"

	unset __sx_arr_pop0_arr_ __sx_arr_pop0_len_ __sx_arr_pop0_dest_ __sx_arr_pop0_src_
}

### sx_arr_push - 配列の末尾に要素を追加する
##
## 使い方:
##   sx_arr_push 配列名 [値 ...]
##
## 説明:
##   指定された sx 配列の末尾に 0 個以上の値を追加する。
##   配列名が有効でも、対象が sx 配列でない場合は SX_EX_DATAERR を返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  配列名が無効 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
sx_arr_push() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_push "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return "${SX_EX_USAGE}"
	__sx_var_is_arr "${1}" || return "${SX_EX_DATAERR}"
	eval sx_arr_is_rw "${1}" "\"\${${1}_len}\"" "$((${#} - 1))" || return "${SX_EX_NOPERM}"

	__sx_arr_push "${@}"
}

### __sx_arr_push - 配列の末尾に要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_push 配列名 [値 ...]
##
## 説明:
##   指定された配列の末尾に一つ以上の値を追加し、長さを更新する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。
__sx_arr_push() {
	eval "__sx_arr_push_i_=\"\${${1}_len}\""

	__sx_arr_push_arr_="${1}"
	shift

	# 値の追加
	for __sx_arr_push_arg_ in "${@}"; do
		eval "${__sx_arr_push_arr_}_${__sx_arr_push_i_}=\"\${__sx_arr_push_arg_}\""
		__sx_arr_push_i_="$((__sx_arr_push_i_ + 1))"
	done

	# 長さを更新
	eval "${__sx_arr_push_arr_}_len=${__sx_arr_push_i_}"
	__sx_var_touch "${__sx_arr_push_arr_}"

	unset __sx_arr_push_i_ __sx_arr_push_arr_ __sx_arr_push_arg_
}

### sx_arr_quote - 配列要素をシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arr_quote 結果変数名 配列名1 [配列名2 ...]
##
## 説明:
##   指定されたすべての配列の要素をそれぞれシングルクォートで囲み（内部のシングルクォートはエスケープ）、
##   スペース区切りで順方向に結合した文字列を作成して結果変数に格納する。
##   作成された文字列は eval 等で安全に位置パラメータに戻すことができる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arr_quote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_quote "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_arr_quote_res="${1}"
	shift

	sx_var_is_arr "${@}" || {
		unset __sx_arr_quote_res
		return "${SX_EX_USAGE}"
	}

	__sx_arr_quote "${__sx_arr_quote_res}" "${@}"
	unset __sx_arr_quote_res
}

### __sx_arr_quote - 配列要素をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_quote 結果変数名 配列名1 [配列名2 ...]
##
## 説明:
##   sx_arr_quote の内部実装。
##   引数チェックは行わない。
__sx_arr_quote() {
	__sx_arr_quote_out_=
	__sx_arr_quote_res_="${1}"
	shift

	for __sx_arr_quote_arr_ in "${@}"; do
		eval set -- 0 "\"\${${__sx_arr_quote_arr_}_len}\""

		while M_NUM_LT([|${1}|], [|${2}|]); do
			eval SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_arr_quote_esc_ "\"\${${__sx_arr_quote_arr_}_${1}}\""
			__sx_arr_quote_out_="${__sx_arr_quote_out_} ${__sx_arr_quote_esc_}"

			set -- "$((${1} + 1))" "${2}"
		done
	done

	__sx_var_set "${__sx_arr_quote_res_}=${__sx_arr_quote_out_# }"

	unset __sx_arr_quote_res_ __sx_arr_quote_out_ __sx_arr_quote_arr_ __sx_arr_quote_esc_
}

### sx_arr_rquote - 配列要素を逆順にシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arr_rquote 結果変数名 配列名1 [配列名2 ...]
##
## 説明:
##   指定されたすべての配列の要素を、完全な逆順（最後の配列の最後の要素が先頭）で
##   それぞれシングルクォートで囲み、スペース区切りで結合した文字列を作成して結果変数に格納する。
##   作成された文字列は eval 等で安全に位置パラメータに戻すことができる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arr_rquote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_rquote "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" || return

	__sx_arr_rquote_res="${1}"
	shift
	sx_var_is_arr "${@}" || {
		unset __sx_arr_rquote_res
		return "${SX_EX_USAGE}"
	}

	set -- "${__sx_arr_rquote_res}" "${@}"
	unset __sx_arr_rquote_res
	__sx_arr_rquote "${@}"
}

### __sx_arr_rquote - 配列要素を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_rquote 結果変数名 配列名1 [配列名2 ...]
##
## 説明:
##   sx_arr_rquote の内部実装。
##   引数チェックは行わない。
__sx_arr_rquote() {
	__sx_arr_rquote_out_=
	__sx_arr_rquote_res_="${1}"
	shift

	for __sx_arr_rquote_arr_ in "${@}"; do
		eval set -- 0 "\"\${${__sx_arr_rquote_arr_}_len}\""

		while M_NUM_LT([|${1}|], [|${2}|]); do
			eval SX_CFG_UNSET_SOFT=2 __sx_arg_quote __sx_arr_rquote_esc_ "\"\${${__sx_arr_rquote_arr_}_${1}}\""
			__sx_arr_rquote_out_=" ${__sx_arr_rquote_esc_}${__sx_arr_rquote_out_}"

			set -- "$((${1} + 1))" "${2}"
		done
	done

	__sx_var_set "${__sx_arr_rquote_res_}=${__sx_arr_rquote_out_# }"

	unset __sx_arr_rquote_res_ __sx_arr_rquote_out_ __sx_arr_rquote_arr_ __sx_arr_rquote_esc_
}
