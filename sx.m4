#!/bin/sh
# shellcheck shell=sh

changequote([|, |])dnl
changecom()dnl

define([|M_STR_NE|], [|case $1 in $2) ! :;; esac|])dnl
define([|M_VAR_SET|], [|ifelse($#, 1, [|ifelse($1, , [|eval|], [|eval "$1="|])|], [|eval "$1="'"$2"'__M_VAR_SET_REST(shift(shift($@)))|])|])dnl
define([|__M_VAR_SET_REST|], [|ifelse(eval($# > 1), 1, [| "$1="'"$2"'ifelse($#, 2, , [|__M_VAR_SET_REST(shift(shift($@)))|])|], [|ifelse($1, , , [| "$1="|])|])|])dnl
define([|M_NUM_INCR|], [|ifelse($#, 1, [|$1=$(($1 + 1))|], [|$1=$(($1 + $2))|])|])dnl
define([|M_NUM_INCRM1|], [|__sx_num_add1_nat0 $1 "${$1}"|])dnl
define([|M_NUM_DECR|], [|ifelse($#, 1, [|$1=$(($1 - 1))|], [|$1=$(($1 - $2))|])|])dnl
define([|M_NUM_DECRM1|], [|__sx_num_sub1_nat0 $1 "${$1}"|])dnl
define([|M_NUM_AMP|], [|ifelse($#, 1, [|$1=$(($1 * 2))|], [|$1=$(($1 * $2))|])|])dnl
define([|M_STR_APPEND|], [|ifelse($#, 2, [|$1="${$1}"$2|], [|$1="${$1}${$1:+$3}"$2|])|])dnl
define([|M_STR_PREPEND|], [|ifelse($#, 2, [|$1=$2"${$1}"|], [|$1=$2"${$1:+$3}${$1}"|])|])dnl
define([|M_STR_WRAP|], [|$1=$2"${$1}"$3|])dnl
define([|M_STR_LTRIM|], [|${$1#"${$1%%$2*}"}|])dnl
define([|M_STR_RTRIM|], [|${$1%"${$1##*$2}"}|])dnl

define([|M_EX_OK|], [|0|])dnl
define([|M_EX_USAGE|], [|64|])dnl
define([|M_EX_DATAERR|], [|65|])dnl
define([|M_EX_NOINPUT|], [|66|])dnl
define([|M_EX_NOUSER|], [|67|])dnl
define([|M_EX_NOHOST|], [|68|])dnl
define([|M_EX_UNAVAILABLE|], [|69|])dnl
define([|M_EX_SOFTWARE|], [|70|])dnl
define([|M_EX_OSERR|], [|71|])dnl
define([|M_EX_OSFILE|], [|72|])dnl
define([|M_EX_CANTCREAT|], [|73|])dnl
define([|M_EX_IOERR|], [|74|])dnl
define([|M_EX_TEMPFAIL|], [|75|])dnl
define([|M_EX_PROTOCOL|], [|76|])dnl
define([|M_EX_NOPERM|], [|77|])dnl
define([|M_EX_CONFIG|], [|78|])dnl

define([|M_STR_EQ|], [|dnl
{ case $1 in $2);; *) ! :;; esac ifelse(eval($# > 2), 1, [|&& __M_STR_EQ_REST(shift($@))|]); }dnl
|])dnl
define([|__M_STR_EQ_REST|], [|dnl
case $1 in $2);; *) ! :;; esac ifelse(eval($# > 2), 1, [| && __M_STR_EQ_REST(shift($@))|])dnl
|])dnl

define([|M_STR_HAS|], [|case $1 in __M_STR_HAS_REST(shift($@)));; *) ! :;; esac|])dnl
define([|__M_STR_HAS_REST|], [|ifelse($#, 0, , $#, 1, [|*$1*|], [|*$1* | __M_STR_HAS_REST(shift($@))|])|])dnl

define([|M_STR_MATCH|], [|case $1 in __M_STR_MATCH_REST(shift($@)));; *) ! :;; esac|])dnl
define([|__M_STR_MATCH_REST|], [|ifelse($#, 0, , $#, 1, [|$1|], [|$1 | __M_STR_MATCH_REST(shift($@))|])|])dnl

define([|__M_NUM_CMP_CHAIN|], [|dnl
$2 $1 $3 ifelse(eval(3 < $#), 1, [| && __M_NUM_CMP_CHAIN($1, shift(shift($@))) |])dnl
|])dnl
define([|M_NUM_EQ|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(==, $@)))|], 0)|])dnl
define([|M_NUM_GE|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(>=, $@)))|], 0)|])dnl
define([|M_NUM_GT|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(>, $@)))|], 0)|])dnl
define([|M_NUM_LE|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(<=, $@)))|], 0)|])dnl
define([|M_NUM_LT|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(<, $@)))|], 0)|])dnl
define([|M_NUM_NE|], [|M_STR_NE([|$((__M_NUM_CMP_CHAIN(!=, $@)))|], 0)|])dnl
define([|M_NUM_BOOL|], [|M_STR_NE([|$(($1))|], 0)|])dnl
define([|M_RENAME_Q|], [|patsubst([|$1|], [|\([^_A-Za-z]\)Q_\([_A-Za-z][_0-9A-Za-z]*\)|], [|\1__sx_$2_\2|])|])dnl
define([|M_RENAME_QI|], [|patsubst([|$1|], [|\([^_A-Za-z]\)Q_\([_A-Za-z][_0-9A-Za-z]*\)|], [|\1__sx_$2_\2_|])|])dnl

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

readonly SX_EX_STS0=OK
readonly SX_EX_STS64=USAGE
readonly SX_EX_STS65=DATAERR
readonly SX_EX_STS66=NOINPUT
readonly SX_EX_STS67=NOUSER
readonly SX_EX_STS68=NOHOST
readonly SX_EX_STS69=UNAVAILABLE
readonly SX_EX_STS70=SOFTWARE
readonly SX_EX_STS71=OSERR
readonly SX_EX_STS72=OSFILE
readonly SX_EX_STS73=CANTCREAT
readonly SX_EX_STS74=IOERR
readonly SX_EX_STS75=TEMPFAIL
readonly SX_EX_STS76=PROTOCOL
readonly SX_EX_STS77=NOPERM
readonly SX_EX_STS78=CONFIG

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
readonly SX_STR_SWORD="_${SX_STR_ALPHA}"
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
readonly SX_NUM_I8_WLEN=1
readonly SX_NUM_I8_QM='?'
readonly SX_NUM_I8_ZR='0'
readonly SX_NUM_U8_MAX=255
readonly SX_NUM_U8_WLEN=2
readonly SX_NUM_U8_QM='??'
readonly SX_NUM_U8_ZR='00'
readonly SX_NUM_I16_MAX=32767
readonly SX_NUM_I16_MIN=-32768
readonly SX_NUM_I16_WLEN=4
readonly SX_NUM_I16_QM='????'
readonly SX_NUM_I16_ZR='0000'
readonly SX_NUM_U16_MAX=65535
readonly SX_NUM_U16_WLEN=4
readonly SX_NUM_U16_QM='????'
readonly SX_NUM_U16_ZR='0000'
readonly SX_NUM_I32_MAX=2147483647
readonly SX_NUM_I32_MIN=-2147483648
readonly SX_NUM_I32_WLEN=9
readonly SX_NUM_I32_QM='?????????'
readonly SX_NUM_I32_ZR='000000000'
readonly SX_NUM_U32_MAX=4294967295
readonly SX_NUM_U32_WLEN=9
readonly SX_NUM_U32_QM='?????????'
readonly SX_NUM_U32_ZR='000000000'
readonly SX_NUM_I64_MAX=9223372036854775807
readonly SX_NUM_I64_MIN=-9223372036854775808
readonly SX_NUM_I64_WLEN=18
readonly SX_NUM_I64_QM='??????????????????'
readonly SX_NUM_I64_ZR='000000000000000000'
readonly SX_NUM_U64_MAX=18446744073709551615
readonly SX_NUM_U64_WLEN=18
readonly SX_NUM_U64_QM='??????????????????'
readonly SX_NUM_U64_ZR='000000000000000000'
readonly SX_NUM_I128_MAX=170141183460469231731687303715884105727
readonly SX_NUM_I128_MIN=-170141183460469231731687303715884105728
readonly SX_NUM_I128_WLEN=37
readonly SX_NUM_I128_QM='?????????????????????????????????????'
readonly SX_NUM_I128_ZR='0000000000000000000000000000000000000'
readonly SX_NUM_U128_MAX=340282366920938463463374607431768211455
readonly SX_NUM_U128_WLEN=38
readonly SX_NUM_U128_QM='??????????????????????????????????????'
readonly SX_NUM_U128_ZR='00000000000000000000000000000000000000'

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
define([|__sx_m4_gen_qm|], [|readonly SX_NUM_QM_$1='$2'
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_qm(incr($1), $2?)|])|])dnl
__sx_m4_gen_qm(1, ?)

define([|__sx_m4_gen_zr|], [|readonly SX_NUM_ZR_$1='$2'
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_zr(incr($1), $2[|0|])|])|])dnl
__sx_m4_gen_zr(1, 0)

# __sx_str_qm / __sx_str_zr 用の 37 分岐 case を生成する（定数生成と同一の 37 境界）
define([|__sx_m4_gen_qm_case|], [|	$1) __sx_str_qm_out_="${SX_NUM_QM_$1}";;
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_qm_case(incr($1))|])|])dnl
define([|__sx_m4_gen_zr_case|], [|	$1) __sx_str_zr_out_="${SX_NUM_ZR_$1}";;
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_zr_case(incr($1))|])|])dnl

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
readonly SX_CFG_DEF_ARR_UPDATE=1
readonly SX_CFG_DEF_ARR_HOLE=
readonly SX_CFG_DEF_ARR_REF=

: "${SX_CFG_SIG_BASE:=${SX_CFG_DEF_SIG_BASE}}"
: "${SX_CFG_SIG_ARR:=${SX_CFG_DEF_SIG_ARR}}"
: "${SX_CFG_SKIP_CHK:=${SX_CFG_DEF_SKIP_CHK}}"
: "${SX_CFG_NUM_RANGE:=${SX_CFG_DEF_NUM_RANGE}}"
: "${SX_CFG_SEP:=${SX_CFG_DEF_SEP}}"
: "${SX_CFG_ARR_UPDATE:=${SX_CFG_DEF_ARR_UPDATE}}"
: "${SX_CFG_ARR_HOLE:=${SX_CFG_DEF_ARR_HOLE}}"
: "${SX_CFG_ARR_REF:=${SX_CFG_DEF_ARR_REF}}"

SX_SYS_REV=0
eval SX_SYS_NUM_WLEN="\${SX_NUM_I${SX_CFG_NUM_RANGE}_WLEN}" SX_SYS_NUM_QM="\${SX_NUM_I${SX_CFG_NUM_RANGE}_QM}" SX_SYS_NUM_ZR="\${SX_NUM_I${SX_CFG_NUM_RANGE}_ZR}" SX_SYS_NUM_MAX="\${SX_NUM_I${SX_CFG_NUM_RANGE}_MAX}" SX_SYS_NUM_MIN="\${SX_NUM_I${SX_CFG_NUM_RANGE}_MIN}"


# ========================================
#  CFG (Configuration)
# ========================================

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
##
## 終了ステータス:
##    0  すべて妥当 (SX_EX_OK)
##    1  無効な設定項目、または不適切な値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_cfg_is_valid() {
	case "${#}" in 0)
		set -- \
			NUM_RANGE="${SX_CFG_NUM_RANGE-}" \
			SKIP_CHK="${SX_CFG_SKIP_CHK-}" \
			SIG_BASE="${SX_CFG_SIG_BASE-}" \
			SIG_ARR="${SX_CFG_SIG_ARR-}" \
			SEP="${SX_CFG_SEP-}" \
			ARR_UPDATE="${SX_CFG_ARR_UPDATE-}" \
			ARR_HOLE="${SX_CFG_ARR_HOLE-}" \
			ARR_REF="${SX_CFG_ARR_REF-}"
	esac

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			NUM_RANGE | SKIP_CHK | SIG_BASE | SIG_ARR | SEP | ARR_UPDATE | ARR_HOLE | ARR_REF) ;;
			NUM_RANGE=32 | NUM_RANGE=64 | NUM_RANGE=128) ;;
			SKIP_CHK=[01] | SIG_BASE=?* | SIG_ARR=?* | SEP=?* | ARR_UPDATE=[01] | ARR_HOLE=* | ARR_REF=*) ;;
			*)
				unset CLEANUP
				return 1
				;;
		esac
	done

	unset CLEANUP
}
|], [|cfg_is_valid|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg Q_chk|])dnl

sx_cfg_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_cfg_set "${@}" || return; return 0;; esac

	case "${#}" in 0) return M_EX_OK; esac

	sx_cfg_is_valid "${@}" || return M_EX_USAGE

	Q_chk=

	for Q_arg in "${@}"; do
		M_STR_APPEND([|Q_chk|], [|" SX_CFG_${Q_arg%%=*}"|])
	done

	eval sx_var_is_rw "${Q_chk}" || {
		unset CLEANUP
		return M_EX_NOPERM
	}

	unset CLEANUP
	__sx_cfg_set "${@}"
}
|], [|cfg_set|])dnl

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

__sx_cfg_set() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) eval "SX_CFG_${Q_arg%%=*}=\"\${Q_arg#*=}\"";;
			*) eval "SX_CFG_${Q_arg}=\"\${SX_CFG_DEF_${Q_arg}}\"";;
		esac

		case "${Q_arg}" in SIG_BASE | SIG_BASE=*)
			SX_CFG_SIG_ARR="array-${SX_CFG_SIG_BASE}"
		esac

		case "${Q_arg}" in NUM_RANGE | NUM_RANGE=*)
			eval SX_SYS_NUM_WLEN="\${SX_NUM_I${SX_CFG_NUM_RANGE}_WLEN}" SX_SYS_NUM_QM="\${SX_NUM_I${SX_CFG_NUM_RANGE}_QM}" SX_SYS_NUM_ZR="\${SX_NUM_I${SX_CFG_NUM_RANGE}_ZR}" SX_SYS_NUM_MAX="\${SX_NUM_I${SX_CFG_NUM_RANGE}_MAX}" SX_SYS_NUM_MIN="\${SX_NUM_I${SX_CFG_NUM_RANGE}_MIN}"
		esac
	done

	unset CLEANUP
}
|], [|cfg_set|])dnl

# ========================================
#  EX (Exit Status)
# ========================================

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_ex_is_err() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			[1-9] | [1-9][0-9] | 1[0-9][0-9] | 2[0-4][0-9] | 25[0-5]) continue;;
		esac

		unset CLEANUP
		return 1
	done

	unset CLEANUP
}
|], [|ex_is_err|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_ex_is_status() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			[0-9] | [1-9][0-9] | 1[0-9][0-9] | 2[0-4][0-9] | 25[0-5]) continue;;
		esac

		unset CLEANUP
		return 1
	done

	unset CLEANUP
}
|], [|ex_is_status|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_ex_is_valid() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			[0-9] | [1-9][0-9] | 1[0-9][0-9] | 2[0-4][0-9] | 25[0-5] | OK | USAGE | DATAERR | NOINPUT | NOUSER | NOHOST | UNAVAILABLE | SOFTWARE | OSERR | OSFILE | CANTCREAT | IOERR | TEMPFAIL | PROTOCOL | NOPERM | CONFIG) continue;;
		esac

		unset CLEANUP
		return 1
	done

	unset CLEANUP
}
|], [|ex_is_valid|])dnl

M_RENAME_Q([|dnl
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
##   - 64 (SX_EX_USAGE): バインド形式が無効、無効なステータス、または対応するマッピングが存在しない。
##   - 77 (SX_EX_NOPERM): 書き込み禁止の変数に代入しようとした。
##   - 78 (SX_EX_CONFIG): SX_CFG_NUM_RANGE の値が不正。

define([|CLEANUP|], [|Q_bind Q_arg|])dnl

sx_ex_map() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_ex_map "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0 | 6[4-9] | 7[0-8] | OK | USAGE | DATAERR | NOINPUT | NOUSER | NOHOST | UNAVAILABLE | SOFTWARE | OSERR | OSFILE | CANTCREAT | IOERR | TEMPFAIL | PROTOCOL | NOPERM | CONFIG) ;;
			*)
				unset CLEANUP
				return M_EX_USAGE
				;;
		esac
	done

	__sx_ex_map "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|ex_map|])dnl

M_RENAME_QI([|dnl
### __sx_ex_map - 終了ステータスの数値と名前を相互変換、または有効性を確認する（内部用）
##
## 使い方:
##   __sx_ex_map バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_ex_map の内部実装。
##   引数チェックを行わずに変換処理を行う。

define([|CLEANUP|], [|Q_bind Q_arg|])dnl

__sx_ex_map() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			[0-9]*) eval __sx_var_ubind Q_bind '"${Q_bind}"' "\"\${SX_EX_STS${Q_arg}}\"";;
			*) eval __sx_var_ubind Q_bind '"${Q_bind}"' "\"\${SX_EX_${Q_arg}}\"";;
		esac || break
	done

	unset CLEANUP
}
|], [|ex_map|])dnl

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

	eval "unset CLEANUP; \"\${@:-:}\" && Q_sts=0 || Q_sts=\"\${?}\"; set -- ${Q_map}"

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
			!*)
				case "${1}" in ![!0-9]*)
					__sx_ex_map Q_tmp "${1#!}"
					set -- "!${Q_tmp}" "${2}"
				esac

				if M_STR_NE([|"${1#!}"|], [|"${Q_sts}"|]); then
					Q_sts="${2}"; break
				fi
				;;
			[!0-9]*)
				__sx_ex_map Q_tmp "${1}"

				case "${Q_tmp}" in "${Q_sts}")
					Q_sts="${2}"; break
				esac
				;;
		esac
	done

	case "${Q_sts}" in [!0-9]*)
		__sx_ex_map Q_sts "${Q_sts}"
	esac

	set -- "${Q_sts-0}"
	unset CLEANUP
	return "${1}"
}
|], [|ex_remap|])dnl

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

	sx_ex_is_valid "${1-0}" || return M_EX_USAGE

	__sx_ex_yield "${@}" || return
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_s|])dnl

__sx_ex_yield() {
	case "${1-0}" in [!0-9]*)
		__sx_ex_map Q_s "${1}"
		set -- "${Q_s}"
		unset CLEANUP
	esac

	return "${1-0}"
}
|], [|ex_yield|])dnl

# ========================================
#  FN (Function)
# ========================================

M_RENAME_Q([|dnl
### sx_fn_is_valid - 関数定義の妥当性（名前および構文）を確認する
##
## 使い方:
##   sx_fn_is_valid 名前=本体 [名前=本体 ...]
##
## 終了ステータス:
##    0  すべて妥当
##    1  無効な名前、または構文エラーが含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_fn_is_valid() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *=*)
			sx_var_is_name "${Q_arg%%=*}" && continue
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
|], [|fn_is_valid|])dnl

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

	sx_fn_is_valid "${@}" || return M_EX_USAGE

	__sx_fn_set "${@}"
}

M_RENAME_QI([|dnl
### __sx_fn_set - 関数を実際に定義する（内部用）
##
## 使い方:
##   __sx_fn_set 名前=本体 [名前=本体 ...]

define([|CLEANUP|], [|Q_arg Q_body|])dnl

__sx_fn_set() {
	for Q_arg in "${@}"; do
		Q_body="${Q_arg#*=}"
		eval "${Q_arg%%=*}() { ${Q_body:-:}${SX_STR_LF}}"
	done

	unset CLEANUP
}
|], [|fn_set|])dnl

M_RENAME_Q([|dnl
### sx_fn_with - 一時的な匿名関数を定義してコマンドを実行する
##
## 使い方:
##   sx_fn_with [エイリアス=本体 ...] [${SX_CFG_SEP}] コマンド [引数 ...]
##
## 説明:
##   指定されたエイリアス名で一時的な関数を定義し、コマンドを実行する。
##   コマンドの引数の中にエイリアス名と一致するものがあれば、生成された一意な名前に置換される。
##   コマンドの実行終了後、定義された関数は自動的に削除される。

define([|CLEANUP|], [|Q_i Q_arg Q_fn|])dnl

sx_fn_with() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_with "${@}" || return; return;; esac

	Q_i=0
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${SX_CFG_SEP-}") break;;
			*=*) ;;
			*) break;;
		esac

		M_NUM_INCR([|Q_i|])
	done

	case "${Q_i}" in [!0]*)
		__sx_arg_quote "${Q_i}Q_fn:" "${@}"

		eval sx_fn_is_valid "${Q_fn}" || {
			unset CLEANUP
			return M_EX_USAGE
		}
	esac

	unset CLEANUP

	__sx_fn_with "${@}" || return
}
|], [|fn_with|])dnl

M_RENAME_QI([|dnl
### __sx_fn_with - 一時的な匿名関数を定義してコマンドを実行する（内部用）

define([|CLEANUP|], [|Q_fns Q_map Q_arg Q_anon Q_tmp|])dnl

__sx_fn_with() {
	Q_fns=
	Q_map=' '

	# 1. エイリアスの解析と関数定義
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${SX_CFG_SEP-}") shift; break;;
			*=*)
				__sx_fn_anon Q_anon "${Q_arg#*=}"
				M_STR_APPEND([|Q_fns|], [|"${Q_anon} "|])
				M_STR_APPEND([|Q_map|], [|"${Q_arg%%=*}:${Q_anon} "|])
				shift
				;;
			*) break;;
		esac
	done

	# 2. コマンド引数の置換とクォート処理
	for Q_arg in "${@}"; do
		case "${Q_map}" in *" ${Q_arg}:"*)
			Q_tmp="${Q_map#*" ${Q_arg}:"}"
			Q_arg="${Q_tmp%% *}"
		esac

		shift
		set -- "${@}" "${Q_arg}"
	done

	# 3. 実行と状態の保持 (set -e 対策)
	eval "unset CLEANUP; \"\${@:-:}\" && set -- '${Q_fns}' 0 || set -- '${Q_fns}' \"\${?}\""

	# 4. 後始末
	case "${1}" in ?*)
		eval "unset -f ${1}"
	esac

	return "${2}"
}
|], [|fn_with|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_bind Q_arg|])dnl

sx_fn_anon() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_fn_anon "${@}" || return; return;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		shift
		set -- "${@}" "sx_fn_anon_0=${Q_arg}"
	done

	sx_fn_is_valid "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	for Q_arg in "${@}"; do
		shift
		set -- "${@}" "${Q_arg#sx_fn_anon_0=}"
	done

	__sx_fn_anon "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|fn_anon|])dnl

M_RENAME_QI([|dnl
### __sx_fn_anon - 匿名関数を実際に生成・定義する（内部用）
##
## 使い方:
##   __sx_fn_anon 結果変数名（またはバインド形式） 本体 [本体 ...]
##
##   一意な関数名 (sx_fn_anon_${SX_SYS_REV}) を生成して定義し、
##   結果変数に格納する。

define([|CLEANUP|], [|Q_bind Q_arg Q_name|])dnl

__sx_fn_anon() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	for Q_arg in "${@}"; do
		Q_name="sx_fn_anon_${SX_SYS_REV}"

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_name}" || break

		__sx_fn_set "${Q_name}=${Q_arg}"

		M_NUM_INCRM1([|SX_SYS_REV|])
	done

	unset CLEANUP
}
|], [|fn_anon|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_count() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_count "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_num_is_nat0_safe "${3}" || return M_EX_USAGE

			case "$(((${3} & SX_ARG_COUNT_GLOB) * (${3} & SX_ARG_COUNT_CB)))" in [!0])
				return M_EX_USAGE
			esac
			;;
	esac

	__sx_arg_count "${@}"
}

M_RENAME_QI([|dnl
### __sx_arg_count - 引数リストから指定された値の出現回数を取得する（内部用）
##
## 使い方:
##   __sx_arg_count 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   sx_arg_count の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_tmp|])dnl

__sx_arg_count() {
	Q_res="${1}"
	shift

	__sx_arg_find Q_tmp "${@}" || :

	eval __sx_arg_len "${Q_res}" "${Q_tmp}"

	unset CLEANUP
}
|], [|arg_count|])dnl

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
##   64 => 引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   78 => SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_each() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_each "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	__sx_arg_each "${@}" || return
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

__sx_arg_each() {
	# $1: cnt, $2: cb, $@: data
	set -- -2 "${@}"

	for Q_arg in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${Q_arg}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset CLEANUP

		"${2}" "${3}" "${1}" || return
	done

	unset CLEANUP
}
|], [|arg_each|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_enough() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_enough "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}") ;;
		"${3+X${3}}") __sx_num_is_nat0_safe "${2}" || return M_EX_USAGE;;
	esac

	__sx_arg_enough "${@}" || return
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

__sx_arg_enough() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			Q_cb="${1}"
			shift 2
			;;
		"${3+X${3}}")
			Q_cb="${1}" Q_need="${2}"
			shift 3
			;;
		*)
			Q_cb="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	# $1=idx(-4), $2=total, $3=cb, $4=need(count-found)
	set -- -4 "${#}" "${Q_cb-}" "$((${Q_need:-${#}}))" "${@}"
	unset Q_cb Q_need

	case "${4}" in 0)
		return M_EX_OK
	esac

	for Q_arg in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${Q_arg}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset CLEANUP

		# 短絡評価: 残りの全要素が成功しても必要数に達しない
		case "$((${2} - ${1} + 1 < ${4}))" in 1)
			return 1
		esac

		"${3}" "${5}" "${1}" && set -- "${1}" "${2}" "${3}" "$((${4} - 1))" || :

		# 短絡評価: 必要数に達した
		case "${4}" in 0)
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|arg_enough|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_find() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_find "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*)
			__sx_var_is_bind ${1+"${1}"} || return M_EX_USAGE

			__sx_var_is_bindable ${1+"${1}"} || return M_EX_NOPERM
			;;
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_num_is_nat0_safe "${3}" || return M_EX_USAGE

			case "$(((${3} & SX_ARG_FIND_GLOB) * (${3} & SX_ARG_FIND_CB)))" in [!0])
				return M_EX_USAGE
			esac
			;;
	esac

	__sx_arg_find "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_arg_find - 引数リストから指定された値を探す（内部用: ディスパッチャ）
##
## 使い方:
##   __sx_arg_find 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   ::: セパレータをパースし、フラグに応じて __sx_arg_find_lit または
##   __sx_arg_find_cb にディスパッチする。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_tgt Q_flg|])dnl

__sx_arg_find() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			Q_bind="${1}"
			shift 2;;
		"${3+X${3}}")
			Q_bind="${1}" Q_tgt="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_bind="${1}" Q_tgt="${2}" Q_flg="${3}"
			shift 4
			;;
		*)
			Q_bind="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

		set -- "${Q_bind-}" "${Q_tgt-}" "${Q_flg:-0}" "${@}"
	unset CLEANUP

	__sx_var_bind_init "${1}"

	case "$((${3} & SX_ARG_FIND_CB))" in
		0) __sx_arg_find_lit "${@}";;
		*) __sx_arg_find_cb "${@}";;
	esac || return
}
|], [|arg_find|])dnl

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_arg Q_bind|])dnl

__sx_arg_find_cb() {
	set -- -6 0 "$(((${3} & SX_ARG_FIND_TEXT) != 0))" "${@}"

	for Q_arg in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${5}" "${Q_arg}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset CLEANUP

		case "${4}" in '')
			break
		esac

		# $1=i, $2=match_cnt, $3=txt_flg, $4=bind, $5=cb, $6=value
		"${5}" "${6}" "${1}" "${2}" && {
			case "${3}" in
				0) __sx_var_ubind Q_bind "${4}" "${1}";;
				*) __sx_var_bind Q_bind "${4}" "${6}";;
			esac

			set -- "${1}" "$((${2} + 1))" "${3}" "${Q_bind}" "${5}"
		}
	done

	unset CLEANUP

	return "$((!${2}))"
}
|], [|arg_find_cb|])dnl

M_RENAME_QI([|dnl
### __sx_arg_find_lit - 引数リストから指定された値を探す（内部用: リテラル/glob照合）
##
## 使い方:
##   __sx_arg_find_lit 結果変数名 検索対象 フラグ [値 ...]
##
## 説明:
##   __sx_arg_find から呼ばれる。先頭から末尾に向かって検索する。
##   引数は正規化済み。引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_tgt Q_glob Q_text Q_i Q_arg Q_sts|])dnl

__sx_arg_find_lit() {
	Q_bind="${1}"
	Q_tgt="${2}"
	Q_glob=$(((${3} & SX_ARG_FIND_GLOB) != 0))
	Q_text=$(((${3} & SX_ARG_FIND_TEXT) != 0))
	Q_i=1

	shift 3

	for Q_arg in "${@}"; do
		case "${Q_bind}" in '')
			break
		esac

		case "${Q_glob}${Q_arg}" in "0${Q_tgt}" | 1${Q_tgt})
			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_i}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${Q_arg}";;
			esac

			Q_sts=M_EX_OK
		esac

		M_NUM_INCR([|Q_i|])
	done

	set -- "${Q_sts-1}"

	unset CLEANUP
	return "${1}"
}
|], [|arg_find_lit|])dnl

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
##   64 => 引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78 => SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_fold() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_fold "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_arg_fold "${@}" || return
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

__sx_arg_fold() {
	# $1: count, $2: res, $3: cb, $4: acc, $@: data
	set -- -4 "${@}"

	for Q_arg in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${Q_arg}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		unset CLEANUP

		"${3}" Q_ret "${4}" "${5}" "${1}" || {
			set -- "${@}" "${?}"
			M_VAR_SET([|${2}|], [|${4}|])
			unset Q_ret
			return "${6}"
		}

		set -- "${1}" "${2}" "${3}" "${Q_ret-${4}}"
		unset Q_ret
	done

	M_VAR_SET([|${2}|], [|${4}|])
	unset CLEANUP
}
|], [|arg_fold|])dnl

M_RENAME_Q([|dnl
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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_int Q_lim Q_flg|])dnl

sx_arg_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_isep "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*)
			__sx_var_is_bind "${1-}" || return M_EX_USAGE

			__sx_var_is_bindable "${1-}" || return M_EX_NOPERM
			;;
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}") Q_int="${3}";;
		"${5+X${5}}") Q_int="${3}" Q_lim="${4}";;
		"${6+X${6}}") Q_int="${3}" Q_lim="${4}" Q_flg="${5}";;
	esac

	__sx_num_is_int_safe_inv ${Q_int:+"${Q_int}"} && __sx_num_is_nat0_safe ${Q_lim:+"${Q_lim}"} ${Q_flg:+"${Q_flg}"} || {
		unset CLEANUP
		return M_EX_USAGE
	}

	case ${Q_int:+"${Q_int#[+-]}"} in 0)
		unset CLEANUP
		return M_EX_USAGE
	esac

	unset CLEANUP

	__sx_arg_isep "${@}" || return
}
|], [|arg_isep|])dnl

M_RENAME_QI([|dnl
### __sx_arg_isep - 引数間にセパレータを挿入する（ディスパッチャ、内部用）
##
## 使い方:
##   __sx_arg_isep [bind [sep [inv [limit [flg]]]]] ::: [arg ...]
##   __sx_arg_isep [bind] [arg ...]
##
## 説明:
##   ::: のパースと、lit/cb の振り分けを行う。

define([|CLEANUP|], [|Q_bind Q_sep Q_int Q_lim Q_flg|])dnl

__sx_arg_isep() {
	# ::: の位置を特定 (Bounded Search: $2, $3, $4, $5, $6)
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			Q_bind="${1}"
			shift 2;;
		"${3+X${3}}")
			Q_bind="${1}" Q_sep="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_bind="${1}" Q_sep="${2}" Q_int="${3}"
			shift 4
			;;
		"${5+X${5}}")
			Q_bind="${1}" Q_sep="${2}" Q_int="${3}" Q_lim="${4}"
			shift 5
			;;
		"${6+X${6}}")
			Q_bind="${1}" Q_sep="${2}" Q_int="${3}" Q_lim="${4}" Q_flg="${5}"
			shift 6
			;;
		*)
			Q_bind="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	set -- "${Q_bind-}" "${Q_sep-}" "${Q_int:-1}" "${Q_lim:-${SX_NUM_I32_MAX}}" "$((${Q_flg:-0} & (${#} != 0 ? ~0 : (${Q_int:-1} > 0 ? ~SX_ARG_ISEP_POST : ~SX_ARG_ISEP_PRE))))" "${@}"
	unset CLEANUP

	__sx_var_bind_init "${1}"

	case "$((${5} & SX_ARG_ISEP_CB))" in
		0) __sx_arg_isep_lit "${@}";;
		*) __sx_arg_isep_cb "${@}";;
	esac || return
}
|], [|arg_isep|])dnl

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_bind Q_int Q_flg Q_cnt Q_stat Q_post Q_r Q_i Q_arg Q_ret|])dnl

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
			if "${6}" Q_ret 0 "$((${1} + 1))" "${2}"; then
				case "${Q_ret+X}" in X)
					__sx_var_bind Q_bind "${5}" "${Q_ret}"
					eval 'shift 5;' set -- "$((${1} + 1))" "${2}" 0 "${4}" "${Q_bind}" '"${@}"';;
				*)
					eval 'shift 2;' set -- "$((${1} + 1))" "$((${2} + 1))" '"${@}"';;
				esac
			else
				eval 'shift 3;' set -- "${8}" "${2}" "${?}" '"${@}"'
			fi

			unset Q_ret Q_bind Q_cb
		esac

		# === メインループ ===
		for Q_arg in "${@}"; do
			set -- "${1}" "${2}" "${3}" "$((${4} + 1))" "${5}" "${6}" "${7}" "${8}" "${9}" "${Q_arg}"

			case "$((${4} < 0))" in 1)
				continue
			esac

			unset Q_arg

			case "${5}" in '')
				return "${3}"
			esac

			# 内部セパレータ挿入判定（前向き）
			case "$((${1} < ${8} && 0 < ${4} && ${4} % ${7} == 0))" in 1)
				if "${6}" Q_ret "${4}" "$((${1} + 1))" "${2}"; then
					case "${Q_ret+X}" in X)
						__sx_var_bind Q_bind "${5}" "${Q_ret}"

						set -- "$((${1} + 1))" "${2}" 0 "${4}" "${Q_bind}" "${6}" "${7}" "${8}" "${9}" "${10}";;
					*)
						set -- "$((${1} + 1))" "$((${2} + 1))" 0 "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}";;
					esac
				else
					set -- "${8}" "${2}" "${?}" "${4}" "${5}" '' "${7}" "${8}" "${9}" "${10}"
				fi
			esac

			__sx_var_bind Q_bind "${5}" "${10}" || :
			set -- "${1}" "${2}" "${3}" "${4}" "${Q_bind}" "${6}" "${7}" "${8}" "${9}"
			unset Q_ret Q_bind
		done

		case "${5}" in '')
			unset Q_arg
			return "${3}"
		esac

		# === POST セパレータ ===
		case "$((${1} < ${8} && ${9} & SX_ARG_ISEP_POST && (${4} + 1) % ${7} == 0))" in 1)
			if "${6}" Q_ret "$((${4} + 1))" "$((${1} + 1))" "${2}"; then
				case "${Q_ret+X}" in X)
					__sx_var_bind Q_bind "${5}" "${Q_ret}" || :
				esac
			else
				set -- "${1}" "${2}" "${?}"
			fi
		esac

		unset Q_ret Q_arg Q_bind
		return "${3}"
	else
		# === 負のインターバル: countベースCB呼出 + 左→右bind ===
		Q_bind="${1}"
		Q_cb="${2}"
		Q_int="${3}"
		Q_lim="${4}"
		Q_flg="${5}"
		shift 5

		# max = eff（accumulator、max < lim なら lim を cap）
		Q_max=$(((0 < ${#}) * (${#} - 1) / ${Q_int#-}))

		# POST加算
		case "$((Q_flg & SX_ARG_ISEP_POST))" in [!0]*)
			M_NUM_INCR([|Q_max|])
		esac

		# PRE加算（eff < lim - post は max < lim に簡約）
		case "$((Q_flg & SX_ARG_ISEP_PRE && (${#} % ${Q_int#-}) == 0))" in 1)
			M_NUM_INCR([|Q_max|])
		esac

		# lim capping
		Q_lim=$((Q_max < Q_lim ? Q_max : Q_lim))

		# ===== Phase 1: countベースCB呼出 + 結果prepend（save/restore対応） =====
			# SAVE state (8 vars) — 再帰呼び出しでCLEANUPにより変数が消える対策
		set -- 0 0 "${Q_bind}" "${Q_cb}" "${Q_int}" "${Q_lim}" "${Q_flg}" "${#}" "${@}"
		unset Q_bind Q_cb Q_int Q_lim Q_flg Q_max

		while M_NUM_BOOL([|${1} < ${6}|]); do
			if "${4}" Q_ret "$(((${7} & SX_ARG_ISEP_POST) && ${1} == 0 ? ${8} : ${8} - (${1} + 1 - ((${7} & SX_ARG_ISEP_POST) != 0)) * ${5#-}))" "$((${1} + 1))" "${2}"; then
				case "${Q_ret+X}" in
					X)
						Q_cb="${4}"
						eval 'shift 8;' set -- "$((${1} + 1))" "${2}" "${3}" '"${Q_cb}"' "${5}" "${6}" "${7}" "${8}" '"${Q_ret+:}${Q_ret-}"' '"${@}"'
						;;
				*) eval 'shift 2;' set -- "$((${1} + 1))" "$((${2} + 1))" '"${@}"';;
				esac
			else
				Q_stat="${?}"
				break
			fi

			unset Q_ret Q_cb
		done

		Q_cnt="${1}"
		Q_bind="${3}"
		Q_int="${5}"
		Q_flg="${7}"
		: "${Q_stat=0}"
		shift 8

		# ===== Phase 2: 左→右bind (for ループ) =====
		# $@ = sep_N ... sep_1 data_1 ... data_M
		# cnt_ 個の sep が先頭に積まれている
		Q_post=$((Q_flg & SX_ARG_ISEP_POST && 0 < Q_cnt))
		Q_r=$(((${#} - Q_cnt) - (Q_cnt - Q_post) * ${Q_int#-}))

		# $@ 先頭から ${1} + shift で sep を消費する
		# PRE (先頭セパレータ)
		case "$((Q_flg & SX_ARG_ISEP_PRE && Q_r == 0))" in 1)
			case "${1-}" in :*)
				__sx_var_bind Q_bind "${Q_bind}" "${1#:}" || {
					set -- "${Q_stat}"
					unset CLEANUP
					return "${1}"
				}
			esac

			shift
			M_NUM_DECR([|Q_cnt|])
		esac

		# 要素を左→右に走査してbind (for ループ)
		Q_i="-${Q_cnt}"
		for Q_arg in "${@}"; do
			M_NUM_INCR([|Q_i|])

			# 先頭の sep 領域をスキップ
			case "$((Q_i <= 0))" in 1) continue; esac

			# 内部セパレータ
			case "$((
				1 < Q_i &&
				Q_r < Q_i &&
				(Q_i - Q_r - 1) % ${Q_int#-} == 0
			))" in 1)
				case "${1-}" in :*)
					__sx_var_bind Q_bind "${Q_bind}" "${1#:}" || {
						set -- "${Q_stat}"
						unset CLEANUP
						return "${1}"
					}
				esac

				shift
			esac

			# 要素本体をbind
			__sx_var_bind Q_bind "${Q_bind}" "${Q_arg}" || {
				set -- "${Q_stat}"
				unset CLEANUP
				return "${1}"
			}
		done

		# POST (末尾セパレータ)
		case "$((Q_post))${1-}" in 1:*)
			__sx_var_bind Q_bind "${Q_bind}" "${1#:}" || :;;
		esac

		set -- "${Q_stat}"
		unset CLEANUP
		return "${1}"
	fi
}
|], [|arg_isep_cb|])dnl

M_RENAME_QI([|dnl
### __sx_arg_isep_lit - 引数間にリテラルセパレータを挿入する（内部用）
##
## 使い方:
##   __sx_arg_isep_lit 結果変数名 セパレータ インターバル フラグ リミット [値 ...]
##
## 説明:
##   引数間にセパレータを挿入し、すべてをクォートして結合する。
##   PRE/POST フラグにより先頭・末尾への挿入も行う。

define([|CLEANUP|], [|Q_bind Q_sep Q_int Q_flg Q_lim Q_eff Q_r Q_i Q_arg Q_max Q_post_ok|])dnl

__sx_arg_isep_lit() {
	Q_bind="${1}"
	Q_sep="${2}"
	Q_int="${3}"
	Q_lim="${4}"
	Q_flg="${5}"
	shift 5

	# セパレータを挿入可能な論理的な箇所数（要素間のみ）を計算
	Q_eff=$(((0 < ${#}) * (${#} - 1) / ${Q_int#-}))

	# --- 特殊処理: 負のインターバル（後方から数えるモード） ---
	# インターバルが負の場合、末尾（POST側）を基準にするため、
	# POSTフラグが指定されている場合は、ループ前にあらかじめ回数を1つ消費しておく。
	case "$((Q_int < 0 && Q_lim != 0 && Q_flg & SX_ARG_ISEP_POST))" in 1)
		Q_post_ok=1
		M_NUM_DECR([|Q_lim|])
	esac

	# --- 回数制限 (lim) の調整 ---
	# PRE/POSTフラグを含めた「物理的に挿入可能な絶対最大数」を算出し、lim がそれを超えないよう制限(cap)する。
	Q_max="${Q_eff}"
	case "$((Q_flg & SX_ARG_ISEP_PRE))" in [!0]*)
		M_NUM_INCR([|Q_max|])
	esac

	case "$((Q_flg & SX_ARG_ISEP_POST))" in [!0]*)
		M_NUM_INCR([|Q_max|])
	esac

	case "$((Q_max < Q_lim))" in 1)
		Q_lim="${Q_max}"
	esac

	# --- オフセット (r_) の計算 ---
	# ループ内で最初のセパレータをどこで入れるかを決めるための基準値を算出する。
	# 正の場合：単純にインターバル数。
	# 負の場合：要素数と残りの挿入可能回数から、左から数えて何個目を起点にするかを逆算。
	Q_r=$((0 < Q_int ? Q_int : ${#} - Q_lim * ${Q_int#-}))

	# --- PRE セパレータの挿入 ---
	# 先頭にセパレータを配置するフラグがある場合の処理。
	case "$((
		Q_flg & SX_ARG_ISEP_PRE &&
		(0 < Q_int ?
			Q_lim != 0 :
			Q_eff < Q_lim &&
			(Q_r % Q_int) == 0)
		))" in 1)
		__sx_var_bind Q_bind "${Q_bind}" "${Q_sep}" || {
			unset CLEANUP
			return M_EX_OK
		}
		M_NUM_DECR([|Q_lim|])
	esac

	Q_i=1
	# --- メインループ: 引数の結合 ---
	for Q_arg in "${@}"; do
		# 1. セパレータの挿入判定
		#    - 制限回数 (lim) が残っている
		#    - 最初の要素ではなく (1 < j_)
		#    - オフセット位置を過ぎており (r_ < j_)
		#    - インターバルの倍数位置である ((j - r - 1) % int == 0)
		case "$((
			Q_lim != 0 &&
			1 < Q_i &&
			Q_r < Q_i &&
			(Q_i - Q_r - 1) % Q_int == 0
		))" in 1)
			__sx_var_bind Q_bind "${Q_bind}" "${Q_sep}" || {
				unset CLEANUP
				return M_EX_OK
			}
			M_NUM_DECR([|Q_lim|])
		esac

		# 2. 値の結合（クォートして結合）
		__sx_var_bind Q_bind "${Q_bind}" "${Q_arg}" || {
			unset CLEANUP
			return M_EX_OK
		}
		M_NUM_INCR([|Q_i|])
	done

	# --- POST セパレータの挿入 ---
	# 末尾にセパレータを配置するフラグがある場合の処理。
	case "$((${Q_post_ok-0} || (
		0 < Q_int &&
		Q_lim != 0 &&
		Q_flg & SX_ARG_ISEP_POST &&
		(${#} - Q_r) % ${Q_int} == 0
	)))" in 1)
		__sx_var_bind Q_bind "${Q_bind}" "${Q_sep}" || :
	esac

	unset CLEANUP
}
|], [|arg_isep_lit|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_join() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_join "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_arg_join "${@}"
}

M_RENAME_QI([|dnl
### __sx_arg_join - 引数を指定された区切り文字で結合する（内部用）
##
## 使い方:
##   __sx_arg_join 結果変数名 区切り文字 [値 ...]
##
## 説明:
##   引数チェックを行わずに結合処理を行う。

define([|CLEANUP|], [|Q_res Q_sep Q_out Q_arg|])dnl

__sx_arg_join() {
	Q_res="${1}"
	Q_sep="${2-}"
	Q_out=
	shift ${2+2}

	for Q_arg in "${@}"; do
		M_STR_APPEND([|Q_out|], [|"${Q_sep}${Q_arg}"|])
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out#"${Q_sep}"}|])

	unset CLEANUP
}
|], [|arg_join|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_len() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_len "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

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
	M_VAR_SET([|${1}|], [|$((${#} - 1))|])
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
##   64 => 引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78 => SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_map() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_map "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	__sx_var_is_bind "${1-}" || return M_EX_USAGE

	__sx_var_is_bindable "${1-}" || return M_EX_NOPERM

	__sx_arg_map "${@}" || return
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

__sx_arg_map() {
	__sx_var_bind_init "${1}"

	# $1: status, $2: count, $3: callback, $4: bind, $@: 処理対象の引数
	set -- 0 -4 "${@}"

	for Q_arg in "${@}"; do
		set -- "${1}" "$((${2} + 1))" "${3}" "${4}" "${Q_arg}"

		case "$((${2} <= 0))" in 1)
			continue
		esac

		case "${3}" in '')
			break
		esac

		case "${1}" in
			0)
				unset CLEANUP
				shift

				"${3}" Q_ret "${4}" "${1}" && set -- "${?}" "${@}" || {
					set -- "${?}" "${@}"
					Q_ret="${5}"
				}
				;;
			*) Q_ret="${5}";;
		esac

		case "${Q_ret+X}" in X)
			__sx_var_ubind Q_fmt "${3}" "${Q_ret}"

			set -- "${1}" "${2}" "${Q_fmt}" "${4}"
		esac

		unset Q_ret Q_fmt
	done

	unset CLEANUP
	return "${1}"
}
|], [|arg_map|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_quote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_quote "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	__sx_var_is_bind "${1-}" || return M_EX_USAGE

	__sx_var_is_bindable "${1-}" || return M_EX_NOPERM

	__sx_arg_quote "${@}"
}

M_RENAME_QI([|dnl
### __sx_arg_quote - 引数をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_quote スキーマ [値 ...]
##
## 説明:
##   引数チェックを行わずに分配代入およびクォート結合処理を行う。

define([|CLEANUP|], [|Q_bind|])dnl

__sx_arg_quote() {
	__sx_var_bind_init "${1-}"
	__sx_var_bind Q_bind "${@}" || :

	unset CLEANUP
}
|], [|arg_quote|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_pad() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_pad "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*)
			__sx_var_is_bind ${1+"${1}"} || return M_EX_USAGE

			__sx_var_is_bindable ${1+"${1}"} || return M_EX_NOPERM
			;;
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}") ;;
		"${3+X${3}}" | "${4+X${4}}") __sx_num_is_int_safe_inv "${2}" || return M_EX_USAGE;;
		"${5+X${5}}")
			__sx_num_is_int_safe_inv "${2}" && __sx_num_is_int_safe_inv "${4}" || return M_EX_USAGE;;
	esac

	__sx_arg_pad "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_arg_pad - 引数リストをパディングスキーマで整形する（内部用）
##
## 使い方:
##   __sx_arg_pad [bind [len [val [flg]]]] ::: [arg ...]
##   __sx_arg_pad [bind] [arg ...]
##
## 説明:
##   sx_arg_pad の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_len Q_val Q_flg|])dnl

__sx_arg_pad() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			Q_bind="${1}"
			shift 2
			;;
		"${3+X${3}}")
			Q_bind="${1}" Q_len="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_bind="${1}" Q_len="${2}" Q_val="${3}"
			shift 4
			;;
		"${5+X${5}}")
			Q_bind="${1}" Q_len="${2}" Q_val="${3}" Q_flg="${4}"
			shift 5
			;;
		*)
			Q_bind="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	set -- "${Q_bind-}" "${Q_len:-0}" "${Q_val-}" "${Q_flg:-0}" "${@}"
	unset  CLEANUP

	__sx_var_bind_init "${1}"

	case "$((${4} & SX_ARG_PAD_CB))" in
		0) __sx_arg_pad_lit "${@}";;
		*) __sx_arg_pad_cb "${@}";;
	esac || return
}
|], [|arg_pad|])dnl

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_ex Q_ret|])dnl

__sx_arg_pad_cb() {
	set -- 1 1 0 "$((${2#-} - ${#} + 4))" "${@}"

	# 左パディング
	case "$((${6} < 0))" in 1)
		while M_NUM_LE([|${2}|], [|${4}|]) && M_STR_NE([|"${5}"|], [|''|]); do
			"${7}" Q_ret "${1}" "${2}" "${3}" || {
				Q_ex="${?}"
				break
			}

			case "${Q_ret+X}" in
				X)
					__sx_var_bind Q_bind "${5}" "${Q_ret}"
					eval 'shift 5;' set -- "$((${1} + 1))" "$((${2} + 1))" "${3}" "${4}" "${Q_bind}" '"${@}"'
					;;
				*) eval 'shift 3;' set -- "${1}" "$((${2} + 1))" "$((${3} + 1))" '"${@}"';;
			esac

			unset Q_ret Q_bind
		done
	esac

	# idx は左パディングで消費済み。残り8フィールドを-8カウンタでスキップ
	shift 1
	set -- -8 "${@}"

	for Q_arg in "${@}"; do
		set -- "$((${1} + 1))" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}"

		case "$((${1} <= 0))" in 1)
			continue
		esac

		__sx_var_bind Q_bind "${5}" "${Q_arg}" || break
		eval 'shift 5;' set -- "${1}" "${2}" "${3}" "${4}" "${Q_bind}" '"${@}"'
	done

	unset Q_arg Q_bind

	eval 'shift;' set -- "$((${1} + 1))" '"${@}"'

	case "$((${6} < 0))" in 0)
		while M_NUM_LE([|${2}|], [|${4}|]) && M_STR_NE([|"${5}"|], [|''|]); do
			"${7}" Q_ret "${1}" "${2}" "${3}" || {
				Q_ex="${?}"
				break
			}

			case "${Q_ret+X}" in
				X)
					__sx_var_bind Q_bind "${5}" "${Q_ret}"
					eval 'shift 5;' set -- "$((${1} + 1))" "$((${2} + 1))" "${3}" "${4}" "${Q_bind}" '"${@}"'
					;;
				*) eval 'shift 3;' set -- "${1}" "$((${2} + 1))" "$((${3} + 1))" '"${@}"';;
			esac

			unset Q_ret Q_bind
		done
	esac

	set -- "${Q_ex-0}"
	unset CLEANUP
	return "${1}"
}
|], [|arg_pad_cb|])dnl

M_RENAME_QI([|dnl
### __sx_arg_pad_lit - 引数リストをパディングする（内部用）
##
## 使い方:
##   __sx_arg_pad_lit スキーマ 長さ パディング値 [値 ...]
##
## 説明:
##   sx_arg_pad の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_len Q_val Q_needed Q_arg|])dnl

__sx_arg_pad_lit() {
	Q_bind="${1}"
	Q_len="${2}"
	Q_val="${3}"
	shift 4

	Q_needed=$((${Q_len#-} - ${#}))

	# 左パディング（needed <= 0 なら何もしない）
	case "${Q_len}" in -*)
		while M_NUM_LT([|0|], [|Q_needed|]); do
			__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" || {
				unset CLEANUP
				return M_EX_OK
			}

			M_NUM_DECR([|Q_needed|])
		done
	esac

	# 入力値を結合
	for Q_arg in "${@}"; do
		__sx_var_bind Q_bind "${Q_bind}" "${Q_arg}" || {
			unset CLEANUP
			return M_EX_OK
		}
	done

	# 右パディング（needed <= 0 なら何もしない）
	case "${Q_len}" in [!-]*)
		while M_NUM_LT([|0|], [|Q_needed|]); do
			__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" || :

			M_NUM_DECR([|Q_needed|])
		done
	esac

	unset CLEANUP
}
|], [|arg_pad_lit|])dnl

M_RENAME_Q([|dnl
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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE) - shape の形式が不正
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_shape|])dnl

sx_arg_resize() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_resize "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*)
			__sx_var_is_bind ${1+"${1}"} || return M_EX_USAGE

			__sx_var_is_bindable ${1+"${1}"} || return M_EX_NOPERM
			;;
	esac

	Q_shape=
	case "X${SX_CFG_SEP}" in
		"${3+X${3}}" | "${4+X${4}}") Q_shape="${2}";;
		"${5+X${5}}")
			__sx_num_is_nat0_safe "${4:-}" || return M_EX_USAGE
			Q_shape="${2}"
			;;
	esac

	case "${Q_shape}" in *::* | *-[02-9]* | *[!:0-9-]* | *-1*-1* | :* | *: | *-1[!:]*)
		unset CLEANUP
		return M_EX_USAGE
	esac

	unset CLEANUP

	__sx_arg_resize "${@}"
}
|], [|arg_resize|])dnl

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_padded Q_bind Q_shape Q_val Q_inferred Q_total Q_out Q_arg Q_tmp Q_cnt Q_dim Q_group Q_flg|])dnl

__sx_arg_resize() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			Q_bind="${1}"
			shift 2
			;;
		"${3+X${3}}")
			Q_bind="${1}" Q_shape="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_bind="${1}" Q_shape="${2}" Q_val="${3}"
			shift 4
			;;
		"${5+X${5}}")
			Q_bind="${1}" Q_shape="${2}" Q_val="${3}" Q_flg="${4}"
			shift 5
			;;
		*)
			Q_bind="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	: "${Q_bind=}" "${Q_shape:=${#}}" "${Q_val=}" "${Q_flg:=0}"

	__sx_var_bind_init "${Q_bind}"
	__sx_str_sub Q_shape: "${Q_shape}" : '*'
	__sx_str_sub Q_tmp: "${Q_shape}" -1 1
	Q_total=$((${Q_tmp}))

	# 形状解析
	case "${Q_shape}" in *-1*)
		Q_inferred=$((Q_total == 0 ? 0 : (${#} + Q_total - 1) / Q_total))

		Q_total=$((Q_total * Q_inferred))
		__sx_str_sub Q_shape: "${Q_shape}" -1 "${Q_inferred}"
	esac

	__sx_arg_pad Q_padded "$((Q_total * (Q_flg & SX_ARG_RESIZE_PAD_LEFT ? -1 : 1)))" "${Q_val}" ::: "${@}"

	eval set -- "${Q_padded}"

	# Phase 1-N: grouping (最内→最外)
	while M_STR_HAS([|"${Q_shape}"|], [|'*'|]); do
		Q_dim="${Q_shape##*'*'}"
		Q_shape="${Q_shape%'*'*}"
		Q_cnt=$((${Q_shape}))
		Q_out=

		while M_NUM_LT([|0|], [|Q_cnt|]); do
			case ${Q_dim} in
				[!0]*) __sx_arg_quote "${Q_dim}Q_group:" "${@}";;
				*) Q_group=;;
			esac

			__sx_arg_quote Q_group "${Q_group}"
			M_STR_APPEND([|Q_out|], [|" ${Q_group}"|])

			shift "${Q_dim}"
			M_NUM_DECR([|Q_cnt|])
		done

		eval set -- "${Q_out}"
	done

	for Q_arg in "${@}"; do
		case "$((0 < Q_shape))" in 0)
			break
		esac

		__sx_var_bind Q_bind "${Q_bind}" "${Q_arg}" || break
		M_NUM_DECR([|Q_shape|])
	done

	# クリーンアップ
	unset CLEANUP
}
|], [|arg_resize|])dnl

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
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_range "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe "${2-}" ${3+"${3}"} ${4+"${4}"} || return M_EX_USAGE

	case "${4-1}" in 0)
		return M_EX_USAGE
	esac

	__sx_arg_range "${@}"
}

M_RENAME_QI([|dnl
### __sx_arg_range - 位置パラメータの参照文字列を指定範囲で生成する（内部用）
##
## 使い方:
##   __sx_arg_range 宛先変数名 [開始 [終了 [ステップ]]]
##
## 説明:
##   指定された範囲のインデックスに対応する位置パラメータの参照文字列を生成し、
##   宛先変数に格納する。バリデーションは行わない。

define([|CLEANUP|], [|Q_res Q_idxs Q_tmp|])dnl

__sx_arg_range() {
	Q_res="${1}"
	shift
	__sx_num_range Q_idxs "${@}"

	case "${Q_idxs}" in
		'') M_VAR_SET([|${Q_res}|], [||]);;
		*)
			__sx_str_sub Q_tmp: "${Q_idxs}" ' ' '}" "${'
			M_VAR_SET([|${Q_res}|], [|\"\${${Q_tmp}}\"|])
			;;
	esac

	unset CLEANUP
}
|], [|arg_range|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_rfind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rfind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") ;;
		*)
			__sx_var_is_bind ${1+"${1}"} || return M_EX_USAGE

			__sx_var_is_bindable ${1+"${1}"} || return M_EX_NOPERM
			;;
	esac

	case "X${SX_CFG_SEP}" in
		"${1+X${1}}" | "${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}")
			__sx_num_is_nat0_safe "${3}" || return M_EX_USAGE

			case "$(((${3} & SX_ARG_RFIND_GLOB) * (${3} & SX_ARG_RFIND_CB)))" in [!0])
				return M_EX_USAGE
			esac
			;;
	esac

	__sx_arg_rfind "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_arg_rfind - 引数リストから指定された値を後ろ向きに探す（内部用: ディスパッチャ）
##
## 使い方:
##   __sx_arg_rfind 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   ::: セパレータをパースし、フラグに応じて __sx_arg_rfind_lit または
##   __sx_arg_rfind_cb にディスパッチする。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_tgt Q_flg|])dnl

__sx_arg_rfind() {
	case "X${SX_CFG_SEP}" in
		"${1+X${1}}") shift;;
		"${2+X${2}}")
			Q_bind="${1}"
			shift 2;;
		"${3+X${3}}")
			Q_bind="${1}" Q_tgt="${2}"
			shift 3
			;;
		"${4+X${4}}")
			Q_bind="${1}" Q_tgt="${2}" Q_flg="${3}"
			shift 4
			;;
		*)
			Q_bind="${1-}"
			shift "$((0${1+1}))"
			;;
	esac

	set -- "${Q_bind-}" "${Q_tgt-}" "${Q_flg:-0}" "${@}"
	unset CLEANUP

	__sx_var_bind_init "${1}"

	case "$((${3} & SX_ARG_RFIND_CB))" in
		0) __sx_arg_rfind_lit "${@}";;
		*) __sx_arg_rfind_cb "${@}";;
	esac || return
}
|], [|arg_rfind|])dnl

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_bind|])dnl

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
				0) __sx_var_ubind Q_bind "${3}" "${1}";;
				*) eval __sx_var_bind Q_bind "${3}" "\"\${$((${1} + 8))}\"";;
			esac

			eval 'shift 3;' set -- "$((${1} - 1))" "$((${2} + 1))" '"${Q_bind}"' '"${@}"'
		else
			eval 'shift 1;' set -- "$((${1} - 1))" '"${@}"'
		fi

		unset CLEANUP
	done

	return "$((!${2}))"
}
|], [|arg_rfind_cb|])dnl

M_RENAME_QI([|dnl
### __sx_arg_rfind_lit - 引数リストから指定された値を後ろ向きに探す（内部用: リテラル/Glob）
##
## 使い方:
##   __sx_arg_rfind_lit 結果変数名 [検索対象 [フラグ]] ::: [値 ...]
##
## 説明:
##   sx_arg_rfind のリテラル/Glob検索実装。末尾から先頭に向かって検索する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_match Q_glob Q_text Q_i Q_arg Q_sts|])dnl

__sx_arg_rfind_lit() {
	Q_bind="${1}"
	Q_match="${2}"
	Q_glob=$(((${3} & SX_ARG_RFIND_GLOB) != 0))
	Q_text=$(((${3} & SX_ARG_RFIND_TEXT) != 0))

	shift 3
	Q_i="${#}"

	while M_NUM_LT([|0|], [|Q_i|]) && M_STR_NE([|"${Q_bind}"|], [|''|]); do
		eval Q_arg=\"\${${Q_i}}\"

		case "${Q_glob}${Q_arg}" in "0${Q_match}" | 1${Q_match})
			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_i}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${Q_arg}";;
			esac

			Q_sts=M_EX_OK
		esac

		M_NUM_DECR([|Q_i|])
	done

	set -- "${Q_sts-1}"

	unset CLEANUP
	return "${1}"
}
|], [|arg_rfind_lit|])dnl

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
##   64 => 引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77 => 結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78 => SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_rfold() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rfold "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_arg_rfold "${@}" || return
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_ret Q_cb|])dnl

__sx_arg_rfold() {
	set -- "$((${#} - 3))" "${@}"

	while M_NUM_LT([|0|], [|${1}|]); do
		eval '"${3}"' Q_ret '"${4}"' "\"\${$((${1} + 4))}\"" "${1}" || {
			set -- "${?}" "${@}"
			M_VAR_SET([|${3}|], [|${5}|])
			unset Q_ret
			return "${1}"
		}

		Q_cb="${3}"
		: "${Q_ret=${4}}"

		eval 'shift 4;' set -- "$((${1} - 1))" "${2}" '"${Q_cb}"' '"${Q_ret}"' '"${@}"'

		unset CLEANUP
	done

	M_VAR_SET([|${2}|], [|${4}|])
}
|], [|arg_rfold|])dnl

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
##   64  引数不正、引数個数が安全範囲（SX_CFG_NUM_RANGE）外 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arg_rquote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_rquote "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE}" || return M_EX_CONFIG
	__sx_num_is_nat0_safe "${#}" || return M_EX_USAGE

	__sx_var_is_bind "${1-}" || return M_EX_USAGE

	__sx_var_is_bindable "${1-}" || return M_EX_NOPERM

	__sx_arg_rquote "${@}"
}

M_RENAME_QI([|dnl
### __sx_arg_rquote - 引数を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arg_rquote スキーマ [値 ...]
##
## 説明:
##   引数チェックを行わずに逆順分配代入およびクォート結合処理を行う。

define([|CLEANUP|], [|Q_bind Q_i Q_val|])dnl

__sx_arg_rquote() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift
	Q_i="${#}"

	while M_NUM_LT([|0|], [|Q_i|]); do
		eval "Q_val=\"\${${Q_i}}\""

		__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" || break

		M_NUM_DECR([|Q_i|])
	done

	unset CLEANUP
}
|], [|arg_rquote|])dnl

# ========================================
#  VAR (Variable)
# ========================================

### sx_var_bind - バインド状態に従って値を割り当てる
##
## 使い方:
##   sx_var_bind 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   バインド形式（a:b:c 等）を解析し、値を適切な変数に割り当てる。
##   割り当て後、残りのバインド形式が結果変数に格納される。
##   結果変数名に空文字列を指定した場合は、残りのバインド形式を書き込まずに破棄する。
##   複数の値を一度に割り当てることができ、各値はバインド形式の
##   セグメントに対して順次処理される。バインド先が枯渇し、未処理の
##   値が残る場合は終了ステータス 1 を返し、結果変数が空でない場合に限り
##   残りのバインド形式（枯渇時は空文字列）が書き込まれる。
##   蓄積スロット（数値プレフィックス付き・最後の変数）へ値を蓄積する際は
##   値をクォートする。クォートせずに蓄積したい場合は sx_var_ubind を
##   使用する。代入スロット（名前:残り）への代入は値のクォートを行わない。
##   蓄積スロットは、既存値が空文字列の場合（bind 未到達を含む）は
##   セパレータを付加せず蓄積する。
##   @name / N@name 形式の要素は sx 配列への分配先となる。配列要素への
##   代入時は値をクォートしない（sx_var_ubind と同一）。
##   バインド形式は事前に sx_var_bind_init で初期化されている必要がある。
##   未初期化の状態で呼び出すと終了ステータス 65 を返す。
##   詳細は sx_var_is_bind_ready を参照。
##
## 終了ステータス:
##    0  割り当て成功 (SX_EX_OK)
##    1  バインド先がもうない（データがバインド先より多い）。結果変数が空でない場合に限り空文字列が書き込まれる
##   64  引数不正 (SX_EX_USAGE)
##   65  バインド先が割当て可能な状態にない (SX_EX_DATAERR)
##   77  結果変数名（空でない場合）またはバインド先が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_bind "${@}" || return; return 0;; esac

	# 結果変数名自体の妥当性と書き込み権限をチェック
	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	case "${1-}" in ?*)
		sx_var_is_name "${1-}" || return M_EX_USAGE

		__sx_var_is_rw "${1}" || return M_EX_NOPERM
	esac

	__sx_var_is_bind "${2-}" || return M_EX_USAGE

	__sx_var_is_bindable "${2-}" || return M_EX_NOPERM

	__sx_var_is_bind_ready "${2-}" || return M_EX_DATAERR

	__sx_var_bind "${@}" || return
}

### __sx_var_bind - バインド状態に従って値を割り当てる（クォートあり・内部用）
##
## 使い方:
##   __sx_var_bind 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_var_bind の内部実装。リスト蓄積時に値をクォートする。
##   引数の検証を行わない。結果変数名が空文字列の場合は残りを破棄する。
##   バインド先が枯渇し、未処理の値が残る場合は終了ステータス 1 を返し、
##   結果変数が空でない場合に限り残りのバインド形式（枯渇時は空文字列）が書き込まれる。
##
## 終了ステータス:
##    0  割り当て成功
##    1  バインド先がもうない（データがバインド先より多い）。結果変数が空でない場合に限り空文字列が書き込まれる

__sx_var_bind() {
	__sx_var_bind0 1 "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_bind0 - 複数の値をバインド状態に従って順次割り当てる
##
## 使い方:
##   __sx_var_bind0 エスケープフラグ(1/0) 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_var_bind / sx_var_ubind の共通コア実装。
##   データ列を for で巡回し、1 データにつきバインド状態を 1 セグメント分
##   進める。蓄積スロット（数値プレフィックス付き・最後の変数）は
##   Q_esc に応じて値をクォートして累積する。
##   @name / N@name 形式の要素は sx 配列へ値を追加し、クォートは行わない。
##   結果変数名が空文字列の場合は残りのバインド形式を破棄する。
##   バインド先が枯渇した場合は Q_res が空でない場合に限り空の残りバインドを書き込んで 1 を返す。
##
## 終了ステータス:
##    0  データを全て割り当て、結果変数が空でない場合に限り残りのバインド形式を格納した
##    1  バインド先が枯渇したままデータが残っている。結果変数が空でない場合に限り空文字列を書き込む

define([|CLEANUP|], [|Q_esc Q_res Q_bind Q_seg Q_lim Q_vn Q_tmp Q_val|])dnl
__sx_var_bind0() {
	Q_esc="${1}"
	Q_res="${2}"
	Q_bind="${3}"
	shift 3

	while M_STR_NE([|"${#}"|], [|0|]); do
		case "${Q_bind}" in
			[1-9]*:*)
				Q_seg="${Q_bind%%:*}"
				Q_lim="${Q_bind%%[!0-9]*}"
				Q_vn="${Q_seg#"${Q_lim}"}"

				case "${Q_vn}" in
					'')
						__sx_num_cmp_nat0 "${Q_lim}" "${#}" || case "${?}" in [12])
							shift "${Q_lim}"
							Q_bind="${Q_bind#*:}"
							continue
						esac

						__sx_num_sub_nat0 Q_lim "${Q_lim}" "${#}"
						shift "${#}"
						;;
					@*)
						Q_tmp="${Q_vn#@}"

						for Q_val in "${@}"; do
							shift

							SX_CFG_ARR_UPDATE=0 __sx_arr_push "${Q_tmp}" "${Q_val}"

							case "${Q_lim}" in 1)
								Q_bind="${Q_bind#*:}"
								continue 2
							esac

							M_NUM_DECRM1([|Q_lim|])
						done
						;;
					*)
						Q_tmp=

						for Q_val in "${@}"; do
							shift

							case "${Q_esc}" in 1)
								__sx_str_quote Q_val "${Q_val}"
							esac

							Q_tmp="${Q_tmp} ${Q_val}"

							case "${Q_lim}" in 1)
								eval "${Q_vn}=\"\${${Q_vn}-}\${${Q_vn}:+ }\${Q_tmp# }\""
								Q_bind="${Q_bind#*:}"
								continue 2
							esac

							M_NUM_DECRM1([|Q_lim|])
						done

						eval "${Q_vn}=\"\${${Q_vn}-}\${${Q_vn}:+ }\${Q_tmp# }\""
						;;
					'')
				esac

				Q_bind="${Q_lim}${Q_vn}:${Q_bind#*:}"
				break
				;;
			["${SX_STR_SWORD}"]*:*) M_VAR_SET([|${Q_bind%%:*}|], [|${1}|]);&
			:*)
				Q_bind="${Q_bind#*:}"
				shift
				;;
			@*)
				SX_CFG_ARR_UPDATE=0 __sx_arr_push "${Q_bind#@}" "${@}"
				break
				;;
			?*)
				Q_tmp=

				for Q_val in "${@}";do
					case "${Q_esc}" in 1)
						__sx_str_quote Q_val "${Q_val}"
					esac

					Q_tmp="${Q_tmp} ${Q_val}"
				done

				eval "${Q_bind}=\"\${${Q_bind}-}\${${Q_bind}:+ }\${Q_tmp# }\""
				break
				;;
			*)
				case "${Q_res}" in ?*)
					M_VAR_SET([|${Q_res}|], [|${Q_bind}|])
				esac

				unset CLEANUP
				return 1
				;;
		esac
	done

	case "${Q_res}" in ?*)
		M_VAR_SET([|${Q_res}|], [|${Q_bind}|])
	esac

	unset CLEANUP
}
|], [|var_bind0|])dnl

### sx_var_bind_init - バインド形式に基づき変数を初期化する
##
## 使い方:
##   sx_var_bind_init [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   指定されたバインド形式に従って、変数を初期化する。
##   通常の変数は削除（unset）され、数値プレフィックス（N名前）付きの変数は
##   空文字列（''）で初期化される。最後の変数も空文字列（''）で初期化される。
##   これにより、通常の変数が「省略された」ことを sx_var_is_set で判定でき、
##   蓄積スロット（数値プレフィックス付き・最後の変数）は bind が到達しなかった
##   場合でも「0 個のリスト」として常に参照可能（eval set -- "${v}" 等が安全）である。
##   対象が sx 配列である場合は、その関連要素（_len, _n 等）も含めて削除される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  バインド形式が不正 (SX_EX_USAGE)
##   77  書き込み不可な変数が含まれる (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_bind_init() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_bind_init "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${@}" || return M_EX_USAGE

	__sx_var_is_bindable "${@}" || return M_EX_NOPERM

	__sx_var_bind_init "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_bind_init - バインド形式に基づき変数を初期化する（内部用）
##
## 使い方:
##   __sx_var_bind_init [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   sx_var_bind_init の内部実装。
##   引数チェックは行わない。
##   通常の変数は削除（unset）され、数値プレフィックス（N名前）付きの変数と
##   最後の変数は空文字列（''）で初期化される。
##   対象が sx 配列である場合は、その関連要素（_len, _n 等）も含めて削除する。

define([|CLEANUP|], [|Q_arg Q_seg|])dnl

__sx_var_bind_init() {
	for Q_arg in "${@}"; do
		while
			Q_seg="${Q_arg%%:*}"

			case "${Q_seg}" in
				*@*) __sx_arr_gen "${Q_seg#*@}";;
				["${SX_STR_SWORD}"]*) unset "${Q_seg}";;
				*["${SX_STR_SWORD}"]*) eval "M_STR_LTRIM([|Q_seg|], [|[!0-9]|])=";;
			esac

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done

		case "${Q_seg}" in ["${SX_STR_SWORD}"]*)
			eval "${Q_seg}="
		esac
	done

	unset CLEANUP
}
|], [|var_bind_init|])dnl


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

	sx_var_is_chain "${@}" || return M_EX_USAGE

	__sx_var_is_copyable "${@}" || return M_EX_NOPERM

	__sx_var_copy "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_copy - 変数の値を連鎖コピーする（内部用）
##
## 使い方:
##   __sx_var_copy [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_copy の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_asg|])dnl

__sx_var_copy() {
	__sx_var_copy_script Q_asg "${@}"

	# 代入の実行
	eval "${Q_asg}"

	# 内部用変数を掃除
	unset CLEANUP
}
|], [|var_copy|])dnl

### sx_var_copy_script - 変数のコピー用スクリプトを生成する
##
## 使い方:
##   sx_var_copy_script 結果変数名 [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   与えられた連鎖式群に対するコピー処理で必要となる、
##   実行可能なコピースクリプトを生成して結果変数に格納する。
##   連鎖ごとにコピー先の削除（__sx_var_unset）に続けて、
##   コピー元の現在値を取得した代入式（dest='値'）または削除式（unset -v dest）を
##   SX_STR_LF 区切りで並べる。コピー元が sx 配列である場合は、
##   関連するすべての要素も含めて展開する。
##   生成されたスクリプトは eval で実行できる。
##   連鎖式が指定されない場合や引数が単一の変数名の場合は、空文字列を格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_copy_script() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_copy_script "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_rw "${1}" || return M_EX_NOPERM
	sx_var_is_chain "${@}" || return M_EX_USAGE

	__sx_var_copy_script "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_copy_script - 変数のコピー用スクリプトを生成する（内部用）
##
## 使い方:
##   __sx_var_copy_script 結果変数名 [変数名1 [変数名2 [変数名3 ...]]]
##
## 説明:
##   sx_var_copy_script の内部実装。
##   変数名列から右方向連鎖コピー用の実行スクリプトを生成する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_out Q_chain Q_dest Q_dep Q_src Q_vn Q_set Q_val Q_expr Q_unset|])dnl

__sx_var_copy_script() {
	Q_res="${1}"
	Q_out=
	shift

	for Q_chain in "${@}"; do
		Q_src=

		while
			case "${Q_chain}" in
				*=*) Q_dest="${Q_chain##*=}" Q_chain="${Q_chain%=*}";;
				*-*) Q_dest="${Q_chain%%-*}" Q_chain="${Q_chain#*-}";;
				*) Q_dest="${Q_chain}" Q_chain=;;
			esac

			case "${Q_src}" in ?*)
				Q_expr= Q_unset=

				__sx_var_list_dep Q_dep "${Q_src}"

				eval set -- "${Q_dep}"

				for Q_vn in "${@}"; do
					eval "Q_set=\"\${${Q_vn}+X}\" Q_val=\"\${${Q_vn}-}\""
					case "${Q_set}" in
						X)
							__sx_str_quote Q_val "${Q_val}"

							M_STR_APPEND([|Q_expr|], [|"${Q_dest}${Q_vn#"${Q_src}"}=${Q_val} "|])
							;;
						*) M_STR_APPEND([|Q_unset|], [|"${Q_dest}${Q_vn#"${Q_src}"} "|]);;
					esac
				done

				M_STR_APPEND([|Q_out|], [|"__sx_var_unset ${Q_dest}${SX_STR_LF}${Q_expr}${SX_STR_LF}${Q_unset:+unset -v ${Q_unset}${SX_STR_LF}}"|])
			esac

			case "${Q_chain}" in '')
				break
			esac

			Q_src="${Q_dest}"
			continue
		do :; done
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out}|])

	unset CLEANUP
}
|], [|var_copy_script|])dnl

### sx_var_dump - 変数や配列の状態を文字列として取得する
##
## 使い方:
##   sx_var_dump 結果変数名 [名前1 ...]
##
## 説明:
##   指定された変数（または配列）の現在の状態を、代入式（name='value'）の
##   形式で取得し、結果変数に格納する。配列の場合は関連する全要素を含む。
##   変数が設定されていない場合は 'unset -v name' の形式となる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_var_dump() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_dump "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" "${@}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_var_dump "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_dump - 変数や配列の状態を文字列として取得する（内部用）
##
## 使い方:
##   __sx_var_dump 結果変数名 [名前1 ...]
##
## 説明:
##   sx_var_dump の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_out Q_dep Q_vn Q_set Q_val|])dnl

__sx_var_dump() {
	Q_res="${1}"
	Q_out=
	shift

	__sx_var_list_dep Q_dep "${@}"
	eval set -- "${Q_dep}"

	for Q_vn in "${@}"; do
		eval "Q_set=\"\${${Q_vn}+X}\" Q_val=\"\${${Q_vn}-}\""

		case "${Q_set}" in
			X)
			__sx_str_quote Q_val "${Q_val}"

				M_STR_APPEND([|Q_out|], [|"${Q_vn}=${Q_val}${SX_STR_LF}"|])
				;;
			*) M_STR_APPEND([|Q_out|], [|"unset -v ${Q_vn}${SX_STR_LF}"|]);;
		esac
	done

	M_VAR_SET([|${Q_res}|], [|${Q_out}|])

	unset CLEANUP
}
|], [|var_dump|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_arr "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_arr - 指定された変数がsx配列であるか確認する（内部用）
##
## 使い方:
##   __sx_var_is_arr [変数名1 ...]
##
## 説明:
##   変数の値（シグネチャ）と長さ変数の妥当性をチェックする。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_is_arr() {
	for Q_arg in "${@}"; do
		if
			! eval sx_str_sw "\"\${${Q_arg}-}\"" '"${SX_CFG_SIG_ARR}":' ||
			! eval __sx_num_is_nat0_base 10 "\"\${${Q_arg}_len-}\""
		then
			unset CLEANUP
			return 1
		fi
	done

	unset CLEANUP
}
|], [|var_is_arr|])dnl

### sx_var_is_bind - 文字列が分配代入バインド形式として有効か確認する
##
## 使い方:
##   sx_var_is_bind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、分配代入バインド形式（var1:var2::var3 等）
##   として有効な形式であるかを確認する。
##   各要素は以下のいずれかである必要がある。
##     - 有効な変数名
##     - スキップを意味する空文字列
##     - 数値プレフィックス付きの要素（N名前 / N）
##       N は 1 以上の自然数。カウント値に上限はない（多倍長で処理される）。
##       先頭に 0 を置くことはできない（10進のみ解釈）。
##   最後の要素は残り蓄積先として変数名で直接使用されるため、
##   数字で始めることはできない。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
sx_var_is_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_bind "${@}" || return; return 0;; esac

	__sx_var_is_bind "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_is_bind - 文字列が分配代入バインド形式として有効か確認する（内部用）
##
## 使い方:
##   __sx_var_is_bind [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_var_is_bind の内部実装。SX_CFG_NUM_RANGE の妥当性チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_mark Q_seg Q_vn Q_type Q_tmp|])dnl

__sx_var_is_bind() {
	for Q_arg in "${@}"; do
		Q_mark=

		case "${Q_arg}" in *[!":@${SX_STR_WORD}"]* | 0* | *:0* | *@ | *@[!"${SX_STR_SWORD}"]* | @*:* | *[!0-9]@*:*)
			eval unset CLEANUP "${Q_mark}"
			return 1
		esac

		case "${Q_arg##*:}" in [0-9]*)
			eval unset CLEANUP "${Q_mark}"
			return 1
		esac

		while
			Q_seg="${Q_arg%%:*}"
			Q_vn=

			case "${Q_seg}" in
				*[!0-9]*@*)
					eval unset CLEANUP "${Q_mark}"
					return 1
					;;
				*@*) Q_vn="${Q_seg#*@}" Q_type=arr;;
				["${SX_STR_SWORD}"]*)
					case "${Q_arg}" in
						*:*) Q_vn="${Q_seg}" Q_type=scalar;;
						*) Q_vn="${Q_seg}" Q_type=list;;
					esac
					;;
				*["${SX_STR_SWORD}"]*) Q_vn="M_STR_LTRIM([|Q_seg|], [|[!0-9]|])" Q_type=list;;
			esac

			case "${Q_vn}" in ?*)
				eval "Q_tmp=\"\${Q_v${Q_vn}_=${Q_type}}\""
				M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])

				if M_STR_NE([|"${Q_tmp}"|], [|"${Q_type}"|]); then
					eval unset CLEANUP "${Q_mark}"
					return 1
				fi
			esac

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done

		eval ${Q_mark:+"unset ${Q_mark}"}
	done

	unset CLEANUP
}
|], [|var_is_bind|])dnl

### sx_var_is_bind_ready - バインド形式が直ちにバインド可能な状態か確認する
##
## 使い方:
##   sx_var_is_bind_ready [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   引数で指定されたすべてのバインド形式が、直ちに sx_var_bind / sx_var_ubind
##   で使用できる状態（bind_init 直後の状態）にあるかを確認する。
##   各要素は以下の状態である必要がある。
##     - @name / N@name: 対象が sx 配列であること
##     - 中間の素変数名: 未設定であること
##     - 末尾の素変数名: 設定済みであること
##     - 数値プレフィックス付きの要素（N名前）: 数字を除いた名前が設定済みであること
##   空セグメントと裸の数値は検査対象外とする。
##   bind_init を事前に実行していないバインド形式は拒否される。
##
## 終了ステータス:
##    0  すべてバインド可能な状態である (SX_EX_OK)
##    1  バインド可能な状態にないものが含まれる
##   64  バインド形式が不正 (SX_EX_USAGE)
sx_var_is_bind_ready() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_bind_ready "${@}" || return; return 0;; esac

	__sx_var_is_bind "${@}" || return M_EX_USAGE

	__sx_var_is_bind_ready "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_bind_ready - バインド形式が直ちにバインド可能な状態か確認する（内部用）
##
## 使い方:
##   __sx_var_is_bind_ready [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   sx_var_is_bind_ready の内部実装。
##   引数チェックは行わない。
##
## 終了ステータス:
##    0  すべてバインド可能な状態である (SX_EX_OK)
##    1  バインド可能な状態にないものが含まれる

define([|CLEANUP|], [|Q_arg Q_seg|])dnl

__sx_var_is_bind_ready() {
	for Q_arg in "${@}"; do
		while
			Q_seg="${Q_arg%%:*}"

			case "${Q_seg}" in
				*@*) __sx_var_is_arr "${Q_seg#*@}";;
				[${SX_STR_SWORD}]*)
					case "${Q_arg}" in
						*:*) ! __sx_var_is_set "${Q_seg}";;
						*) __sx_var_is_set "${Q_seg}";;
					esac
					;;
				*[${SX_STR_SWORD}]*) __sx_var_is_set "M_STR_LTRIM([|Q_seg|], [|[!0-9]|])";;
			esac || {
				unset CLEANUP
				return 1
			}

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done
	done

	unset CLEANUP
}
|], [|var_is_bind_ready|])dnl

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

	__sx_var_is_bind "${@}" || return M_EX_USAGE

	__sx_var_is_bindable "${@}" || return
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_str Q_arr Q_arg Q_seg|])dnl

__sx_var_is_bindable() {
	Q_str=
	Q_arr=

	for Q_arg in "${@}"; do
		while
			Q_seg="${Q_arg%%:*}"

			case "${Q_seg}" in
				*@*) M_STR_APPEND([|Q_arr|], [|"${Q_seg#*@} "|]);;
				["${SX_STR_SWORD}"]*) M_STR_APPEND([|Q_str|], [|"${Q_seg} "|]);;
				*["${SX_STR_SWORD}"]*) M_STR_APPEND([|Q_str|], [|"M_STR_LTRIM([|Q_seg|], [|[!0-9]|]) "|]);;
			esac

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done
	done

	eval ${Q_str:+"__sx_var_is_rw ${Q_str}"} && eval ${Q_arr:+"__sx_var_is_rw_deep ${Q_arr}"} || {
		unset CLEANUP
		return 1
	}

	unset CLEANUP
}
|], [|var_is_bindable|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_var_is_chain() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) ! M_STR_MATCH([|"${Q_arg}"|], [|*[!"${SX_STR_WORD}"=]*|], [|*==*|], [|=*|], [|*=|], [|[0-9]*|], [|*=[0-9]*|]);;
			*-*) ! M_STR_MATCH([|"${Q_arg}"|], [|*[!"${SX_STR_WORD}"-]*|], [|*--*|], [|-*|], [|*-|], [|[0-9]*|], [|*-[0-9]*|]);;
			*) sx_var_is_name "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|var_is_chain|])dnl

### sx_var_is_copyable - コピー先が構造を含めて書き込み可能か確認する
##
## 使い方:
##   sx_var_is_copyable [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   与えられた連鎖式群を実行した場合に、書き込み対象となる全ての変数
##   （配列の子要素を含む）が書き込み可能か確認する。
##   「名前_*」形式の変数は暗黙的に「名前」に属するとみなす。
##   そのため、宛先が配列でない場合でも、属する全ての変数が
##   書き込み可能であることを要求する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_var_is_copyable() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_copyable "${@}" || return; return 0;; esac

	sx_var_is_chain "${@}" || return M_EX_USAGE

	__sx_var_is_copyable "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_copyable - コピー先が構造を含めて書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_copyable [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_is_copyable の内部実装。
##   引数チェックは行わない。
##   「名前_*」形式の変数は暗黙的に「名前」に属するとみなすため、
##   __sx_var_is_rw_deep により配下の変数も含めて確認する。

define([|CLEANUP|], [|Q_ls Q_arg|])dnl

__sx_var_is_copyable() {
	Q_ls=''

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) Q_arg="${Q_arg%[=-]*}";;
			*-*) Q_arg="${Q_arg#*[=-]}";;
			*) continue;;
		esac

		while M_STR_MATCH([|"${Q_arg}"|], [|*[=-]*|]); do
			M_STR_APPEND([|Q_ls|], [|" ${Q_arg%%[=-]*}"|])
			Q_arg="${Q_arg#*[=-]}"
		done

		M_STR_APPEND([|Q_ls|], [|" ${Q_arg}"|])
	done

	eval set -- "${Q_ls}"
	unset CLEANUP

	__sx_var_is_rw_deep "${@}" || return
}
|], [|var_is_copyable|])dnl

### sx_var_is_ebind - 文字列が拡張バインド形式として有効か確認する
##
## 使い方:
##   sx_var_is_ebind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、拡張バインド形式として有効であるかを確認する。
##   vn を変数名、nat1 を [1-9][0-9]*、nat0 を 0|nat1、M を nat0、N を nat1 とし、
##   seg を M/vn | M/Nvn | M/ | M/N | vn | 空 | M/@vn | M/N@vn、
##   ebind を seg(:seg)* とする。N が存在する場合は M<N が必須である。
##   素 vn は scalar、M/vn・M/Nvn は list、
##   M/@vn・M/N@vn は arr、空・M/・M/N は型なしとなる。
##   異なる型で同名の変数を2回以上利用するのはエラー（sx_var_is_bind と同様）。
##   数値に上限はない（SX_CFG_NUM_RANGE は設定の妥当性チェックにのみ使用される）。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_is_ebind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_ebind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_ebind "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_is_ebind - 文字列が拡張バインド形式として有効か確認する（内部用）
##
## 使い方:
##   __sx_var_is_ebind [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_var_is_ebind の内部実装。SX_CFG_NUM_RANGE の妥当性チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_mark Q_seg Q_vn Q_type Q_tmp Q_frac|])dnl

__sx_var_is_ebind() {
	for Q_arg in "${@}"; do
		Q_mark=

		case "${Q_arg}" in *[!":@/${SX_STR_WORD}"]* | 0 | 0[!/]* | *:0[!/]* | /* | *[!0-9]/* | */0* | *@ | *@[!"${SX_STR_SWORD}"]* | @* | *[!/0-9]@*)
			eval unset CLEANUP "${Q_mark}"
			return 1
		esac

		while
			Q_seg="${Q_arg%%:*}"
			Q_vn=

			case "${Q_seg}" in
				*[!0-9]*/* | *[!/0-9]*@*)
					eval unset CLEANUP "${Q_mark}"
					return 1
					;;
				*/*)
					Q_frac="${Q_seg%%[!/0-9]*}"

					# M nat0・N nat1は事前検査で保証済み
					case "${Q_frac}" in *[0-9])
						__sx_num_cmp_nat0 "${Q_frac%/*}" "${Q_frac#*/}" || case "${?}" in [23])
							eval unset CLEANUP "${Q_mark}"
							return 1
						esac
					esac

					Q_seg="${Q_seg#"${Q_frac}"}"

					case "${Q_seg}" in
						@*) Q_vn="${Q_seg#*@}" Q_type=arr;;
						?*) Q_vn="${Q_seg}" Q_type=list;;
					esac
					;;
				[1-9]*)
					eval unset CLEANUP "${Q_mark}"
					return 1
					;;
				*) Q_vn="${Q_seg}" Q_type=scalar;;
			esac

			case "${Q_vn}" in ?*)
				eval "Q_tmp=\"\${Q_v${Q_vn}_=${Q_type}}\""
				M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])

				if M_STR_NE([|"${Q_tmp}"|], [|"${Q_type}"|]); then
					eval unset CLEANUP "${Q_mark}"
					return 1
				fi
			esac

			case "${Q_arg}" in
				*:*) Q_arg="${Q_arg#*:}";;
				*) break;;
			esac

			continue
		do :; done

		eval ${Q_mark:+"unset ${Q_mark}"}
	done

	unset CLEANUP
}
|], [|var_is_ebind|])dnl

### sx_var_to_ebind - bind形式を拡張bind形式に変換する
##
## 使い方:
##   sx_var_to_ebind 結果変数名 bind形式
##
## 説明:
##   bind形式（sx_var_is_bind 参照）を拡張bind形式（sx_var_is_ebind 参照）の
##   初期状態（進行度0）に変換し、結果変数に格納する。
##   中間の N / Nvn / N@vn は 0/N 形式に、同名の再利用は合算して M/N 形式にする。
##   末尾の素 vn / @vn は M/vn / M/@vn 形式の rest に変換する。
##   例: 2:3a:b:9@c:2a:2d::d -> 0/2:0/3a:b:0/9@c:3/5a:0/2d::2/d
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正、bind形式が不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_to_ebind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_to_ebind "${@}" || return; return 0;; esac

	case "${#}" in 2) ;; *) return M_EX_USAGE;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_var_is_bind "${2-}" || return M_EX_USAGE

	__sx_var_to_ebind "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_to_ebind - bind形式を拡張bind形式に変換する（内部用）
##
## 使い方:
##   __sx_var_to_ebind 結果変数名 bind形式
##
## 説明:
##   sx_var_to_ebind の内部実装。
##   内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_bind Q_out Q_mark Q_seg Q_n Q_vn Q_prior Q_e|])dnl

__sx_var_to_ebind() {
	# 残り入力・出力バッファ・動的合算値の後始末リストを初期化する。
	# 動的合算値は変数ごとに作る（初出0、2回目以降は前回までの合計）。
	Q_res="${1}"
	Q_bind="${2-}"
	Q_out=
	Q_mark=

	# bindを先頭から1セグメントずつ切り出してebind片へ直す。
	# コロンの数を保存するため、空セグメントも1件として扱う。
	while
		# セグメント分割: コロンが残っていれば中間、なければ末尾。
		Q_seg="${Q_bind%%:*}"

		# セグメント別の変換則:
		#   空     -> 空のまま（1件スキップ）
		#   N      -> 0/N（N件スキップ）
		#   Nvn    -> Prior/Total+vn（同名は合算、初回は 0/N+vn）
		#   N@vn   -> Prior/Total@vn（配列版の合算）
		#   @vn    -> Prior/@vn（末尾の配列rest）
		#   素vn   -> 中間はそのまま、末尾は Prior/vn のrest化
		case "${Q_seg}" in
			'') Q_e=;;
			[1-9]*)
				# 先頭数字を個数、その残りを宛先に分ける。
				Q_n="${Q_seg%%[!0-9]*}"
				Q_vn="${Q_seg#"${Q_n}"}"

				case "${Q_vn}" in
					# 素の数値は型なしスキップなので合算不要。
					'') Q_e="0/${Q_n}";;
					@*)
						# 配列の制限付き取り分。同じ配列名の合計を積み上げる。
						Q_vn="${Q_vn#@}"
						eval "Q_prior=\"\${Q_s${Q_vn}_-0}\""
						__sx_num_add_nat0 "Q_s${Q_vn}_" "${Q_prior}" "${Q_n}"
						eval "Q_e=\"\${Q_prior}/\${Q_s${Q_vn}_}@\${Q_vn}\""
						M_STR_APPEND([|Q_mark|], [|"Q_s${Q_vn}_ "|])
						;;
					*)
						# 通常変数の制限付き取り分。例: 3a,2a -> 0/3a,3/5a。
						eval "Q_prior=\"\${Q_s${Q_vn}_-0}\""
						__sx_num_add_nat0 "Q_s${Q_vn}_" "${Q_prior}" "${Q_n}"
						eval "Q_e=\"\${Q_prior}/\${Q_s${Q_vn}_}\${Q_vn}\""
						M_STR_APPEND([|Q_mark|], [|"Q_s${Q_vn}_ "|])
						;;
				esac
				;;
			# 末尾の配列rest。ここまでの同名合計を分子に載せる。
			@*) eval "Q_e=\"\${Q_s${Q_seg#@}_-0}/${Q_seg}\"";;
			*)
				case "${Q_bind}" in
					# 中間の素変数は1件代入なので書き換えない。
					*:*) Q_e="${Q_seg}";;
					# 末尾の素変数は残り全部のrestなので M/vn 化する。
					*) eval "Q_e=\"\${Q_s${Q_seg}_-0}/\${Q_seg}\"";;
				esac
				;;
		esac

		# 変換片をコロン区切りで積む。末尾に毎回 : を付けておく。
		M_STR_APPEND([|Q_out|], [|"${Q_e}:"|])

		case "${Q_bind}" in *:*)
			Q_bind="${Q_bind#*:}"
			continue
		esac

		break
	do :; done

	# 積み上げ時に付けた余分な末尾 : を1つ落として確定させる。
	M_VAR_SET([|${Q_res}|], [|${Q_out%:}|])

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_to_ebind|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_empty "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_empty - 変数が設定されており、かつ空か確認する（内部用）
##
## 使い方:
##   __sx_var_is_empty 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が空（かつ設定済み）か確認する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_e|])dnl

__sx_var_is_empty() {
	for Q_arg in "${@}"; do
		eval "Q_e=\"\${${Q_arg}+X}\${${Q_arg}-}\""

		case "${Q_e}" in '' | X?*)
			unset CLEANUP
			return 1
		esac

		unset CLEANUP
	done
}
|], [|var_is_empty|])dnl

M_RENAME_Q([|dnl
### sx_var_is_name - 変数名として有効か確認する
##
## 使い方:
##   sx_var_is_name [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて有効な変数名 (SX_EX_OK)
##    1  無効な変数名が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_var_is_name() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in '' | [0-9]* | *[!"${SX_STR_WORD}"]*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|var_is_name|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_ro "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_ro - 変数が読み取り専用か確認する（内部用）
##
## 使い方:
##   __sx_var_is_ro 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が読み取り専用か確認する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_is_ro() {
	for Q_arg in "${@}"; do
		if __sx_var_is_rw "${Q_arg}"; then
			unset CLEANUP
			return 1
		fi

		unset CLEANUP
	done
}
|], [|var_is_ro|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE
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

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw_all "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_rw_all - 指定された変数および関連要素が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_rw_all 名前1 [名前2 ...]
##
## 説明:
##   sx_var_is_rw_all の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_ls|])dnl

__sx_var_is_rw_all() {
	__sx_var_list_dep Q_ls "${@}"
	eval set -- "${Q_ls}"
	unset CLEANUP

	__sx_var_is_rw "${@}" || return
}
|], [|var_is_rw_all|])dnl

### sx_var_is_rw_deep - 変数およびその配下のサブ変数がすべて書き込み可能か確認する
##
## 使い方:
##   sx_var_is_rw_deep 変数名 [変数名 ...]
##
## 説明:
##   指定された変数と、その配下に存在するサブ変数（${変数名}_len, ${変数名}_0, 等）が
##   すべて書き込み可能か確認する。
##   実際の変数構造に依存せず、現在読み取り専用として登録されている名前を
##   深さを問わず走査して検証する。実体が sx 配列でない場合でも確認自体は可能で、
##   その場合は変数名と配下のサブ変数の書き込み可否を検査する。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可が含まれる
##   64  引数不正 (SX_EX_USAGE)
sx_var_is_rw_deep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_is_rw_deep "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw_deep "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_rw_deep - 変数およびその配下のサブ変数がすべて書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_var_is_rw_deep 変数名 [変数名 ...]
##
## 説明:
##   sx_var_is_rw_deep の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_ro Q_out Q_arg Q_rest Q_tmp|])dnl

__sx_var_is_rw_deep() {
	Q_ro="${SX_STR_LF}$(readonly -p)${SX_STR_LF}"
	Q_out=

	for Q_arg in "${@}"; do
		Q_rest="${Q_ro}"

		while M_STR_HAS([|"${Q_rest}"|], [|"${SX_STR_LF}readonly ${Q_arg}"|]); do
			Q_rest="${Q_rest#*"${SX_STR_LF}readonly ${Q_arg}"}"

			case "${Q_rest}" in
				[${SX_STR_LF}=]*) M_STR_APPEND([|Q_out|], [|" ${Q_arg}"|]);;
				_[${SX_STR_ALNUM}]*)
					Q_tmp="${Q_rest%%[${SX_STR_LF}=]*}"

					if ! M_STR_MATCH([|${Q_tmp}|], [|*_|]) && sx_str_is_word "${Q_tmp}"; then
						M_STR_APPEND([|Q_out|], [|" ${Q_arg}_${Q_tmp#_}"|])
					fi
					;;
			esac
		done
	done

	eval set -- "${Q_out}"
	unset CLEANUP

	__sx_var_is_rw "${@}" || return
}
|], [|var_is_rw_deep|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_set "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_set - 変数が設定されているか確認する（内部用）
##
## 使い方:
##   __sx_var_is_set 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が設定されているか確認する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_e|])dnl

__sx_var_is_set() {
	for Q_arg in "${@}"; do
		eval "Q_e=\"\${${Q_arg}+X}\""

		case "${Q_e}" in '')
			unset CLEANUP
			return 1
		esac

		unset CLEANUP
	done
}
|], [|var_is_set|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE
	__sx_var_is_val "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_var_is_val - 変数が値を持ち、かつ空でないか確認する（内部用）
##
## 使い方:
##   __sx_var_is_val 変数名1 [変数名2 ...]
##
## 説明:
##   引数で指定されたすべての変数が値を持ち、空でないか確認する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_e|])dnl

__sx_var_is_val() {
	for Q_arg in "${@}"; do
		eval "Q_e=\"\${${Q_arg}:+X}\""

		case "${Q_e}" in '')
			unset CLEANUP
			return 1
		esac

		unset CLEANUP
	done
}
|], [|var_is_val|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_bind|])dnl

sx_var_list_dep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_list_dep "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_var_list_dep "${Q_bind}" "${@}"

	unset CLEANUP
}
|], [|var_list_dep|])dnl

M_RENAME_QI([|dnl
### __sx_var_list_dep - 指定された変数に関連するすべての変数名を取得する（内部用）
##
## 使い方:
##   __sx_var_list_dep 結果変数名 検索対象1 [検索対象2 ...]
##
## 説明:
##   位置パラメータをキューとして利用し、非再帰的に関連変数を収集する。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_mark Q_len Q_i|])dnl

__sx_var_list_dep() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_mark="${3+ }"
	shift

	while M_STR_NE([|"${#}"|], [|0|]); do
		if M_STR_MATCH([|"${Q_mark}"|], [|?*|]) && __sx_var_is_set "Q_v${1}_"; then
			shift
			continue
		fi

		__sx_var_ubind Q_bind "${Q_bind}" "${1}" || break

		case "${Q_mark}" in ?*)
			eval "Q_v${1}_="
			M_STR_APPEND([|Q_mark|], [|"Q_v${1}_ "|])
		esac

		if __sx_var_is_arr "${1}"; then
			set -- "${@}" "${1}_len"

			eval "Q_len=\"\${${1}_len}\""
			Q_i=0

			while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
				set -- "${@}" "${1}_${Q_i}"

				M_NUM_INCRM1([|Q_i|])
			done
		fi

		shift
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_list_dep|])dnl

### sx_var_list_ro - 読み取り専用変数の一覧を取得する
##
## 使い方:
##   sx_var_list_ro 結果変数名（またはバインド形式）
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

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_var_list_ro "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_list_ro - 読み取り専用変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_ro 結果変数名（またはバインド形式）
##
## 説明:
##   sx_var_list_ro の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_list Q_bind Q_mark Q_vn|])dnl

__sx_var_list_ro() {
	Q_list="${SX_STR_LF}$(readonly -p)${SX_STR_LF}"
	__sx_var_bind_init "${1-}"
	Q_bind="${1-}"
	Q_mark=

	while M_STR_HAS([|"${Q_list}"|], [|"${SX_STR_LF}readonly "|]); do
		Q_list="${Q_list#*${SX_STR_LF}readonly }"

		case "${Q_list}" in ["${SX_STR_SWORD}"]*)
			case "${Q_bind}" in '')
				break
			esac

			Q_vn="${Q_list%%[!"${SX_STR_WORD}"]*}"

			if
				sx_var_is_name "${Q_vn}" &&
				! __sx_var_is_set "Q_v${Q_vn}_" &&
				__sx_var_is_ro "${Q_vn}"
			then
				__sx_var_ubind Q_bind "${Q_bind}" "${Q_vn}"

				eval "Q_v${Q_vn}_="
				M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])
			fi
		esac
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_list_ro|])dnl

### sx_var_list_set - 設定されている変数の一覧を取得する
##
## 使い方:
##   sx_var_list_set 結果変数名（またはバインド形式）
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

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_var_list_set "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_list_set - 設定されている変数の一覧を取得する（内部用）
##
## 使い方:
##   __sx_var_list_set 結果変数名（またはバインド形式）
##
## 説明:
##   sx_var_list_set の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_list Q_bind Q_mark Q_ln Q_vn|])dnl

__sx_var_list_set() {
	Q_list="$(set)${SX_STR_LF}"
	__sx_var_bind_init "${1-}"
	Q_bind="${1-}"
	Q_mark=

	while M_STR_HAS([|"${Q_list}"|], [|"${SX_STR_LF}"|]); do
		Q_ln="${Q_list%%${SX_STR_LF}*}"
		Q_list="${Q_list#*${SX_STR_LF}}"

		case "${Q_ln}" in ["${SX_STR_SWORD}"]=* | ["${SX_STR_SWORD}"]*["${SX_STR_WORD}"]=*)
			case "${Q_bind}" in '')
				break
			esac

			Q_vn="${Q_ln%%=*}"

			if
				sx_var_is_name "${Q_vn}" &&
				! __sx_var_is_set "Q_v${Q_vn}_" &&
				__sx_var_is_set "${Q_vn}"
			then
				__sx_var_ubind Q_bind "${Q_bind}" "${Q_vn}"

				eval "Q_v${Q_vn}_="
				M_STR_APPEND([|Q_mark|], [|"Q_v${Q_vn}_ "|])
			fi
		esac
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|var_list_set|])dnl

M_RENAME_Q([|dnl
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
##   移動元と移動先が重なる場合（例: a-a、a-b c-a）は移動先への復元を優先し、
##   移動先は保持される。特に自己への移動（a-a、a=a）は何もせず成功する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  移動先または削除対象が読み取り専用 (SX_EX_NOPERM)

define([|CLEANUP|], [|Q_src Q_arg|])dnl

sx_var_move() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_move "${@}" || return; return 0;; esac

	sx_var_is_chain "${@}" || return M_EX_USAGE

	__sx_var_is_copyable "${@}" || return M_EX_NOPERM

	Q_src=
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) M_STR_APPEND([|Q_src|], [|" ${Q_arg##*=}"|]);;
			*-*) M_STR_APPEND([|Q_src|], [|" ${Q_arg%%-*}"|]);;
			*) M_STR_APPEND([|Q_src|], [|" ${Q_arg}"|]);;
		esac
	done

	eval __sx_var_is_rw_all "${Q_src}" || {
		unset CLEANUP
		return M_EX_NOPERM
	}

	__sx_var_move "${@}"

	unset CLEANUP
}
|], [|var_move|])dnl

M_RENAME_QI([|dnl
### __sx_var_move - 変数を連鎖移動する（内部用）
##
## 使い方:
##   __sx_var_move [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_move の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_script|])dnl

__sx_var_move() {
	__sx_var_copy_script Q_script "${@}"

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) __sx_var_unset "${Q_arg##*=}";;
			*-*) __sx_var_unset "${Q_arg%%-*}";;
			*) __sx_var_unset "${Q_arg}";;
		esac
	done

	eval "${Q_script}"

	unset CLEANUP
}
|], [|var_move|])dnl

M_RENAME_Q([|dnl
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
## 注意:
##   内部関数は結果変数への代入時に事前 unset を行わないため、
##   sx 配列が格納された変数を結果変数として使う場合は、
##   事前に sx_var_unset を明示的に呼び出してから関数を呼び出すこと。
##   これを怠ると、古い配列要素（_len, _0, _1...）が残存する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  読み取り専用変数への操作失敗 (SX_EX_NOPERM)

define([|CLEANUP|], [|Q_arg Q_chk|])dnl

sx_var_set() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_set "${@}" || return; return 0;; esac

	Q_chk=

	for Q_arg in "${@}"; do
		sx_var_is_name "${Q_arg%%=*}" || {
			unset Q_arg Q_chk
			return M_EX_USAGE
		}

		M_STR_APPEND([|Q_chk|], [|" ${Q_arg%%=*}"|])
	done

	eval sx_var_is_rw_all "${Q_chk}" || {
		unset  Q_chk Q_arg
		return M_EX_NOPERM
	}

	unset  Q_chk Q_arg
	__sx_var_set "${@}"
}
|], [|var_set|])dnl

M_RENAME_QI([|dnl
### __sx_var_set - 変数に値を設定、または削除する（内部用）
##
## 使い方:
##   __sx_var_set [名前=値 | 名前 ...]
##
## 説明:
##   sx_var_set の内部実装。
##   引数チェックは行わない。
##
## 注意:
##   内部関数は結果変数への代入にこの関数を使わず、M_VAR_SET マクロ
##   （事前 unset を行わない eval による直接代入）を使用する。
##   そのため、sx 配列が格納された変数を結果変数として使う場合は、
##   事前に sx_var_unset を明示的に呼び出すこと。

define([|CLEANUP|], [|Q_arg Q_vn|])dnl

__sx_var_set() {
	for Q_arg in "${@}"; do
		Q_vn="${Q_arg%%=*}"
		__sx_var_unset "${Q_vn%%=*}"

		case "${Q_arg}" in *=*)
			eval "${Q_vn}="'"${Q_arg#*=}"'
		esac
	done

	unset CLEANUP
}
|], [|var_set|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg Q_chain|])dnl

sx_var_swap() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_swap "${@}" || return; return 0;; esac

	sx_var_is_chain "${@}" || return M_EX_USAGE

	Q_chain=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) M_STR_APPEND([|Q_chain|], [|"${Q_arg##*=}=${Q_arg} "|]);;
			*-*) M_STR_APPEND([|Q_chain|], [|"${Q_arg}-${Q_arg%%-*} "|]);;
		esac
	done

	eval __sx_var_is_copyable "${Q_chain}" || {
		unset CLEANUP
		return M_EX_NOPERM
	}

	__sx_var_swap "${@}"
	unset CLEANUP
}
|], [|var_swap|])dnl

M_RENAME_QI([|dnl
### __sx_var_swap - 変数を連鎖的にローテーションする（内部用）
##
## 使い方:
##   __sx_var_swap [連鎖式1 [連鎖式2 ...]]
##
## 説明:
##   sx_var_swap の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg Q_chain|])dnl

__sx_var_swap() {
	Q_chain=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*=*) M_STR_APPEND([|Q_chain|], [|"${Q_arg##*=}=${Q_arg} "|]);;
			*-*) M_STR_APPEND([|Q_chain|], [|"${Q_arg}-${Q_arg%%-*} "|]);;
		esac
	done

	eval __sx_var_copy "${Q_chain}"

	unset CLEANUP
}
|], [|var_swap|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw "${@}" || return M_EX_NOPERM

	__sx_var_touch "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_touch - 変数のリビジョン番号を更新する（内部用）
##
## 使い方:
##   __sx_var_touch 変数名1 [変数名2 ...]
##
## 説明:
##   指定された変数の値に含まれるリビジョン番号（末尾の : 以降）を
##   現在の SX_SYS_REV で更新し、SX_SYS_REV をインクリメントする。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_arg|])dnl

__sx_var_touch() {
	for Q_arg in "${@}"; do
		eval "${Q_arg}=\"\${${Q_arg}:+\"\${${Q_arg}%:*}\"}:\${SX_SYS_REV}\""
		M_NUM_INCRM1([|SX_SYS_REV|])
	done

	unset CLEANUP
}
|], [|var_touch|])dnl

### sx_var_ubind - バインド状態に従って値を割り当てる（クォートなし）
##
## 使い方:
##   sx_var_ubind 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_var_bind と同様に複数の値をバインド形式に従って割り当てる。
##   蓄積スロット（数値プレフィックス付き・最後の変数）への蓄積時に
##   値のクォートを行わない点のみが sx_var_bind と異なる。
##   代入スロット（名前:残り）への代入は sx_var_bind と同様に生の値となる。
##   結果変数名に空文字列を指定した場合は、残りのバインド形式を書き込まずに破棄する。
##   バインド先が枯渇し、未処理の値が残る場合は終了ステータス 1 を返し、
##   結果変数が空でない場合に限り残りのバインド形式（空文字列）が書き込まれる。
##   @name / N@name 形式の要素は sx 配列への分配先となる。
##   バインド形式は事前に sx_var_bind_init で初期化されている必要がある。
##   未初期化の状態で呼び出すと終了ステータス 65 を返す。
##   詳細は sx_var_is_bind_ready を参照。
##
## 終了ステータス:
##    0  割り当て成功 (SX_EX_OK)
##    1  バインド先がもうない（データがバインド先より多い）。結果変数が空でない場合に限り空文字列が書き込まれる
##   64  引数不正 (SX_EX_USAGE)
##   65  バインド先が割当て可能な状態にない (SX_EX_DATAERR)
##   77  結果変数名（空でない場合）またはバインド先が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_var_ubind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_ubind "${@}" || return; return 0;; esac

	# 結果変数名自体の妥当性と書き込み権限をチェック
	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	case "${1-}" in ?*)
		sx_var_is_name "${1-}" || return M_EX_USAGE

		__sx_var_is_rw "${1}" || return M_EX_NOPERM
	esac

	__sx_var_is_bind "${2-}" || return M_EX_USAGE

	__sx_var_is_bindable "${2-}" || return M_EX_NOPERM

	__sx_var_is_bind_ready "${2-}" || return M_EX_DATAERR

	__sx_var_ubind "${@}" || return
}

### __sx_var_ubind - バインド状態に従って値を割り当てる（クォートなし・内部用）
##
## 使い方:
##   __sx_var_ubind 結果変数名（空文字列可） バインド形式 [値1 [値2 ...]]
##
## 説明:
##   sx_var_ubind の内部実装。リスト蓄積時に値をクォートしない。
##   引数の検証を行わない。結果変数名が空文字列の場合は残りを破棄する。
##   バインド先が枯渇し、未処理の値が残る場合は終了ステータス 1 を返し、
##   結果変数が空でない場合に限り残りのバインド形式（枯渇時は空文字列）が書き込まれる。
##
## 終了ステータス:
##    0  割り当て成功
##    1  バインド先がもうない（データがバインド先より多い）。結果変数が空でない場合に限り空文字列が書き込まれる

__sx_var_ubind() {
	__sx_var_bind0 0 "${@}" || return
}

### sx_var_unexport - 変数のエクスポート属性を解除する
##
## 使い方:
##   sx_var_unexport 名前1 [名前2 ...]
##
## 説明:
##   指定された変数のエクスポート（export）属性を解除する。変数の値は保持される。
##   POSIX sh には export -n が存在しないため、値を一時保存した上で unset し、
##   再代入することで export 属性を除去する。
##   対象は通常の変数を想定する（sx 配列は対象外。配列要素の一括解除は行わない）。
##   すでに export されていない変数を指定しても成功する（何もしない）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  読み取り専用などの理由で解除できない変数が含まれる (SX_EX_NOPERM)
sx_var_unexport() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_var_unexport "${@}" || return; return 0;; esac

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw "${@}" || return M_EX_NOPERM

	__sx_var_unexport "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_unexport - 変数のエクスポート属性を解除する（内部用）
##
## 使い方:
##   __sx_var_unexport 名前1 [名前2 ...]
##
## 説明:
##   sx_var_unexport の内部実装。
##   引数チェックは行わない。値を保持したまま export 属性のみを除去する。

define([|CLEANUP|], [|Q_arg Q_tmp Q_set|])dnl

__sx_var_unexport() {
	for Q_arg in "${@}"; do
		eval "Q_tmp=\"\${${Q_arg}-}\" Q_set=\"\${${Q_arg}+X}\""
		unset -v "${Q_arg}"

		case "${Q_set}" in X)
			M_VAR_SET([|${Q_arg}|], [|${Q_tmp}|])
		esac
	done

	unset CLEANUP
}
|], [|var_unexport|])dnl

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

	sx_var_is_name "${@}" || return M_EX_USAGE

	__sx_var_is_rw_all "${@}" || return M_EX_NOPERM

	__sx_var_unset "${@}"
}

M_RENAME_QI([|dnl
### __sx_var_unset - 変数または配列を関連要素を含めて削除する（内部用）
##
## 使い方:
##   __sx_var_unset 名前1 [名前2 ...]
##
## 説明:
##   sx_var_unset の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_len Q_i|])dnl

__sx_var_unset() {
	while M_STR_NE([|"${#}"|], [|0|]); do
		if __sx_var_is_arr "${1}"; then
			eval "Q_len=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			Q_i=0
			while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
				set -- "${@}" "${1}_${Q_i}"
				M_NUM_INCR([|Q_i|])
			done
		fi

		unset -v "${1}"
		shift
	done

	unset CLEANUP
}
|], [|var_unset|])dnl

# ========================================
#  NUM (Numerical Operations)
# ========================================

## 型サフィックス (Type Suffixes)
##
##   数値演算関数は sx_num_<op>_<型> の形式で命名する。型サフィックスは以下:
##     int    符号付き整数 (signed integer)
##     nat0   非負整数 (natural number incl. 0)
##     nat1   正整数 (natural number excl. 0)
##     pint   正の整数 (positive int)
##     nint   負の整数 (negative int)
##     nnint  非負整数 (non-negative int)
##     npint  非正整数 (non-positive int)
##
##   型サフィックスに base を付加すると、第1引数で基数 (8, 10, 16) を
##   指定する形式になる（例: sx_num_is_int_base）。
##   型サフィックスに safe を付加すると、SX_CFG_NUM_RANGE で設定される
##   標準的な数値範囲、または安全上の制限（DoS 対策）に基づく検証を行う
##   形式になる（例: sx_num_is_int_safe）。

M_RENAME_Q([|dnl
### sx_num_add_int - 複数の符号付き整数を加算する
##
## 使い方:
##   sx_num_add_int 結果変数名 [数値1 [数値2 ...]]
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

define([|CLEANUP|], [|Q_res|])dnl

sx_num_add_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_add_int "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_int_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_add_int "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_add_int|])dnl

M_RENAME_QI([|dnl
### __sx_num_add_int - 複数の符号付き整数を加算する（内部用）
##
## 使い方:
##   __sx_num_add_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を加算する。まず正数と負数に分けてそれぞれ
##   __sx_num_add_nat0 で絶対値加算を行い、最後に絶対値を比較し
##   減算して符号を決定する。

define([|CLEANUP|], [|Q_res Q_pos Q_neg Q_pos_sum Q_neg_sum Q_arg Q_acc|])dnl

__sx_num_add_int() {
	Q_res="${1}"
	shift

	# Step 1: 正数と負数に分離
	Q_pos=
	Q_neg=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			-*) M_STR_APPEND([|Q_neg|], [|" ${Q_arg#-}"|]);;
			*)  M_STR_APPEND([|Q_pos|], [|" ${Q_arg#+}"|]);;
		esac
	done

	# Step 2: 正数の合計
	eval __sx_num_add_nat0 Q_pos_sum "${Q_pos}"

	# Step 3: 負数（絶対値）の合計
	eval __sx_num_add_nat0 Q_neg_sum "${Q_neg}"

	# Step 4: 絶対値を比較して最終結果を決定
	__sx_num_cmp_nat0 "${Q_pos_sum}" "${Q_neg_sum}" || case "${?}" in
		1)
			__sx_num_sub_nat0 Q_acc "${Q_neg_sum}" "${Q_pos_sum}"
			M_STR_PREPEND([|Q_acc|], [|-|])
			;;
		2) Q_acc=0;;
		3) __sx_num_sub_nat0 Q_acc "${Q_pos_sum}" "${Q_neg_sum}";;
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_acc}|])

	unset CLEANUP
}
|], [|num_add_int|])dnl

M_RENAME_Q([|dnl
### sx_num_add_nat0 - 複数の絶対値をチャンク加算する
##
## 使い方:
##   sx_num_add_nat0 結果変数名 [数値1 [数値2 ...]]
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

define([|CLEANUP|], [|Q_res|])dnl

sx_num_add_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_add_nat0 "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_nat0_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_add_nat0 "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_add_nat0|])dnl

M_RENAME_QI([|dnl
### __sx_num_add_nat0 - 複数の絶対値をチャンク加算する（内部用）
##
## 使い方:
##   __sx_num_add_nat0 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を加算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   逐次方式でアキュムレータに各数値を順次加算する。

define([|CLEANUP|], [|Q_res Q_carry Q_out Q_rem1 Q_rem2 Q_ch1 Q_ch2 Q_tmp|])dnl

__sx_num_add_nat0() {
	Q_res="${1}"
	Q_rem1="${2-0}"

	shift "$((1 + 0${2+1}))"

	for Q_rem2 in "${@}"; do
		case "${Q_rem1}:${Q_rem2}" in
			*:0) continue;;
			${SX_SYS_NUM_QM}?*:* | *:${SX_SYS_NUM_QM}?*) ;;
			*)
				M_NUM_INCR([|Q_rem1|], [|Q_rem2|])
				continue
				;;
		esac

		# (2) 右端→左端 チャンク処理
		Q_carry=0
		Q_out=

		while
			# rem1 からチャンク抽出
			case "${Q_rem1}" in
				${SX_SYS_NUM_QM}?*)
					Q_tmp="${Q_rem1%${SX_SYS_NUM_QM}}"
					Q_ch1="${Q_rem1#"${Q_tmp}"}"
					Q_rem1="${Q_tmp}"

					case "${Q_ch1}" in 0*)
						Q_ch1=$((1${Q_ch1} - 1${SX_SYS_NUM_ZR}))
					esac
					;;
				*)
					Q_ch1="${Q_rem1}"
					Q_rem1=
					;;
			esac

			# rem2 からチャンク抽出
			case "${Q_rem2}" in
				${SX_SYS_NUM_QM}?*)
					Q_tmp="${Q_rem2%${SX_SYS_NUM_QM}}"
					Q_ch2="${Q_rem2#"${Q_tmp}"}"
					Q_rem2="${Q_tmp}"

					case "${Q_ch2}" in 0*)
						Q_ch2=$((1${Q_ch2} - 1${SX_SYS_NUM_ZR}))
					esac
					;;
				*)
					Q_ch2="${Q_rem2}"
					Q_rem2=
					;;
			esac

			Q_tmp=$(( Q_ch1 + Q_ch2 + Q_carry ))
			Q_carry=$((1${SX_SYS_NUM_ZR} <= Q_tmp))

			case "${Q_carry}:${Q_rem1}:${Q_rem2}" in
				?::) Q_rem1="${Q_tmp}${Q_out}" && break;;
				0:?*: | 0::?*)
					case "${Q_tmp}" in
						${SX_SYS_NUM_QM}) M_STR_APPEND([|Q_rem1|], [|"${Q_rem2}${Q_tmp}${Q_out}"|]);;
						*)
							# ゼロ埋めして前置（片方のチャンクが先頭ゼロ除去で短くなった場合の桁揃え）
							M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
							M_STR_APPEND([|Q_rem1|], [|"${Q_rem2}${Q_tmp#1}${Q_out}"|])
							;;
						esac

						break
						;;
				0:*)
					case "${Q_tmp}" in
						${SX_SYS_NUM_QM}) M_STR_PREPEND([|Q_out|], [|"${Q_tmp}"|]);;
						*)
							# ゼロ埋めして前置
							M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
							M_STR_PREPEND([|Q_out|], [|"${Q_tmp#1}"|])
							;;
					esac
					;;
				*) M_STR_PREPEND([|Q_out|], [|"${Q_tmp#1}"|]);;
			esac

			continue
		do :; done
	done

	M_VAR_SET([|${Q_res}|], [|${Q_rem1}|])

	unset CLEANUP
}
|], [|num_add_nat0|])dnl

M_RENAME_Q([|dnl
### sx_num_add1_nat0 - 非負整数に1を加算する
##
## 使い方:
##   sx_num_add1_nat0 結果変数名 数値
##
## 説明:
##   符号なし10進整数に1を加算する。
##   引数の検証を行い、符号なし整数でない場合はエラーとする。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

sx_num_add1_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_add1_nat0 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 "${2-}" || return M_EX_USAGE

	__sx_num_add1_nat0 "$1" "$2"
}
|], [|num_add1_nat0|])dnl

M_RENAME_QI([|dnl
### __sx_num_add1_nat0 - 非負整数に1を加算する（内部用）
##
## 使い方:
##   __sx_num_add1_nat0 結果変数名 数値
##
## 説明:
##   sx_num_add1_nat0 の内部実装。引数の検証を行わない。
##   SX_CFG_NUM_RANGE に応じて、ネイティブ算術または __sx_num_add_nat0 に委譲する。

__sx_num_add1_nat0() {
	case "${SX_CFG_NUM_RANGE}" in
		32)
			case "$2" in
				?????????*) __sx_num_add_nat0 "$1" "$2" 1;;
				*) : "$(($1 = $2 + 1))";;
			esac
			;;
		64)
			case "$2" in
				??????????????????*) __sx_num_add_nat0 "$1" "$2" 1;;
				*) : "$(($1 = $2 + 1))";;
			esac
			;;
		128)
			case "$2" in
				??????????????????????????????????????*) __sx_num_add_nat0 "$1" "$2" 1;;
				*) : "$(($1 = $2 + 1))";;
			esac
			;;
	esac
}
|], [|num_add1_nat0|])dnl

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
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_cmp_arith() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_cmp_arith "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_int_safe "${1-}" "${2-}" || return M_EX_USAGE

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

	sx_num_is_fixed "${1-}" "${2-}" || return M_EX_USAGE

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

M_RENAME_QI([|dnl
### __sx_num_cmp_fixed_frac - 小数部を左から比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺

define([|CLEANUP|], [||])dnl

__sx_num_cmp_fixed_frac() {
	# 接頭辞チェック（正規化により、長い方が必ず大きい）
	# 冒頭で行うことで、長い小数部の延長比較をループなしで高速に処理する
	# 完全に一致する場合は即座に終了 (EQ)
	case "${1}" in
		"${2}") return 2;;
		"${2}"*) return 3;;
	esac

	case "${2}" in "${1}"*)
		return 1
	esac

	# 両方の文字列が窓幅以上の間、チャンクごとに比較
	while M_STR_MATCH([|"${1}"|], [|${SX_SYS_NUM_QM}?*|]) && M_STR_MATCH([|"${2}"|], [|${SX_SYS_NUM_QM}?*|]); do
		set -- "${1#${SX_SYS_NUM_QM}}" "${2#${SX_SYS_NUM_QM}}" "${1}" "${2}"
		__sx_num_cmp_arith_digit "${3%"${1}"}" "${4%"${2}"}" || case "${?}" in
			1 | 3) return "${?}";;
		esac
	done

	# 接頭辞の関係にない（＝どこかの桁で異なる）残りの部分をパディングして最後の比較
	set -- "${1}${SX_SYS_NUM_ZR}" "${2}${SX_SYS_NUM_ZR}"

	__sx_num_cmp_arith_digit "${1%"${1#${SX_SYS_NUM_QM}}"}" "${2%"${2#${SX_SYS_NUM_QM}}"}" || return "${?}"
}
|], [|num_cmp_fixed_frac|])dnl

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

	sx_num_is_float "${1-}" "${2-}" || return M_EX_USAGE

	__sx_num_cmp_float "${@}"
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_a Q_b|])dnl

__sx_num_cmp_float() {
	__sx_num_norm Q_a:Q_b "${1}" "${2}"
	set -- "${Q_a}" "${Q_b}"
	unset CLEANUP

	__sx_num_cmp_fixed "${@}" || return
}
|], [|num_cmp_float|])dnl

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

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG
	__sx_num_is_nat0_base 10 "${1-}" "${2-}" || return M_EX_USAGE

	__sx_num_cmp_nat0 "${1}" "${2}" || return
}

M_RENAME_QI([|dnl
### __sx_num_cmp_nat0 - 符号なし10進整数文字列を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺

define([|CLEANUP|], [|Q_l Q_r Q_qm|])dnl

__sx_num_cmp_nat0() {
	case "${1}" in "${2}")
		return 2
	esac

	Q_l="${#1}"
	Q_r="${#2}"

	case "${Q_l}" in "${Q_r}")
		while M_STR_MATCH([|"${1}"|], [|${SX_SYS_NUM_QM}?*|]); do
			set -- "${1#${SX_SYS_NUM_QM}}" "${2#${SX_SYS_NUM_QM}}" "${1}" "${2}"
			__sx_num_cmp_arith "1${3%"${1}"}" "1${4%"${2}"}" || case "${?}" in 1 | 3)
				set -- "${?}"
				unset CLEANUP
				return "${1}"
			esac
		done

		unset CLEANUP

	__sx_num_cmp_arith "1${1}" "1${2}" || return "${?}"
	esac

	if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_l}" "${Q_r}"; then
		__sx_num_cmp_arith "${Q_l}" "${Q_r}"
	else
		__sx_num_cmp_nat0 "${Q_l}" "${Q_r}"
	fi || {
		set -- "${?}"
		unset CLEANUP
		return "${1}"
	}
}
|], [|num_cmp_nat0|])dnl

M_RENAME_Q([|dnl
### sx_num_div_int - 符号付き整数の除算で実数商（整数商 + 小数部）を求める
##
## 使い方:
##   sx_num_div_int 結果変数名 小数桁数 被除数 [除数1 [除数2 ...]]
##
## 説明:
##   符号付き10進整数の除算を行い、実数商（整数商 + 小数部）を求める。
##   すべての除数を乗算した値を単一の除数として扱い、被除数をその除数で除算する。
##   小数部は小数桁数（最大桁数）までを floor（切り捨て）で求め、末尾の 0 は除去される。
##   小数部が 0 になる場合は実数商 = 整数商となる。
##   （例: d 2 -100 3 → d=-33.33 / d 2 5 -10 → d=-0.5 / d 3 -100 -2 5 → d=10）
##   被除数は任意の符号付き整数、各除数は 0 以外の符号付き整数、小数桁数は 0 以上の自然数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   小数桁数・被除数・除数は省略可能で、省略した場合はそれぞれ 0、0、1 として扱われる
##   （小数桁数省略時は実数商 = 整数商、除数省略時は被除数がそのまま実数商）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res Q_dp Q_u|])dnl

sx_num_div_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_div_int "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_nat0_safe ${2:+"${2}"} && __sx_num_is_int_base 10 ${3:+"${3}"} || return M_EX_USAGE

	Q_res="${1}"
	Q_dp="${2:-0}"
	Q_u="${3:-0}"
	shift "$((0${2+1} + 0${3+1} + 1))"

	__sx_num_is_nzint_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_div_int "${Q_res}" "${Q_dp}" "${Q_u}" "${@}"
	unset CLEANUP
}
|], [|num_div_int|])dnl

M_RENAME_QI([|dnl
### __sx_num_div_int - 符号付き整数の除算で実数商（整数商 + 小数部）を求める（内部用）
##
## 使い方:
##   __sx_num_div_int 結果変数名 小数桁数 被除数 [除数1 [除数2 ...]]
##
## 説明:
##   sx_num_div_int の内部実装。引数チェックは行わない。
##   前提: 小数桁数は 0 以上の自然数、被除数は任意の符号付き整数、
##   すべての除数は 0 以外の符号付き整数であること。

define([|CLEANUP|], [|Q_res Q_dp Q_u Q_den Q_q|])dnl

__sx_num_div_int() {
	Q_res="${1}"
	Q_dp="${2:-0}"
	Q_u="${3:-0}"
	shift "$((0${1+1} + 0${2+1} + 0${3+1}))"

	case "${Q_u}" in 0 | +0 | -0)
		M_VAR_SET([|${Q_res}|], [|0|])
		unset CLEANUP
		return M_EX_OK
	esac

	__sx_num_mul_int Q_den "${@}"

	__sx_num_div_nat0 Q_q "${Q_dp}" "${Q_u#[+-]}" "${Q_den#[+-]}"

	case "${Q_u}:${Q_den}:${Q_q}" in -*:[!-]*:*[!0]* | [!-]*:-*:*[!0]*)
		M_STR_PREPEND([|Q_q|], [|-|])
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_q}|])
	unset CLEANUP
}
|], [|num_div_int|])dnl

M_RENAME_Q([|dnl
### sx_num_div_nat0 - 絶対値の除算で実数商（整数商 + 小数部）を求める
##
## 使い方:
##   sx_num_div_nat0 結果変数名 小数桁数 被除数 [除数1 [除数2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値の除算を行い、実数商（整数商 + 小数部）を求める。
##   すべての除数を乗算した値を単一の除数として扱い、被除数をその除数で除算する。
##   小数部は小数桁数（最大桁数）までを floor（切り捨て）で求め、末尾の 0 は除去される。
##   小数部が 0 になる場合は実数商 = 整数商となる。
##   （例: d 2 100 3 → d=33.33 / d 2 5 10 → d=0.5 / d 3 100 2 5 → d=10）
##   被除数は 0 以上の自然数、各除数は 1 以上の自然数、小数桁数は 0 以上の自然数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   小数桁数・被除数・除数は省略可能で、省略した場合はそれぞれ 0、0、1 として扱われる
##   （小数桁数省略時は実数商 = 整数商、除数省略時は被除数がそのまま実数商）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res Q_dp Q_u|])dnl

sx_num_div_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_div_nat0 "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_nat0_safe ${2:+"${2}"} && __sx_num_is_nat0_base 10 ${3:+"${3}"} || return M_EX_USAGE

	Q_res="${1}"
	Q_dp="${2:-0}"
	Q_u="${3:-0}"
	shift "$((0${2+1} + 0${3+1} + 1))"

	__sx_num_is_nat1_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_div_nat0 "${Q_res}" "${Q_dp}" "${Q_u}" "${@}"
	unset CLEANUP
}
|], [|num_div_nat0|])dnl

M_RENAME_QI([|dnl
### __sx_num_div_nat0 - 絶対値の除算で実数商（整数商 + 小数部）を求める（内部用）
##
## 使い方:
##   __sx_num_div_nat0 結果変数名 小数桁数 被除数 [除数1 [除数2 ...]]
##
## 説明:
##   sx_num_div_nat0 の内部実装。引数チェックは行わない。
##   前提: 小数桁数は 0 以上の自然数、被除数は 0 以上の自然数、
##   すべての除数は 1 以上の自然数であること。
##
##   実行フロー（ステップ 1〜3）:
##   1) すべての除数を __sx_num_mul_nat0 で乗算して単一の除数 den を求める
##      （除数が無い場合は 1）。
##   2) __sx_num_divmod_nat0 で整数商 q と余剰 r を求める。
##   3) 小数桁数 dp が 1 以上で余剰 r が 0 でない場合、小数部 dec を
##      floor(余剰 × 10^dp ÷ den) の商として dp 桁にゼロ埋めした文字列で求め、
##      末尾の 0 を除去する。dec が空（小数が 0）になれば整数商 q をそのまま返す。
##      ゼロ埋めの '?'×桁数 / "0"×桁数 は SX_NUM_QM / SX_NUM_ZR 定数（1〜37 桁）から参照し、
##      37 桁を超える場合のみ __sx_str_rep で生成する。

define([|CLEANUP|], [|Q_res Q_dp Q_u Q_den Q_q Q_r Q_dec Q_zr Q_qm|])dnl

__sx_num_div_nat0() {
	# ステップ 1: 引数の取得（結果変数名、小数桁数 dp、被除数 u、除数群）
	Q_res="${1}"
	Q_dp="${2:-0}"
	Q_u="${3:-0}"
	shift 3

	case "${Q_u}" in 0 | +0 | -0)
		M_VAR_SET([|${Q_res}|], [|0|])
		unset CLEANUP
		return M_EX_OK
	esac

	# ステップ 2: すべての除数を乗算して単一の除数にする（除数が無い場合は 1）
	__sx_num_mul_nat0 Q_den "${@}"

	# ステップ 3: 整数商と余剰を求める
	__sx_num_divmod_nat0 "Q_q:Q_r:" "${Q_u}" "${Q_den}"

	# ステップ 4: 小数部の導出（dp が 1 以上かつ余剰が 0 でない場合のみ）
	#   dec = floor(余剰 × 10^dp ÷ den) を dp 桁にゼロ埋めした文字列（末尾 0 は除去）
	Q_dec=

	case "${Q_dp}${Q_r}" in [!0]*[!0]*)
		# "0"×dp は SX_NUM_ZR 定数（1〜37 桁）から参照し、超過時のみ str_rep で生成する
		__sx_str_zr Q_zr "${Q_dp}"

		# 小数部 = 余剰 × 10^dp ÷ den の整数商（この除算の余りは不要）
		__sx_num_divmod_nat0 "Q_dec:" "${Q_r}${Q_zr}" "${Q_den}"

		# dec が dp 桁未満の場合のみ先頭をゼロ埋めする（len == dp なら定数参照を丸ごとスキップ）
		if M_STR_NE([|"${#Q_dec}"|], [|"${Q_dp}"|]); then
			# 前置 "0"×dp から剥ぎ取る '?'×len(dec) は SX_NUM_QM 定数（1〜37 桁）から参照する
			__sx_str_qm Q_qm "${#Q_dec}"

			# "0"×dp を前置して '?'×len(dec) を剥ぎ、末尾 dp 桁だけを採用する
			# （dec は高々 dp 桁のため、桁不足のときのみこのパスに来る）
			M_STR_PREPEND([|Q_dec|], [|"${Q_zr}"|])

			# '?'×len(dec) は ? がパターン一致として働く必要があるため、
			# 内側の展開は意図的にクォートしない（クォートすると ? がリテラル化して剥ぎ取りが失敗する）
			Q_dec="${Q_dec#${Q_qm}}"
		fi

		# 小数部の末尾 0 を除去する
		case "${Q_dec}" in *0)
			Q_dec="M_STR_RTRIM([|Q_dec|], [|[!0]|])";;
		esac
	esac

	# 小数部が空（小数が 0）なら "." を付けず整数商のまま
	case "${Q_dec}" in ?*)
		M_STR_APPEND([|Q_q|], [|".${Q_dec}"|])
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_q}|])
	unset CLEANUP
}
|], [|num_div_nat0|])dnl

### sx_num_divmod_int - 符号付き整数の除算で整数商と余剰を同時に求める（Truncated）
##
## 使い方:
##   sx_num_divmod_int バインド形式 被除数 [除数]
##
## 説明:
##   符号付き10進整数の除算（Truncated 規約: 商はゼロ方向へ丸め、
##   余剰は被除数と同じ符号を持つ）を行い、整数商と余剰を同時に求める。
##   第一引数は商・余剰の割り当て先を指定する分配代入バインド形式（例: "q:r:"）。
##   被除数は任意の符号付き整数、除数は 0 以外の符号付き整数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_divmod_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divmod_int "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${2:+"${2}"} && __sx_num_is_nzint_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_num_divmod_int "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_divmod_int - 符号付き整数の除算で整数商と余剰を同時に求める（内部用）
##
## 使い方:
##   __sx_num_divmod_int バインド形式 被除数 [除数]
##
## 説明:
##   sx_num_divmod_int の内部実装。引数チェックは行わない。
##   Truncated 規約: 商はゼロ方向へ丸め、余剰は被除数と同じ符号を持つ。
##   絶対値どうしの除算（q0, r0）の後に符号のみを適用する。
##   q = sign(u)×sign(v)×q0、r = sign(u)×r0 であり、
##   q0 や r0 が 0 のときは "-0" を作らない。

define([|CLEANUP|], [|Q_bind Q_q Q_r Q_us Q_vs|])dnl

__sx_num_divmod_int() {
	__sx_var_bind_init "${1}"
	set -- "${1}" "${2:-0}" "${3:-1}"
	Q_us=0
	Q_vs=0

	case "${2}" in -*)
		Q_us=1
	esac

	case "${3}" in -*)
		Q_vs=1
	esac

	__sx_num_divmod_nat0 'Q_q:Q_r:' "${2#[+-]}" "${3#[+-]}"

	case "$((Q_us ^ Q_vs))${Q_q}" in 1[!0]*)
		M_STR_PREPEND([|Q_q|], [|-|])
	esac

	__sx_var_ubind Q_bind "${1}" "${Q_q}" || {
		unset CLEANUP
		return M_EX_OK
	}

	case "${Q_us}${Q_r}" in 1[!0]*)
		M_STR_PREPEND([|Q_r|], [|-|])
	esac

	__sx_var_ubind Q_bind "${Q_bind}" "${Q_r}" || :

	unset CLEANUP
}
|], [|num_divmod_int|])dnl

### sx_num_divmod_nat0 - 絶対値の除算で整数商と余剰を同時に求める
##
## 使い方:
##   sx_num_divmod_nat0 バインド形式 被除数 [除数]
##
## 説明:
##   符号なし10進整数の絶対値の除算を行い、整数商と余剰を同時に求める。
##   第一引数は商・余剰の割り当て先を指定する分配代入バインド形式（例: "q:r:"）。
##   第1セグメントには整数商、第2セグメントには余剰が格納される。
##   実数商（整数商 + 小数部）を求める場合は sx_num_div_nat0 を使用する。
##   被除数は 0 以上の自然数、除数は 1 以上の自然数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_divmod_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_divmod_nat0 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_base 10 ${2:+"${2}"} && __sx_num_is_nat1_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_num_divmod_nat0 "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_divmod_nat0 - 絶対値の除算で整数商と余剰を同時に求める（内部用）
##
## 使い方:
##   __sx_num_divmod_nat0 バインド形式 被除数 [除数]
##
## 説明:
##   符号なし10進整数の絶対値の除算を行う。
##   第一引数は商・余剰の割り当て先を指定する分配代入バインド形式（例: "q:r:"）。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   除数が 0 でないことが保証されていること。
##   被除数・除数は省略時、それぞれ 0、1 として扱われる。
##
##   アルゴリズム: 語サイズ c = WLEN/2 桁で語分割する融合 Knuth D 法。
##   語の並びは常に「最上位語が先頭」で、v_1 が最上位語、v_n が最下位語。
##   u は先頭にゼロ語 u_1 = 0 を 1 語追加して合計 K 語で持ち、実データは u_2..u_K
##   （u_1 は主ループの最初の窓が参照するために確保するセンチネル語）。
##
##   実行フロー（ステップ 1〜9）:
##   1) 引数の取得（商・余剰の結果変数名、被除数 u、除数 v）。
##   2) 高速パス 1〜3: 自明なケースを確定する。
##      v = 1 → 商 = u、余り = 0 ／ u = v → 商 = 1、余り = 0
##      u < v → 商 = 0、余り = u（同桁数は最上位桁から 1 桁ずつ比較する）。
##   3) 語サイズ c の決定（c = WLEN/2。語積 10^(2c) は RANGE の算術幅に収まる）。
##   4) 末尾ゼロ分解: v = m × 10^k に分解し、u も 10^k で縮小する
##      （商は不変、余りは最後に u の下位 k 桁を復元する）。
##   5) 高速パス 4: 被除数全体が RANGE の算術幅（WLEN 桁）以内なら
##      ネイティブ除算で確定する。
##   6) 高速パス 5: 除数が (WLEN-1)*9/10 桁以内なら語幅 c = WLEN - len(v)（約 WLEN/10 + 1）の
##      語単位ネイティブ筆算で O(語数) に確定する。
##   7) 一般パス: 融合 Knuth D 法（u > v、u は 19 桁以上、v は 2 語以上）。
##      7.1 正規化: u、v を 10^d 倍して v の先頭語をちょうど c 桁に揃える。
##      7.2 語分割: v を n 語（v_1..v_n）、u を K 語に分解する。u 語は変数ではなく
##          位置パラメータ上で保持する（MS-first: $1 = u_1 = センチネル 0、$2..$# = u_2..u_K）。
##          （7.1 の v 左切り出しと正規化は 1 ループで同時に行い、u も右剥ぎ 1 ループで
##          語の中身を取りながら分割する。v の正規化は最下位語 v_n への 0^d 付加のみ）。
##      7.3 主ループ: 窓（$1..$(n+1) = u_{W-n}..u_W）を 1 語ずつ左へずらしながら商を 1 語ずつ確定する。
##          D2 商の見積り → D3 精緻化 → D4 融合 multiply-subtract → D5 加算復帰。
##          各反復末尾で shift n+1 → set -- ${new_} "$@" → shift 1 により窓を更新する。
##      7.4 余り抽出: ループ終了後に位置パラメータへ残る末尾 n 語（u_{K-n+1}..u_K）を連結する。
##      7.5 逆正規化: 余りの末尾 d 桁を除去して 10^d 倍を戻す。
##   8) 商・余剰を結果変数に格納し、内部変数を全て解放する。
##   ネイティブ演算の語積は必ず qhat*v_j < b^2 = 10^(2c) に収まり、
##   c = WLEN/2 より 10^(2c) は SX_CFG_NUM_RANGE の算術幅内に収まる。

define([|CLEANUP|], [|Q_tmp Q_bind Q_u Q_v Q_c Q_b Q_qm Q_zr Q_d Q_qmd Q_n Q_chunk Q_q Q_r Q_t Q_top2 Q_qhat Q_rhat Q_uw Q_p Q_carry Q_ck Q_ut Q_new Q_zv Q_btail Q_vstr Q_v1 Q_v2|])dnl

__sx_num_divmod_nat0() {
	# ステップ 1: 引数の取得（バインド形式と、被除数 u・除数 v の値）
	#   q_/r_ は直前のフレーム（再帰呼び出し元）から値が残っている場合があるため、
	#   計算前に必ずクリアする（6505 の分岐が q_ の残存値に誤導されるのを防ぐ）。
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_u="${2:-0}"
	Q_v="${3:-1}"
	Q_q=
	Q_r=

	# ステップ 2: 高速パス 1〜3（自明なケースを即座に確定する）
	#   高速パス 1: 除数が 1 なら商 = 被除数、余り = 0

	if M_STR_EQ([|"${Q_v}"|], [|1|]); then
		Q_q="${Q_u}"
		Q_r=0

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}
	elif
		# 高速パス 3: 被除数 < 除数なら商 = 0、余り = 被除数
		__sx_num_cmp_nat0 "${Q_u}" "${Q_v}" || case "${?}" in
			1) Q_q=0 Q_r="${Q_u}";;
			2) Q_q=1 Q_r=0;;
			*) ! :
		esac
	then
		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}
	else
		# ステップ 4: 末尾ゼロ分解（v = m × 10^k に分解して両者を 10^k で縮小する）
		#   数式: q = (u ÷ 10^k) ÷ m、r = ((u ÷ 10^k) mod m) × 10^k + (u mod 10^k)
		#   商は変化せず、余りには縮小で取り除いた u の下位 k 桁（btail）を最後に復元する。
		#   例: 1234500 ÷ 1200 → m = 12、k = 2、12345 ÷ 12 = 商 1028 余り 9
		#      → 余り = 9 × 100 + 00 = 900（商は縮小の影響を受けない）
		#   適用条件:
		#     kz > WLEN（末尾ゼロが 1 語幅を超える）場合のみ縮小する。
		#     kz は fit_dec によりネイティブ演算の桁数上限に制限される。
		Q_btail=

		case "${Q_v}" in *0${SX_SYS_NUM_ZR})
			Q_zv="${Q_v##*[!0]}"
			Q_tmp="${#Q_zv}"

			if __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_tmp}"; then
				__sx_str_qm Q_qm "${Q_tmp}"

				Q_tmp="${Q_u%${Q_qm}}"
				Q_btail="${Q_u#"${Q_tmp}"}"
				Q_v="${Q_v%"${Q_zv}"}"
				Q_u="${Q_tmp}"
			fi
		esac
	fi

	if M_STR_NE([|"${Q_q-}"|], [|''|]); then
		:
	# ステップ 5: 高速パス 4 — 被除数全体がネイティブ除算で確定できる場合
	elif __sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_u}"; then
		Q_q=$((Q_u / Q_v))

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}

		Q_r="$((Q_u % Q_v))${Q_btail}"

		# 末尾ゼロ分解で縮小した被除数の下位 k 桁（btail）を余りに復元する
		case "${Q_r}" in 0*)
			Q_r="M_STR_LTRIM([|Q_r|], [|[!0]|])"
		esac
	elif
		# ステップ 6: 高速パス 5 — 除数が (WLEN-1)*9/10 桁以内なら語単位のネイティブ筆算
		#   語幅 c = WLEN - len(v) は約 WLEN/10 + 1 以上に保たれる。c が小さいと反復回数と
		#   商文字列の連結コスト（O(len(q)^2)）が増え、被除数が長い場合は Knuth D 法に
		#   逆転される（実測では c = 2 で ulen ~ 500 付近から逆転）ため安全マージンを確保する。
		__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_v}" &&
		M_NUM_LE([|${#Q_v}|], [|(SX_SYS_NUM_WLEN - 1) * 9 / 10|])
	then
		# v の桁数 s に応じて語幅を c = WLEN - s へ拡大する。
		# 余り r は常に r < v なので、1 反復で取る u の桁を s のぶんだけ増やしても
		# nv = r * 10^c + chunk < 10^WLEN が保たれ、ネイティブ演算に収まる。
		Q_q=
		Q_r=0
		Q_c=$((SX_SYS_NUM_WLEN - ${#Q_v}))

		eval "Q_qm=\"\${SX_NUM_QM_${Q_c}}\" Q_b=\"1\${SX_NUM_ZR_${Q_c}}\""

		# 筆算の1語分: 前語までの余りを基数倍して次の語を結合し、ネイティブ除算で商1語を確定する
		while
			case "${Q_u}" in
				'') break;;
				${Q_qm}?*)
					Q_tmp="${Q_u#${Q_qm}}"
					Q_chunk="${Q_u%"${Q_tmp}"}"
					Q_u="${Q_tmp}"
					;;
				*)
					Q_c="${#Q_u}"
					eval "Q_qm=\"\${SX_NUM_QM_${Q_c}}\" Q_b=\"1\${SX_NUM_ZR_${Q_c}}\""
					Q_chunk="${Q_u}"
					Q_u=
					;;
			esac

			case "${Q_chunk}" in
				0*[1-9]*) Q_chunk=$((1${Q_chunk} - Q_b));;
				0*)
					case "${Q_r}" in 0)
						M_STR_APPEND([|Q_q|], [|"${Q_b#1}"|])
						continue
					esac

					Q_chunk=0
					;;
			esac

			# chunk を nv（r * 10^c + chunk）として再利用する
			M_NUM_INCR([|Q_chunk|], [|Q_r * Q_b|])
			Q_r=$((Q_chunk % Q_v))
				# 商1語がちょうど c 桁ならゼロ埋め・切り出しを省略し、それ以外は c 桁に整形する
			Q_tmp=$((Q_chunk / Q_v))

			case "${Q_tmp}" in
				${Q_qm}) M_STR_APPEND([|Q_q|], [|"${Q_tmp}"|]);;
				*)
					M_NUM_INCR([|Q_tmp|], [|Q_b|])
					M_STR_APPEND([|Q_q|], [|"${Q_tmp#1}"|])
					;;
			esac

			continue
		do :; done

		case "${Q_q}" in 0*)
			Q_q="M_STR_LTRIM([|Q_q|], [|[!0]|])"
		esac

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}

			# 末尾ゼロ分解で縮小した被除数の下位 k 桁（btail）を余りに復元する
			M_STR_APPEND([|Q_r|], [|"${Q_btail}"|])

			case "${Q_r}" in 0*)
				Q_r="M_STR_LTRIM([|Q_r|], [|[!0]|])";;
			esac
	else
		# 語サイズ c の決定
		Q_c=$((SX_SYS_NUM_WLEN / 2))
		eval "Q_qm=\"\${SX_NUM_QM_${Q_c}}\" Q_zr=\"\${SX_NUM_ZR_${Q_c}}\""
		Q_b="1${Q_zr}"
		# ステップ 7: 一般パス — 融合 Knuth D 法（u > v、u は 19 桁以上、v は 2 語以上）
		# ステップ 7.1: 正規化 — u・v を 10^d 倍し、v の先頭語をちょうど c 桁に揃える
		#   d = c - s（s は v の先頭語の桁数、s = (len(v) mod c) の剰余。s がちょうど c なら d = 0）
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
		#   s と n は v の左切り出し（先頭から c 文字ずつ除去して数える）で同時に求まる。
		#   切出しチャンクは語境界に一致する（右剥ぎのチャンクは (c-s) 文字の位相ずれがあり語にならない）。
		#   残余（高々 c 桁）が最下位語 v_n で、先頭語の桁数 s = ${#残余} から
		#   正規化量 d = c - s を確定し、v_n に 0^d を末尾付加して正規化する。
		#   文字列の全長を算術式に入れず、残余は高々 c 桁なので ${#残余} のみ算術に使う。
		#   v_ は分割中に消費される（分割後は使用しない）。
		Q_vstr=
		Q_n=1
		while
			case "${Q_v}" in
				${Q_qm}?*)
					Q_tmp="${Q_v#${Q_qm}}"
					Q_chunk="${Q_v%"${Q_tmp}"}"
					Q_v="${Q_tmp}"
					;;
				*)
					# 残余が 1..c 文字 = 最下位語 v_n。ここで s → d が確定する
					# （残余がちょうど c 文字のときもこの分岐に入り d = 0 になる）。
					# 残余は v_ に残っている（chunk_ は直前の c 文字チャンクのため使用しない）。
					Q_d=$((Q_c - ${#Q_v}))

					case "${Q_d}" in [!0]*)
						eval "Q_tmp=\"\${SX_NUM_ZR_${Q_d}}\" Q_qmd=\"\${SX_NUM_QM_${Q_d}}\""
						M_STR_APPEND([|Q_v|], [|"${Q_tmp}"|])
						M_STR_APPEND([|Q_u|], [|"${Q_tmp}"|])
					esac

					Q_chunk="${Q_v}"
					Q_v=
					;;
			esac

			case "${Q_chunk}" in 0*)
				Q_chunk=$((1${Q_chunk} - Q_b))
			esac

			M_STR_PREPEND([|Q_vstr|], [|"${Q_chunk} \"\${${Q_n}}\" "|])

			case "${Q_n}" in
				1) Q_v1="${Q_chunk}";;
				2) Q_v2="${Q_chunk}";;
			esac

			case "${Q_v}" in '')
				break
			esac

			M_NUM_INCRM1([|Q_n|])

			continue
		do :; done

		# ステップ 7.2 の u 側: u' を K 語に分割する。語は変数ではなく位置パラメータ上で保持する
		# （MS-first: $1 = u_1 = センチネル 0、$2..$# = u_2..u_K の語値。主ループの窓を
		# $1..$(n+1) 固定で扱えるようにした D1 の改良。u_1 は主ループの最初の窓（D2）が
		# 参照するために先頭に確保するゼロ語）。
		# up_（= u_ + 0^d）の右剥ぎチャンクは語境界ちょうどで語になる（正規化ゼロは末尾に付加され、
		# パディング padz は先頭にのみ挿入されるため。v と違い位相ずれが起きない）。
		# 右剥ぎチャンクは下位の語から得られるため、位置パラメータへの前置（set -- "${tail_}" "${@}"）
		# により逆順（MS-first）に整列する。ループ前に位置パラメータを空クリア（set --）してから
		# 蓄積を開始する（関数の元引数が語列の末尾に混入しないようにするため）。
		# 残余（高々 c 桁 = 先頭語 u_2 の元）はそのまま末尾に連結する（正規入力では先頭桁が非ゼロで
		# ありゼロストリップ不要。ゼロストリップは分割済みチャンクに対してのみ行う）。
		#   up_ は分割中に消費される（分割後は使用しない）。
		set --

		while
			case "${Q_u}" in
				'') break;;
				${Q_qm}?*)
					Q_tmp="${Q_u%${Q_qm}}"
					Q_chunk="${Q_u#${Q_tmp}}"
					Q_u="${Q_tmp}"

					case "${Q_chunk}" in 0*)
						Q_chunk=$((1${Q_chunk} - Q_b))
					esac
					;;
				*)
					Q_chunk="${Q_u}"
					Q_u=
					;;
			esac

			set -- "${Q_chunk}" "${@}"

			continue
		do :; done

		set -- 0 "${@}"
		# ステップ 7.3: 主ループ — 位置パラメータを窓として扱い、1 語ずつ左へずらしながら商を 1 語ずつ確定する
		#   窓 = $1..$(n+1) = u_{W-n}..u_W。D2/D3 は窓先頭 2〜3 語を $1..$3 から直接参照する
		#   （eval 不要）。D4（稀に D5）の書き込みは eval を避けて new_ に前置で蓄積し、
		#   反復末尾に shift n+1 → set -- ${new_} "$@" → shift 1（退出語 u_{W-n} を破棄）で
		#   次窓 $1..$(n+1) = u_{W-n+1}..u_{W+1} を確定する。
		#   D4/D5 は下位語（窓の末尾側）から上位語へ走査するため、読み出しのみ eval を使用する。
		Q_q=

		while M_STR_NE([|"${Q_n}"|], [|"${#}"|]); do
			# D2: 商の見積り — 窓の先頭 2 語（$1, $2）を v1 で割って qhat を仮定する
			#   top2 = u_{W-n}*b + u_{W-n+1}、qhat = top2 ÷ v1（b を超えたら b-1 に丸める）
			Q_top2=$((${1} * Q_b + ${2}))
			Q_qhat=$((Q_top2 / Q_v1))

			case "$((Q_b <= Q_qhat))" in
				1)
					Q_qhat=$((Q_b - 1))
					Q_rhat=$((Q_top2 - Q_qhat * Q_v1))
					;;
				*) Q_rhat=$((Q_top2 % Q_v1));;
			esac

			# D3: 精緻化 — qhat×v2 が b×rhat + u_{W-n+2}（= $3）を超える間 qhat を 1 ずつ減らす
			#   （qhat の過大見積りを補正する。rhat が b 未満である限り繰り返す）
			while M_NUM_BOOL([|Q_rhat < Q_b && (Q_b * Q_rhat + ${3-0}) < (Q_qhat * Q_v2)|]); do
				M_NUM_DECR([|Q_qhat|])
				M_NUM_INCR([|Q_rhat|], [|Q_v1|])
			done

			# D4: 融合 multiply-subtract — 窓の語 u_{W-n+1}..u_W（= $2..$(n+1)）から qhat×v を一括減算する
			#   語積 p = qhat×v_j + carry を一度に算出し、下位語から上位語へ繰り上がりを伝搬する
			#   （vstr_ を用いて $1=v_j, $2=u_j ペアを展開し、計算結果は new_ への前置で MS-first に整列する）
			Q_carry=0
			Q_new=
			Q_ut="${1}"
			shift

			eval set -- "${Q_vstr}" - '"${@}"'

			while
				Q_p=$((Q_qhat * ${1} + Q_carry))
				Q_t=$((${2} - Q_p % Q_b))
				Q_carry=$((Q_p / Q_b))

				case "${Q_t}" in -*)
					M_NUM_INCR([|Q_t|], [|Q_b|])
					M_NUM_INCR([|Q_carry|])
				esac

				M_STR_PREPEND([|Q_new|], [|"${Q_t} "|])
				shift 2

				case "${1}" in -)
					shift
					break
				esac

				continue
			do :; done

			M_NUM_DECR([|Q_ut|], [|Q_carry|])
			shift "${Q_n}"
			eval set -- "${Q_new}" '"${@}"'

			# D5: 加算復帰 — D4 の減算結果が負（qhat が過大）だった場合に v を加算して qhat を 1 減らす
			#   （通常 0 回、最大 2 回で収束する。新窓 $1..$n に対して vstr_ で加算し、新窓を置換する）
			while M_NUM_LT([|Q_ut|], [|0|]); do
				Q_ck=0
				Q_new=

				eval set -- "${Q_vstr}" - '"${@}"'

				while
					Q_t=$((${2} + ${1} + Q_ck))
					case "$((Q_b <= Q_t))" in
						1)
							M_NUM_DECR([|Q_t|], [|Q_b|])
							Q_ck=1
							;;
						*) Q_ck=0;;
					esac

					M_STR_PREPEND([|Q_new|], [|"${Q_t} "|])
					shift 2

					case "${1}" in -)
						shift
						break
					esac

					continue
				do :; done

				shift "${Q_n}"
				eval set -- "${Q_new}" '"${@}"'

				M_NUM_DECR([|Q_qhat|])
				M_NUM_INCR([|Q_ut|], [|Q_ck|])
			done

			case "${Q_qhat}" in
				${Q_qm}) M_STR_APPEND([|Q_q|], [|"${Q_qhat}"|]);;
				*)
					# 商に qhat を c 桁ゼロ埋めで連結
					M_STR_PREPEND([|Q_qhat|], [|"${Q_zr}"|])
					M_STR_APPEND([|Q_q|], [|"${Q_qhat#"${Q_qhat%${Q_qm}}"}"|])
					;;
			esac
		done

		case "${Q_q}" in 0*)
			Q_q="M_STR_LTRIM([|Q_q|], [|[!0]|])"
		esac

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_q}" || {
			unset CLEANUP
			return M_EX_OK
		}

		# ステップ 7.4: 余り抽出 — 位置パラメータに残る末尾 n 語（u_{K-n+1}..u_K）を c 桁ゼロ埋めで連結する
		#   （主ループが各反復で 1 語ずつ破棄したため、ループ終了後の $@ がちょうど余りの n 語になる）
		Q_r=
		for Q_uw in "${@}"; do
			case "${Q_uw}" in
				${Q_qm}) M_STR_APPEND([|Q_r|], [|"${Q_uw}"|]);;
				*)
					M_STR_PREPEND([|Q_uw|], [|"${Q_zr}"|])
					M_STR_APPEND([|Q_r|], [|"${Q_uw#"${Q_uw%${Q_qm}}"}"|])
					;;
			esac
		done

		# ステップ 7.5: 逆正規化 — 余りの末尾 d 桁を除去して 10^d 倍を戻す（商は影響を受けない）
		case "${Q_d}" in [!0]*)
			Q_r="${Q_r%${Q_qmd}}"
		esac

		M_STR_APPEND([|Q_r|], [|"${Q_btail}"|])

		case "${Q_r}" in 0*)
			Q_r="M_STR_LTRIM([|Q_r|], [|[!0]|])";;
		esac
	fi

	__sx_var_ubind Q_bind "${Q_bind}" "${Q_r:-0}" || :

	unset CLEANUP
}
|], [|num_divmod_nat0|])dnl

### sx_num_edivmod_int - ユークリッド除算で整数商と余剰を同時に求める
##
## 使い方:
##   sx_num_edivmod_int バインド形式 被除数 [除数]
##
## 説明:
##   符号付き10進整数のユークリッド除算 a = b×q + r（0 ≤ r < |b|）を行い、
##   整数商と余剰を同時に求める。除法定理により (q, r) は一意に定まり、
##   余剰は入力の符号に依存せず常に 0 以上となる。
##   第一引数は商・余剰の割り当て先を指定する分配代入バインド形式（例: "q:r:"）。
##   被除数は任意の符号付き整数、除数は 0 以外の符号付き整数。
##   除数に 0 を指定した場合は引数不正とみなす。
##   被除数・除数は省略可能で、省略した場合はそれぞれ 0、1 として扱われる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数が書き込み不可 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE が不正 (SX_EX_CONFIG)

sx_num_edivmod_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_edivmod_int "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_base 10 ${2:+"${2}"} && __sx_num_is_nzint_base 10 ${3:+"${3}"} || return M_EX_USAGE

	__sx_num_edivmod_int "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_edivmod_int - ユークリッド除算で整数商と余剰を同時に求める（内部用）
##
## 使い方:
##   __sx_num_edivmod_int バインド形式 被除数 [除数]
##
## 説明:
##   sx_num_edivmod_int の内部実装。引数チェックは行わない。
##   絶対値どうしの除算（q0, r0: 0 ≤ r0 < |v|）の後にユークリッド規約を適用する。
##   - r0 = 0 のとき: q = sign(u)×sign(v)×q0、r = 0
##   - r0 ≠ 0 かつ u ≥ 0 のとき: q = ±q0（v < 0 なら負）、r = r0
##   - r0 ≠ 0 かつ u < 0 のとき: q = ±(q0 + 1)（v < 0 なら正）、r = |v| - r0
##   q0 + 1 は __sx_num_add1_nat0、|v| - r0 は __sx_num_sub_nat0 で算出し、
##   ネイティブ算術幅を超えても多倍長のまま正しく補正する。

define([|CLEANUP|], [|Q_bind Q_q Q_r Q_us Q_vs|])dnl

__sx_num_edivmod_int() {
	__sx_var_bind_init "${1}"
	set -- "${1}" "${2:-0}" "${3:-1}"
	Q_us=0
	Q_vs=0

	case "${2}" in -*)
		Q_us=1
	esac

	case "${3}" in -*)
		Q_vs=1
	esac

	__sx_num_divmod_nat0 'Q_q:Q_r:' "${2#[+-]}" "${3#[+-]}"

	case "${Q_q}:${Q_r}:${Q_us}${Q_vs}" in
		*:[!0]*:1?)
			M_NUM_INCRM1([|Q_q|])

			case "${Q_vs}" in 0)
				M_STR_PREPEND([|Q_q|], [|-|])
			esac

			__sx_var_ubind Q_bind "${1}" "${Q_q}" || {
				unset CLEANUP
				return M_EX_OK
			}

			__sx_num_sub_nat0 Q_r "${3#[+-]}" "${Q_r}"
			;;
		[!0]*:0:10 | [!0]*:*:01) Q_q="-${Q_q}";&
		*)
			__sx_var_ubind Q_bind "${1}" "${Q_q}" || {
				unset CLEANUP
				return M_EX_OK
			}
			;;
	esac

	__sx_var_ubind Q_bind "${Q_bind}" "${Q_r}" || :

	unset CLEANUP
}
|], [|num_edivmod_int|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_fixed() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *.*)
			sx_str_is_digit "${Q_arg#*.}"
		esac && __sx_num_is_int_base 10 "${Q_arg%%.*}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_fixed|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_float() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in *[Ee]*)
			__sx_num_is_int_base 10 "${Q_arg#*[Ee]}"
		esac && sx_num_is_fixed "${Q_arg%%[Ee]*}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_float|])dnl

M_RENAME_Q([|dnl
### sx_num_is_float_safe - すべての引数が安全な範囲の 10 進の実数表記であるか確認する
##
## 使い方:
##   sx_num_is_float_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_float による検証に加えて、セキュリティ上の理由（DoS 対策）から、
##   指数の絶対値を 4 桁（9999）までに制限する。
##
## 終了ステータス:
##    0  すべて安全な 10 進の実数表記である (SX_EX_OK)
##    1  安全ではない、または 10 進の実数表記ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_float_safe() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			# DoS 対策: 指数の絶対値は 4 桁まで
			*[Ee][+-]?????* | *[Ee][!+-]????*) ! :;;
			*) sx_num_is_float "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_float_safe|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_int() {
	for Q_arg in "${@}"; do
		sx_num_is_nat0 "${Q_arg#[+-]}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_int|])dnl

### sx_num_is_int_base - 指定された基数で整数か確認する
##
## 使い方:
##   sx_num_is_int_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が、任意で符号（+ または -）を持つ整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて整数である (SX_EX_OK)
##    1  整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_int_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_int_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_int_base - 指定された基数で整数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_int_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_int_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		__sx_num_is_nat0_base "${Q_rad}" "${Q_arg#[+-]}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_int_base|])dnl

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
		*) return M_EX_USAGE;;
	esac

	sx_num_is_int "${@}" || return M_EX_USAGE

	__sx_num_is_int_fit "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_num_is_int_fit - 指定されたビット幅の符号付き整数の範囲内か確認する（内部ロジック）

define([|CLEANUP|], [|Q_arg Q_bit Q_xlen Q_olenn Q_oleadn Q_olenp Q_oleadp|])dnl

__sx_num_is_int_fit() {
	Q_bit="${1}"
	shift

	for Q_arg in "${@}"; do
		# $1: 値（符号正規化）, $2: 数値部分の長さ
		set -- "${Q_arg#+}" "${#Q_arg}"
		case "${1}" in +* | -*)
			set -- "${1}" "$((${2} - 1))"
		esac

		case "${1}" in
			0[Xx]* | -0[Xx]*)
			# 基数16のパラメータ計算
			: ${Q_xlen=$((Q_bit / 4 + 2))}

				if
					M_NUM_LT([|Q_xlen|], [|${2}|]) || {
						M_STR_EQ([|"${Q_xlen}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[Xx][9ABCDEFabcdef]*|], [|-0[Xx]8*[!0]*|], [|0[Xx][89ABCDEFabcdef]*|])
					}
				then
					unset CLEANUP
					return 1
				fi
				;;
			0?* | -0?*)
				# 基数8のパラメータ計算
				: ${Q_olenn=$(((Q_bit - 1) / 3 + 2))}
				: ${Q_oleadn=$((1 << ((Q_bit - 1) % 3)))}
				: ${Q_olenp=$((Q_olenn - (Q_oleadn == 1)))}
				: ${Q_oleadp=$((Q_oleadn == 1 ? 7 : Q_oleadn - 1))}

				# $3: 制限長さ, $4: 制限先頭文字
				case "${1}" in
					-*) set -- "${1}" "${2}" "${Q_olenn}" "${Q_oleadn}";;
					*)  set -- "${1}" "${2}" "${Q_olenp}" "${Q_oleadp}";;
				esac

				if
					M_NUM_LT([|${3}|], [|${2}|]) || {
						M_STR_EQ([|"${3}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[!1-${4}]*|], [|-0${4}*[!0]*|], [|0[!1-${4}-]*|])
					}
				then
					unset CLEANUP
					return 1
				fi
				;;
			*)
				__sx_num_is_int_fit_dec "${Q_bit}" "${Q_arg}" || {
					unset CLEANUP
					return 1
				}
				;;
			esac
	done

	unset CLEANUP
}
|], [|num_is_int_fit|])dnl

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
		*) return M_EX_USAGE;;
	esac

	__sx_num_is_int_base 10 "${@}" || return M_EX_USAGE

	__sx_num_is_int_fit_dec "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_num_is_int_fit_dec - 桁数チェックと10進整数判定を実行する（内部用）
##
## 使い方:
##   __sx_num_is_int_fit_dec ビット幅 [整数1 [整数2 ...]]
##
## 説明:
##   sx_num_is_int_fit_dec の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bit Q_arg Q_e|])dnl

__sx_num_is_int_fit_dec() {
	Q_bit="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			-*) Q_e=8;;
			*) Q_e=7;;
		esac

		Q_arg=${Q_arg#[+-]}

		case "${Q_bit}" in
			8)
				case "${#Q_arg}" in
					[12]) continue;;
					3)
						case "${Q_arg}" in
							1[01]* | 12[0-${Q_e}]) continue;;
						esac
						;;
				esac
				;;
			16)
				case "${#Q_arg}" in
					[1-4]) continue;;
					5)
						case "${Q_arg}" in
							[12]* | 3[01]* | 32[0-6]* | 327[0-5]* | \
							3276[0-${Q_e}]) continue;;
						esac
						;;
				esac
				;;
			32)
				case "${#Q_arg}" in
					[1-9]) continue;;
					10)
						case "${Q_arg}" in
							1* | 20* | 21[0-3]* | 214[0-6]* | 2147[0-3]* | 21474[0-7]* | \
							214748[0-2]* | 2147483[0-5]* | 21474836[0-3]* | \
							214748364[0-${Q_e}]) continue;;
						esac
						;;
				esac
				;;
			64)
				case "${#Q_arg}" in
					[1-9] | 1[0-8]) continue;;
					19)
						case "${Q_arg}" in
							[1-8]* | 9[01]* | 92[01]* | 922[0-2]* | 9223[0-2]* | \
							92233[0-6]* | 922337[01]* | 92233720[0-2]* | 922337203[0-5]* |\
							9223372036[0-7]* | 92233720368[0-4]* | 922337203685[0-3]* | \
							9223372036854[0-6]* | 92233720368547[0-6]* | \
							922337203685477[0-4]* | 9223372036854775[0-7]* | \
							922337203685477580[0-${Q_e}]) continue;;
						esac
						;;
				esac
				;;
			128)
				case "${#Q_arg}" in
					[1-9] | [12][0-9] | 3[0-8]) continue;;
					39)
						case "${Q_arg}" in
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
							17014118346046923173168730371588410572[0-${Q_e}]) continue;;
						esac
						;;
				esac
				;;
		esac

		unset CLEANUP
		return 1
	done

	unset CLEANUP
}
|], [|num_is_int_fit_dec|])dnl

### sx_num_is_int_safe - 安全に処理できる数値範囲（SX_CFG_NUM_RANGE）の整数か確認する
##
## 使い方:
##   sx_num_is_int_safe [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の整数である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_int_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_safe "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_int_safe "${@}" || return
}

### __sx_num_is_int_safe - 設定された数値範囲に基づいて検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_int_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe の内部実装。引数チェックは行わない。
__sx_num_is_int_safe() {
	__sx_num_is_int_width "${SX_CFG_NUM_RANGE}" "${@}" || return
}

### sx_num_is_int_safe_inv - 安全に処理できる数値範囲（SX_CFG_NUM_RANGE）で符号反転可能な整数か確認する
##
## 使い方:
##   sx_num_is_int_safe_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe と同様に SX_CFG_NUM_RANGE に基づいて整数を検証するが、
##   INT_MIN（符号反転が不可能な最小値）を許可しない。
##   すなわち -(2^(n-1)-1) ～ 2^(n-1)-1 の範囲の整数のみを受理する。
##
## 終了ステータス:
##    0  すべて範囲内の符号反転可能な整数である (SX_EX_OK)
##    1  範囲外、または整数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_int_safe_inv() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_int_safe_inv "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_int_safe_inv "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_num_is_int_safe_inv - 符号反転可能な整数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_int_safe_inv [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_int_safe_inv の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_min Q_arg|])dnl

__sx_num_is_int_safe_inv() {
	__sx_num_is_int_safe "${@}" || return

	eval "Q_min=\"\${SX_NUM_I${SX_CFG_NUM_RANGE}_MIN}\""

	for Q_arg in "${@}"; do
		case "${Q_arg}" in "${Q_min}")
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|num_is_int_safe_inv|])dnl

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
		*) return M_EX_USAGE;;
	esac

	__sx_num_is_int_width "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_num_is_int_width - すべての引数が指定されたビット幅の符号付き整数の範囲内か確認する（内部用）

define([|CLEANUP|], [|Q_bits|])dnl

__sx_num_is_int_width() {
	Q_bits="${1}"
	shift

	sx_num_is_int "${@}" || {
		unset CLEANUP
		return 1
	}

	set -- "${Q_bits}" "${@}"
	unset CLEANUP

	__sx_num_is_int_fit "${@}" || return
}
|], [|num_is_int_width|])dnl

M_RENAME_Q([|dnl
### sx_num_is_nat0 - すべての引数が 0 以上の自然数（符号なし整数） であるか確認する
##
## 使い方:
##   sx_num_is_nat0 [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて 0 以上の自然数である (SX_EX_OK)
##    1  自然数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nat0() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0[Xx]*) __sx_num_is_nat0_base 16 "${Q_arg}";;
			0?*) __sx_num_is_nat0_base 8 "${Q_arg}";;
			*) __sx_num_is_nat0_base 10 "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nat0|])dnl

### sx_num_is_nat0_base - 指定された基数で0以上の自然数か確認する
##
## 使い方:
##   sx_num_is_nat0_base 基数 [文字列1 [文字列2 ...]]
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
sx_num_is_nat0_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat0_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_nat0_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_nat0_base - 指定された基数で0以上の自然数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nat0_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat0_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_arg Q_pfix Q_char|])dnl

__sx_num_is_nat0_base() {
	eval "
		Q_pfix=\"\${SX_NUM_BASE${1}_PREFIX}\"
		Q_char=\"\${SX_NUM_BASE${1}_CHARS}\"
	"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			${Q_pfix}*) ! M_STR_MATCH([|"${Q_arg#${Q_pfix}}"|] , [|''|], [|0?*|], [|*[!"${Q_char}"]*|]);;
			*) ! :;;
		esac || {
			unset Q_pfix Q_char Q_arg
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nat0_base|])dnl

### sx_num_is_nat0_safe - 安全に処理できる数値範囲（SX_CFG_NUM_RANGE）の自然数（0以上）か確認する
##
## 使い方:
##   sx_num_is_nat0_safe [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の自然数である (SX_EX_OK)
##    1  範囲外、または自然数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_nat0_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat0_safe "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_nat0_safe "${@}" || return
}

### __sx_num_is_nat0_safe - 設定された数値範囲に基づいて自然数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_nat0_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat0_safe の内部実装。引数チェックは行わない。
__sx_num_is_nat0_safe() {
	sx_num_is_nat0 "${@}" || return
	__sx_num_is_int_fit "${SX_CFG_NUM_RANGE}" "${@}" || return
}

M_RENAME_Q([|dnl
### sx_num_is_nat1 - すべての引数が 1 以上の自然数（符号なし整数） であるか確認する
##
## 使い方:
##   sx_num_is_nat1 [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて 1 以上の自然数である (SX_EX_OK)
##    1  1 以上の自然数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nat1() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0[Xx]*) __sx_num_is_nat1_base 16 "${Q_arg}";;
			0?*) __sx_num_is_nat1_base 8 "${Q_arg}";;
			*) __sx_num_is_nat1_base 10 "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nat1|])dnl

### sx_num_is_nat1_base - 指定された基数で1以上の自然数か確認する
##
## 使い方:
##   sx_num_is_nat1_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 1 以上の自然数（符号なし整数）であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて 1 以上の自然数である (SX_EX_OK)
##    1  1 以上の自然数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_nat1_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat1_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_nat1_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_nat1_base - 指定された基数で1以上の自然数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nat1_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat1_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_arg Q_pfix Q_char|])dnl

__sx_num_is_nat1_base() {
	eval "
		Q_pfix=\"\${SX_NUM_BASE${1}_PREFIX}\"
		Q_char=\"\${SX_NUM_BASE${1}_CHARS}\"
	"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			${Q_pfix}*) ! M_STR_MATCH([|"${Q_arg#${Q_pfix}}"|], [|''|], [|0*|], [|*[!"${Q_char}"]*|]);;
			*) ! :;;
		esac || {
			unset Q_pfix Q_char Q_arg
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nat1_base|])dnl

### sx_num_is_nat1_safe - 安全に処理できる数値範囲（SX_CFG_NUM_RANGE）の自然数（1以上）か確認する
##
## 使い方:
##   sx_num_is_nat1_safe [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて標準範囲内の 1 以上の自然数である (SX_EX_OK)
##    1  範囲外、または 1 以上の自然数でない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_nat1_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nat1_safe "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_nat1_safe "${@}" || return
}

### __sx_num_is_nat1_safe - 設定された数値範囲に基づいて 1 以上の自然数の検証を行う（内部用）
##
## 使い方:
##   __sx_num_is_nat1_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nat1_safe の内部実装。引数チェックは行わない。
__sx_num_is_nat1_safe() {
	sx_num_is_nat1 "${@}" || return
	__sx_num_is_int_fit "${SX_CFG_NUM_RANGE}" "${@}" || return
}

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			-*) sx_num_is_nat1 "${Q_arg#-}";;
			*) ! :;;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nint|])dnl

### sx_num_is_nint_base - 指定された基数で負の整数（-1以下）か確認する
##
## 使い方:
##   sx_num_is_nint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が、負の符号（-）を必須で持つ -1 以下の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて負の整数である (SX_EX_OK)
##    1  負の整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_nint_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nint_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_nint_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_nint_base - 指定された基数で負の整数（-1以下）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nint_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_nint_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			-*) __sx_num_is_nat1_base "${Q_rad}" "${Q_arg#-}";;
			*) ! :;;
			esac || {
				unset CLEANUP
				return 1
			}
	done

	unset CLEANUP
}
|], [|num_is_nint_base|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nnint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			00 | [+-]00 | 0 | [+-]0 | 0[Xx]0 | [+-]0[Xx]0) continue;;
		esac

		sx_num_is_pint "${Q_arg}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nnint|])dnl

### sx_num_is_nnint_base - 指定された基数で非負整数（0以上）か確認する
##
## 使い方:
##   sx_num_is_nnint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 0 以上の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて非負整数である (SX_EX_OK)
##    1  非負整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_nnint_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nnint_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_nnint_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_nnint_base - 指定された基数で非負整数（0以上）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nnint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nnint_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_nnint_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_rad}${Q_arg}" in
			800 | 8[+-]00 | 100 | 10[+-]0 | 160[Xx]0 | 16[+-]0[Xx]0) continue;;
		esac

		__sx_num_is_pint_base "${Q_rad}" "${Q_arg}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nnint_base|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_npint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			00 | [+-]00 | 0 | [+-]0 | 0[Xx]0 | [+-]0[Xx]0) continue;;
		esac

		sx_num_is_nint "${Q_arg}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_npint|])dnl

### sx_num_is_npint_base - 指定された基数で非正整数（0以下）か確認する
##
## 使い方:
##   sx_num_is_npint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が 0 以下の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて非正整数である (SX_EX_OK)
##    1  非正整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_npint_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_npint_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_npint_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_npint_base - 指定された基数で非正整数（0以下）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_npint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_npint_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_npint_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_rad}${Q_arg}" in
			800 | 8[+-]00 | 100 | 10[+-]0 | 160[Xx]0 | 16[+-]0[Xx]0) continue;;
		esac

		__sx_num_is_nint_base "${Q_rad}" "${Q_arg}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_npint_base|])dnl

### sx_num_is_num_safe - すべての引数が有効な数値（整数または実数）であるか確認する
##
## 使い方:
##   sx_num_is_num_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   引数が 16進数または 8進数の形式（0x または 0[0-9] で始まる）である場合は
##   sx_num_is_int_safe で、それ以外の場合は sx_num_is_float_safe で検証を行う。
##
## 終了ステータス:
##    0  すべて有効な数値である (SX_EX_OK)
##    1  有効な数値ではない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_num_safe() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_num_safe "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_num_is_num_safe "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_num_is_num_safe - すべての引数が有効な数値形式であるか検証する（内部用）
##
## 使い方:
##   __sx_num_is_num_safe [文字列1 [文字列2 ...]]
##
## 説明:
##   引数が 16進数または 8進数の形式である場合は __sx_num_is_int_safe で、
##   それ以外の場合は sx_num_is_float_safe で検証を行う。
##
## 終了ステータス:
##    0  すべて有効な数値である (SX_EX_OK)
##    1  有効な数値ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_num_is_num_safe() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			*[Xx]* | [+-]0[0-9]* | 0[0-9]*) __sx_num_is_int_safe "${Q_arg}";;
			*) sx_num_is_float_safe "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_num_safe|])dnl

M_RENAME_Q([|dnl
### sx_num_is_nzint - すべての引数が 0 以外の整数であるか確認する
##
## 使い方:
##   sx_num_is_nzint [文字列1 [文字列2 ...]]
##
## 説明:
##   0（+0, -0 を含む）以外の整数であるかを確認する。
##
## 終了ステータス:
##    0  すべて 0 以外の整数である (SX_EX_OK)
##    1  0、または整数ではない値が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_nzint() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0 | [+-]0 | 00 | [+-]00 | 0[Xx]0 | [+-]0[Xx]0) ! :;;
			*) sx_num_is_int "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nzint|])dnl

### sx_num_is_nzint_base - 指定された基数で 0 以外の整数か確認する
##
## 使い方:
##   sx_num_is_nzint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が、任意で符号（+ または -）を持つ 0 以外の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて 0 以外の整数である (SX_EX_OK)
##    1  0、または整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_nzint_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_nzint_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_nzint_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_nzint_base - 指定された基数で 0 以外の整数か確認する（内部用）
##
## 使い方:
##   __sx_num_is_nzint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_nzint_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_nzint_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_rad}${Q_arg}" in
			800 | 8[+-]00 | 100 | 10[+-]0 | 160[Xx]0 | 16[+-]0[Xx]0) ! :;;
			*) __sx_num_is_int_base "${Q_rad}" "${Q_arg}";;
		esac || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_nzint_base|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_is_pint() {
	for Q_arg in "${@}"; do
		sx_num_is_nat1 "${Q_arg#+}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_pint|])dnl

### sx_num_is_pint_base - 指定された基数で正の整数（1以上）か確認する
##
## 使い方:
##   sx_num_is_pint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   第一引数で指定された基数（8, 10, 16）において、
##   後続のすべての引数が、任意で正の符号（+）を持つ 1 以上の整数であるか確認する。
##   プレフィックスおよび先行する 0 に関する制約は sx_num_is_nat0_base に準ずる。
##
## 終了ステータス:
##    0  すべて正の整数である (SX_EX_OK)
##    1  正の整数ではない値が含まれる
##   64  基数指定が不正 (SX_EX_USAGE)
sx_num_is_pint_base() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_is_pint_base "${@}" || return; return 0;; esac

	case "${1-}" in 8 | 10 | 16) ;; *) return M_EX_USAGE;; esac

	__sx_num_is_pint_base "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_is_pint_base - 指定された基数で正の整数（1以上）か確認する（内部用）
##
## 使い方:
##   __sx_num_is_pint_base 基数 [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_num_is_pint_base の内部実装。基数チェックを行わない。

define([|CLEANUP|], [|Q_rad Q_arg|])dnl

__sx_num_is_pint_base() {
	Q_rad="${1}"
	shift

	for Q_arg in "${@}"; do
		__sx_num_is_nat1_base "${Q_rad}" "${Q_arg#+}" || {
			unset CLEANUP
			return 1
		}
	done

	unset CLEANUP
}
|], [|num_is_pint_base|])dnl

M_RENAME_Q([|dnl
### sx_num_mul_int - 複数の符号付き整数を乗算する
##
## 使い方:
##   sx_num_mul_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を乗算する。負号の個数で符号を決定し、
##   __sx_num_mul_nat0 で絶対値乗算を行う。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 整数として不正な値が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_mul_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_mul_int "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_int_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_mul_int "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_mul_int|])dnl

M_RENAME_QI([|dnl
### __sx_num_mul_int - 複数の符号付き整数を乗算する（内部用）
##
## 使い方:
##   __sx_num_mul_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_mul_int の内部実装。引数チェックは行わない。
##   負号の個数で符号を決定し、__sx_num_mul_nat0 で絶対値乗算を行う。

define([|CLEANUP|], [|Q_res Q_qty Q_arg Q_abs_args Q_sign Q_acc|])dnl

__sx_num_mul_int() {
	Q_res="${1}"
	shift

	Q_qty=0
	Q_abs_args=

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			0 | +0 | -0)
				M_VAR_SET([|${Q_res}|], [|0|])
				unset CLEANUP
				return
				;;
			-*) Q_qty=$((~Q_qty));;
		esac

		M_STR_APPEND([|Q_abs_args|], [|" ${Q_arg#[+-]}"|])
	done

	case "$((Q_qty & 1))" in
		1) Q_sign=-;;
		*) Q_sign=;;
	esac

	eval __sx_num_mul_nat0 Q_acc "${Q_abs_args}"

	M_VAR_SET([|${Q_res}|], [|${Q_sign}${Q_acc}|])

	unset CLEANUP
}
|], [|num_mul_int|])dnl

M_RENAME_Q([|dnl
### sx_num_mul_nat0 - 複数の絶対値を乗算する
##
## 使い方:
##   sx_num_mul_nat0 結果変数名 [数値1 [数値2 ...]]
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

define([|CLEANUP|], [|Q_res|])dnl

sx_num_mul_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_mul_nat0 "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_nat0_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_mul_nat0 "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_mul_nat0|])dnl

M_RENAME_QI([|dnl
### __sx_num_mul_nat0 - 複数の絶対値を乗算する（内部用）
##
## 使い方:
##   __sx_num_mul_nat0 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号なし10進整数の絶対値を乗算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   逐次方式でアキュムレータに各数値を順次乗算する。

define([|CLEANUP|], [|Q_res Q_a Q_b Q_endz Q_qm Q_shift Q_tmp Q_ch_a Q_ch_b Q_wlen_mul Q_max_ops Q_a_len Q_b_len Q_max_x Q_min_ops Q_opt_x Q_opt_y Q_x Q_y Q_ops Q_qchunk_a Q_qchunk_b Q_zchunk_a Q_zchunk_b Q_carry Q_g Q_fit Q_safe|])dnl

__sx_num_mul_nat0() {
	Q_res="${1}"
	Q_a="${2-1}"
	Q_endz=
	Q_fit=1
	shift "$((1 + 0${2+1}))"

	case "${Q_a}" in 0)
		set --
	esac

	# safe_: 分割探索式の (len + (x - 1)) が INT_MAX を超えないための上限
	Q_safe=$((SX_SYS_NUM_MAX - SX_SYS_NUM_WLEN + 2))

	for Q_b in "${@}"; do
		case "${Q_b}" in 0)
			Q_a=0
			Q_endz=
			break
		esac

		# 高速パス: 両因数が1語に収まればシェル算術で直接乗算
		case "${Q_a}${Q_b}" in
			${SX_SYS_NUM_QM}?*) ;;
			*)
				M_NUM_AMP([|Q_a|], [|Q_b|])
				continue
				;;
		esac

		# 末尾のゼロを一時分離し、後で結合する
		case "${Q_a}" in *0)
			Q_tmp="${Q_a##*[!0]}"
			Q_a="${Q_a%${Q_tmp}}"
			M_STR_APPEND([|Q_endz|], [|"${Q_tmp}"|])
		esac

		case "${Q_b}" in *0)
			Q_tmp="${Q_b##*[!0]}"
			Q_b="${Q_b%${Q_tmp}}"
			M_STR_APPEND([|Q_endz|], [|"${Q_tmp}"|])
		esac

		# 1の乗算をスキップ / 1語に収まらなければ多倍長処理へ
		case "${Q_a}:${Q_b}" in
			1:*) Q_a="${Q_b}";&
			*:1) ! :;;
			${SX_SYS_NUM_QM}??*) ;;
			*) ! M_NUM_AMP([|Q_a|], [|Q_b|])
		esac || continue

		# fit_: 桁数そのものが INT_MAX を超えると算術展開できないため、
		#       範囲内に収まる桁数かどうかを確認する
		Q_a_len="${#Q_a}"
		Q_b_len="${#Q_b}"

		case "${Q_fit}" in 1)
			__sx_num_is_int_fit_dec "${SX_CFG_NUM_RANGE}" "${Q_a_len}" "${Q_b_len}" || Q_fit=0
		esac

		# 長い方を a に統一し、分割最適化の効果を最大化
		case "$((Q_fit && Q_a_len < Q_b_len))" in 1)
			Q_tmp="${Q_b}"
			Q_b="${Q_a}"
			Q_a="${Q_tmp}"
			Q_tmp="${Q_b_len}"
			Q_b_len="${Q_a_len}"
			Q_a_len="${Q_tmp}"
		esac

		# 安全: 桁数が算術展開可能な範囲内 → 全分割点を探索
		# 危険: 桁数が算術展開不能 or 範囲超過 → 均等分割にフォールバック
		if M_NUM_BOOL([|Q_fit && Q_a_len <= Q_safe && Q_b_len <= Q_safe|]); then
			Q_max_x=$((Q_b_len < SX_SYS_NUM_WLEN ? Q_b_len : SX_SYS_NUM_WLEN - 1))
			Q_min_ops="${SX_SYS_NUM_MAX}"
			Q_opt_x=1
			Q_x=1

			while M_NUM_LE([|Q_x|], [|Q_max_x|]); do
				Q_y=$((SX_SYS_NUM_WLEN - Q_x))
				Q_ops=$((((Q_b_len + (Q_x - 1)) / Q_x) * ((Q_a_len + (Q_y - 1)) / Q_y)))

				case "$((Q_ops < Q_min_ops))" in 1)
					Q_min_ops="${Q_ops}"
					Q_opt_x="${Q_x}"
				esac

				M_NUM_INCR([|Q_x|])
			done
		else
			Q_opt_x=$(((SX_SYS_NUM_WLEN + 1) / 2))
		fi

		# 最適分割サイズに基づきチャンク用 QM/ZR をロード
		Q_opt_y=$((SX_SYS_NUM_WLEN - Q_opt_x))

		eval "Q_qchunk_a=\"\${SX_NUM_QM_${Q_opt_y}}\" \
		      Q_zchunk_a=\"\${SX_NUM_ZR_${Q_opt_y}}\" \
		      Q_qchunk_b=\"\${SX_NUM_QM_${Q_opt_x}}\" \
		      Q_zchunk_b=\"\${SX_NUM_ZR_${Q_opt_x}}\""

		Q_shift=

		set --

		# a を opt_y 桁ずつ下位からチャンク分割し位置パラメータに格納
		while
			case "${Q_a}" in
				${Q_qchunk_a}?*)
					Q_tmp="${Q_a%${Q_qchunk_a}}"
					Q_ch_a="${Q_a#"${Q_tmp}"}"
					Q_a="${Q_tmp}"

					case "${Q_ch_a}" in
						0*) set -- "${@}" "$((1${Q_ch_a} - 1${Q_zchunk_a}))";;
						*) set -- "${@}" "${Q_ch_a}";;
					esac
					;;
				*) set -- "${@}" "${Q_a}" && break;;
			esac

			continue
		do :; done

		Q_a=0

		# b を opt_x 桁ずつ分割しながら a の全チャンクと乗算
		while
			case "${Q_b}" in
				'') break;;
				${Q_qchunk_b}?*)
					Q_tmp="${Q_b%${Q_qchunk_b}}"
					Q_ch_b="${Q_b#"${Q_tmp}"}"
					Q_b="${Q_tmp}"

					case "${Q_ch_b}" in
						0*[1-9]*) Q_ch_b=$((1${Q_ch_b} - 1${Q_zchunk_b}));;
						0*)
							M_STR_PREPEND([|Q_shift|], [|"${Q_zchunk_b}"|])
							continue
							;;
					esac
					;;
				*)
					Q_ch_b="${Q_b}"
					Q_b=
					;;
			esac

			Q_g=
			Q_carry=

			# チャンク同士の乗算と桁上げ処理
			for Q_ch_a in "${@}"; do
				Q_tmp=$((Q_ch_b * Q_ch_a + ${Q_carry:-0}))

				case "$((1${Q_zchunk_a} <= Q_tmp))" in
					1)
						Q_carry="${Q_tmp%${Q_qchunk_a}}"
						M_STR_PREPEND([|Q_g|], [|"${Q_tmp#"${Q_carry}"}"|])
						;;
					*)
						Q_carry=

						case "${Q_tmp}" in
							${Q_qchunk_a}) M_STR_PREPEND([|Q_g|], [|"${Q_tmp}"|]);;
							*)
								M_NUM_INCR([|Q_tmp|], [|1${Q_zchunk_a}|])
								M_STR_PREPEND([|Q_g|], [|"${Q_tmp#1}"|])
								;;
						esac
						;;
				esac
			done

			case "${Q_carry}:${Q_g}" in :0*)
				Q_g="M_STR_LTRIM([|Q_g|], [|[!0]|])"
			esac

			# 部分積を結果リストに追加
			__sx_num_add_nat0 Q_a "${Q_a}" "${Q_carry}${Q_g}${Q_shift}"

			M_STR_PREPEND([|Q_shift|], [|"${Q_zchunk_b}"|])
			continue
		do :; done
	done

	M_VAR_SET([|${Q_res}|], [|${Q_a}${Q_endz}|])
	unset CLEANUP
}
|], [|num_mul_nat0|])dnl

M_RENAME_Q([|dnl
### sx_num_max - 与えられた数値の最大値を取得する
##
## 使い方:
##   sx_num_max 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   与えられた数値のうち最大のものを結果変数に格納する。
##   10進整数・16進数・8進数・小数・指数表記を受け付ける（sx_num_rel と同じ数値ドメイン）。
##   結果は最大値の元の表記のまま格納される。同値の場合は先に現れた値を採用する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE) — 数値が1つもない、または数値形式が不正
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_max() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_max "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	case "${#}" in 1)
		return M_EX_USAGE
	esac

	Q_res="${1}"
	shift

	__sx_num_is_num_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_max "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_max|])dnl

M_RENAME_QI([|dnl
### __sx_num_max - 与えられた数値の最大値を取得する（内部用）
##
## 使い方:
##   __sx_num_max 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_max の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_win Q_wnorm Q_arg Q_anorm|])dnl

__sx_num_max() {
	Q_res="${1}"
	Q_win="${2}"
	shift 2

	__sx_num_norm Q_wnorm "${Q_win}"

	for Q_arg in "${@}"; do
		__sx_num_norm Q_anorm "${Q_arg}"

		__sx_num_cmp_fixed "${Q_wnorm}" "${Q_anorm}" || case "${?}" in 1)
			Q_win="${Q_arg}"
			Q_wnorm="${Q_anorm}"
		esac
	done

	M_VAR_SET([|${Q_res}|], [|${Q_win}|])
	unset CLEANUP
}
|], [|num_max|])dnl

M_RENAME_Q([|dnl
### sx_num_min - 与えられた数値の最小値を取得する
##
## 使い方:
##   sx_num_min 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   与えられた数値のうち最小のものを結果変数に格納する。
##   10進整数・16進数・8進数・小数・指数表記を受け付ける（sx_num_rel と同じ数値ドメイン）。
##   結果は最小値の元の表記のまま格納される。同値の場合は先に現れた値を採用する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE) — 数値が1つもない、または数値形式が不正
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_min() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_min "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	case "${#}" in 1)
		return M_EX_USAGE
	esac

	Q_res="${1}"
	shift

	__sx_num_is_num_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_min "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_min|])dnl

M_RENAME_QI([|dnl
### __sx_num_min - 与えられた数値の最小値を取得する（内部用）
##
## 使い方:
##   __sx_num_min 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_min の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_res Q_win Q_wnorm Q_arg Q_anorm|])dnl

__sx_num_min() {
	Q_res="${1}"
	Q_win="${2}"
	shift 2

	__sx_num_norm Q_wnorm "${Q_win}"

	for Q_arg in "${@}"; do
		__sx_num_norm Q_anorm "${Q_arg}"

		__sx_num_cmp_fixed "${Q_wnorm}" "${Q_anorm}" || case "${?}" in 3)
			Q_win="${Q_arg}"
			Q_wnorm="${Q_anorm}"
		esac
	done

	M_VAR_SET([|${Q_res}|], [|${Q_win}|])
	unset CLEANUP
}
|], [|num_min|])dnl

M_RENAME_Q([|dnl
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
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_num_norm() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_norm "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	sx_num_is_num_safe "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_norm "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|num_norm|])dnl

M_RENAME_QI([|dnl
### __sx_num_norm - 数値を10進固定小数点形式に正規化する（内部用）
##
## 使い方:
##   __sx_num_norm バインド形式 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_norm の内部実装。引数の検証は行わない。

define([|CLEANUP|], [|Q_bind Q_arg Q_in Q_mnt Q_dig Q_flen Q_shift Q_dlen|])dnl

__sx_num_norm() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"

	shift

	for Q_arg in "${@}"; do
		Q_in="${Q_arg#[+-]}"

		case "${Q_in}" in
			*[Ee]*)
				# 指数表記の展開
				Q_mnt="${Q_in%%[Ee]*}"
				Q_dig="${Q_mnt%%.*}"

				case "${Q_mnt}" in
					*.*)
						Q_flen=$((${#Q_mnt} - ${#Q_dig} - 1))
						M_STR_APPEND([|Q_dig|], [|"${Q_mnt#*.}"|])
						;;
					*) Q_flen=0;;
				esac

				Q_shift=$((${Q_in#*[Ee]} - Q_flen))
					Q_dlen="${#Q_dig}"

				if M_NUM_LE([|0|], [|Q_shift|]); then
					__sx_str_pad Q_in "${Q_dig}" "-$((Q_dlen + Q_shift))" 0
				else
					: $((Q_shift *= -1))

					if M_NUM_LT([|Q_shift|], [|Q_dlen|]); then
						__sx_str_splice Q_in "${Q_dig}" "$((Q_dlen - Q_shift))" 0 .
					else
						__sx_str_pad Q_in "${Q_dig}" "${Q_shift}" 0
						M_STR_PREPEND([|Q_in|], [|.|])
					fi
				fi

				Q_in="M_STR_LTRIM([|Q_in|], [|[!0]|])"

				case "${Q_in}" in .*)
					M_STR_PREPEND([|Q_in|], [|0|])
				esac
				;;
			*[Xx]* | 0[0-9]*) Q_in=$((Q_in));;
		esac

		# 小数点以下のクリーンアップ
		case "${Q_in}" in *.*)
			Q_in="M_STR_RTRIM([|Q_in|], [|[!0]|])"
			Q_in="${Q_in%.}"
		esac

		case "${Q_in}" in '' | 0)
			Q_arg=
		esac

		__sx_var_ubind Q_bind "${Q_bind}" "${Q_arg%%[!-]*}${Q_in:-0}" || break
	done

	unset CLEANUP
}
|], [|num_norm|])dnl

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
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_range() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_range "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_int_safe "${2-}" ${3+"${3}"} ${4+"${4}"} || return M_EX_USAGE

	case "$((${4-1}))" in 0)
		return M_EX_USAGE
	esac

	__sx_num_range "${@}"
}

M_RENAME_QI([|dnl
### __sx_num_range - 数値の範囲を生成する（内部用）
##
## 使い方:
##   __sx_num_range 宛先 [引数...]
##
## 説明:
##   sx_num_range の内部実装。引数チェックを行わない。

define([|CLEANUP|], [|Q_bind Q_cur|])dnl

__sx_num_range() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	case "${#}" in
		1) set -- 0 "${1}" 1;;
		2) set -- "${1}" "${2}" 1;;
		*) set -- "${1}" "${2}" "${3-1}";;
	esac

	Q_cur="${1}"

	if M_NUM_LT([|0|], [|${3}|]); then
		while M_NUM_LT([|Q_cur|], [|${2}|]); do
			__sx_var_ubind Q_bind "${Q_bind}" "${Q_cur}" || break
			: $((Q_cur += ${3}))
		done
	else
		while M_NUM_LT([|${2}|], [|Q_cur|]); do
			__sx_var_ubind Q_bind "${Q_bind}" "${Q_cur}" || break
			: $((Q_cur += ${3}))
		done
	fi

	unset CLEANUP
}
|], [|num_range|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_num_rel() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_rel "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			eq | '==' | ne | '!=' | lt | '<' | le | '<=' | gt | '>' | ge | '>=') continue;;
		esac

		__sx_num_is_num_safe "${Q_arg}" || {
			unset CLEANUP
			return M_EX_USAGE
		}
	done

	unset CLEANUP

	__sx_num_rel "${@}" || return
}
|], [|num_rel|])dnl

M_RENAME_QI([|dnl
### __sx_num_rel - 数値間の関係を確認する（内部用）
##
## 使い方:
##   __sx_num_rel [数値 | 演算子 ...]
##
## 説明:
##   sx_num_rel の内部実装。
##   引数チェックを行わずに数値と演算子の関係を順次評価する。

define([|CLEANUP|], [|Q_op Q_lhs Q_lcls Q_rcls Q_arg|])dnl

__sx_num_rel() {
	Q_op='eq'

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			eq | '==') Q_op=eq;;
			ne | '!=') Q_op=ne;;
			lt | '<')  Q_op=lt;;
			le | '<=') Q_op=le;;
			gt | '>')  Q_op=gt;;
			ge | '>=') Q_op=ge;;
			*) ! :;;
		esac && continue

		__sx_num_rel_classify "${Q_arg}" || Q_rcls="${?}"

		case "${Q_rcls}" in
			1) : $((Q_arg += 0));;
			2) Q_arg="${Q_arg#+}";;
			*)
				__sx_num_norm Q_arg "${Q_arg}"
				__sx_num_rel_classify "${Q_arg}" || Q_rcls="${?}"
				;;
		esac

		case "${Q_lhs+X}" in X)
			case "${Q_lcls}:${Q_rcls}" in
				1:1) __sx_num_cmp_arith "${Q_lhs}" "${Q_arg}";;
				*) __sx_num_cmp_fixed "${Q_lhs}" "${Q_arg}";;
			esac || case "${Q_op}:${?}" in
				eq:2 | ne:1 | ne:3 | lt:1 | le:1 | le:2 | gt:3 | ge:2 | ge:3) ;;
				*)
					unset CLEANUP
					return 1
					;;
			esac
		esac

		Q_lcls="${Q_rcls}"
		Q_lhs="${Q_arg}"
	done

	unset CLEANUP
}
|], [|num_rel|])dnl

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

M_RENAME_Q([|dnl
### sx_num_sub_int - 複数の符号付き整数を減算する
##
## 使い方:
##   sx_num_sub_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   符号付き10進整数を減算する（第1引数から残りの引数を順次減算）。
##   内部で第2引数以降を __sx_num_add_int で合計し、第1引数と符号付き減算する。
##
## 終了ステータス:
##   0  成功 (SX_EX_OK)
##  64  引数不正 (SX_EX_USAGE) — 整数として不正な値が含まれる
##  77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##  78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_res|])dnl

sx_num_sub_int() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_sub_int "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_int_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_sub_int "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_sub_int|])dnl

M_RENAME_QI([|dnl
### __sx_num_sub_int - 複数の符号付き整数を減算する（内部用）
##
## 使い方:
##   __sx_num_sub_int 結果変数名 [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_sub_int の内部実装。引数チェックは行わない。
##   第2引数以降を __sx_num_add_int で合計し、第1引数と符号付き減算する。
##   符号の組み合わせに応じて __sx_num_cmp_nat0 / __sx_num_sub_nat0 /
##   __sx_num_add_nat0 で絶対値の演算を行う。

define([|CLEANUP|], [|Q_res Q_first Q_sign Q_sum Q_tmp|])dnl

__sx_num_sub_int() {
	Q_res="${1}"
	Q_first="${2-0}"
	Q_sign=

	shift "$((1 + 0${2+1}))"

	# $2...$n の合計（符号付き加算）
	__sx_num_add_int Q_sum "${@}"

	# 合計が 0 なら第1引数がそのまま結果
	case "${Q_sum}" in 0)
		M_VAR_SET([|${Q_res}|], [|${Q_first#+}|])
		unset CLEANUP
		return
	esac

	# a - sum を符号の組み合わせ4ケースに分けて直接演算
	case "${Q_first}${Q_sum}" in
		# ケース4: (-a) - (-s) = |s| - |a|
		-*-*)
			__sx_num_cmp_nat0 "${Q_first#-}" "${Q_sum#-}" || case "${?}" in
				1) __sx_num_sub_nat0 Q_tmp "${Q_sum#-}" "${Q_first#-}";;
				3)
					Q_sign='-'
					__sx_num_sub_nat0 Q_tmp "${Q_first#-}" "${Q_sum#-}"
					;;
			esac
			;;
		# ケース3: (-a) - s = -(a + s)
		-*) Q_sign='-';&
		# ケース2: a - (-s) = a + s
		*-*) __sx_num_add_nat0 Q_tmp "${Q_first#[+-]}" "${Q_sum#-}";;
		# ケース1: a - s
		*)
			__sx_num_cmp_nat0 "${Q_first#+}" "${Q_sum}" || case "${?}" in
				1)
					Q_sign='-'
					__sx_num_sub_nat0 Q_tmp "${Q_sum}" "${Q_first#+}"
					;;
				3) __sx_num_sub_nat0 Q_tmp "${Q_first#+}" "${Q_sum#+}";;
			esac
			;;
	esac

	M_VAR_SET([|${Q_res}|], [|${Q_sign}${Q_tmp-0}|])
	unset CLEANUP
}
|], [|num_sub_int|])dnl

M_RENAME_Q([|dnl
### sx_num_sub_nat0 - 2つの絶対値の差（被減数 - 減数）を計算する
##
## 使い方:
##   sx_num_sub_nat0 結果変数名 被減数 減数
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

define([|CLEANUP|], [|Q_res|])dnl

sx_num_sub_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_sub_nat0 "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	Q_res="${1}"
	shift

	__sx_num_is_nat0_base 10 "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_num_cmp_nat0 "${1-0}" "${2-0}" || case "${?}" in 1)
		unset CLEANUP
		return M_EX_USAGE
	esac

	__sx_num_sub_nat0 "${Q_res}" "${@}"
	unset CLEANUP
}
|], [|num_sub_nat0|])dnl

M_RENAME_QI([|dnl
### __sx_num_sub_nat0 - 絶対値のチャンク減算を行う（内部用）
##
## 使い方:
##   __sx_num_sub_nat0 結果変数名 被減数 減数
##
## 説明:
##   符号なし10進整数の絶対値（被減数 - 減数）を減算する。
##   引数はすべて検証済みの正しい10進整数であることを前提とする。
##   被減数 >= 減数 が保証されていること。

define([|CLEANUP|], [|Q_res Q_borrow Q_out Q_rem1 Q_rem2 Q_ch1 Q_ch2 Q_tmp|])dnl

__sx_num_sub_nat0() {
	Q_res="${1}"
	Q_rem1="${2-0}"
	Q_rem2="${3-0}"
	Q_borrow=0
	Q_out=

	while
		case "${Q_rem1}" in
			${SX_SYS_NUM_QM}?*)
				Q_tmp="${Q_rem1%${SX_SYS_NUM_QM}}"
				Q_ch1="${Q_rem1#"${Q_tmp}"}"
				Q_rem1="${Q_tmp}"

				case "${Q_ch1}" in 0*)
					Q_ch1=$((1${Q_ch1} - 1${SX_SYS_NUM_ZR}))
				esac
				;;
			*)
				Q_ch1="${Q_rem1}"
				Q_rem1=
				;;
		esac

		case "${Q_rem2}" in
			${SX_SYS_NUM_QM}?*)
				Q_tmp="${Q_rem2%${SX_SYS_NUM_QM}}"
				Q_ch2="${Q_rem2#"${Q_tmp}"}"
				Q_rem2="${Q_tmp}"

				case "${Q_ch2}" in 0*)
					Q_ch2=$((1${Q_ch2} - 1${SX_SYS_NUM_ZR}))
				esac
				;;
			*)
				Q_ch2="${Q_rem2}"
				Q_rem2=
				;;
		esac

		Q_tmp=$((${Q_ch1:-0} - ${Q_ch2:-0} - Q_borrow))
		Q_borrow=$((Q_tmp < 0))

		case "${Q_borrow}:${Q_rem1}:${Q_rem2}" in
			0::)
				# 両方の剰余が枯渇 → tmp_ が最上位桁、先頭ゼロ除去のみでゼロ埋め不要
				case "${Q_tmp}" in [!0]*)
					M_STR_PREPEND([|Q_out|], [|"${Q_tmp}"|])
				esac

				break
				;;
			0:*:)
				case "${Q_tmp}" in
					${SX_SYS_NUM_QM}*) M_STR_PREPEND([|Q_out|], [|"${Q_rem1}${Q_tmp}"|]);;
					*)
						# rem2 のみ枯渇、rem1 に未処理チャンクあり → ゼロ埋めして桁揃え
						M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
						M_STR_PREPEND([|Q_out|], [|"${Q_rem1}${Q_tmp#1}"|])
						;;
				esac

				break
				;;
			1:*) M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|]);&
			*)
				case "${Q_tmp}" in
					${SX_SYS_NUM_QM}*) M_STR_PREPEND([|Q_out|], [|"${Q_tmp}"|]);;
					*)
						M_NUM_INCR([|Q_tmp|], [|1${SX_SYS_NUM_ZR}|])
						M_STR_PREPEND([|Q_out|], [|"${Q_tmp#1}"|])
						;;
				esac
				;;
		esac

		continue
	do :; done

	M_VAR_SET([|${Q_res}|], [|${Q_out:-0}|])

	unset CLEANUP
}
|], [|num_sub_nat0|])dnl

M_RENAME_Q([|dnl
### sx_num_sub1_nat0 - 正の整数から1を減算する
##
## 使い方:
##   sx_num_sub1_nat0 結果変数名 数値
##
## 説明:
##   符号なし10進整数から1を減算する。
##   引数の検証を行い、1以上の符号なし整数（nat1）であることを確認する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

sx_num_sub1_nat0() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_sub1_nat0 "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat1_base 10 "${2-}" || return M_EX_USAGE

	__sx_num_sub1_nat0 "$1" "$2"
}
|], [|num_sub1_nat0|])dnl

M_RENAME_QI([|dnl
### __sx_num_sub1_nat0 - 正の整数から1を減算する（内部用）
##
## 使い方:
##   __sx_num_sub1_nat0 結果変数名 数値
##
## 説明:
##   sx_num_sub1_nat0 の内部実装。引数の検証を行わない。
##   SX_CFG_NUM_RANGE に応じて、ネイティブ算術または __sx_num_sub_nat0 に委譲する。

__sx_num_sub1_nat0() {
	case "${SX_CFG_NUM_RANGE}" in
		32)
			case "$2" in
				?????????*) __sx_num_sub_nat0 "$1" "$2" 1;;
				*) : "$(($1 = $2 - 1))";;
			esac
			;;
		64)
			case "$2" in
				??????????????????*) __sx_num_sub_nat0 "$1" "$2" 1;;
				*) : "$(($1 = $2 - 1))";;
			esac
			;;
		128)
			case "$2" in
				??????????????????????????????????????*) __sx_num_sub_nat0 "$1" "$2" 1;;
				*) : "$(($1 = $2 - 1))";;
			esac
			;;
	esac
}
|], [|num_sub1_nat0|])dnl

# ========================================
#  UUID (UUID Operations)
# ========================================

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arg|])dnl

sx_uuid_is_uuid() {
	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]) ;;
			*)
				unset CLEANUP
				return 1
				;;
		esac
	done

	unset CLEANUP
}
|], [|uuid_is_uuid|])dnl

# ========================================
#  STR (String Operations)
# ========================================

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_any() {
	Q_tgt="${1-}"
	shift "$((0 < ${#}))"

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in "${Q_arg}")
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_any|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_camel() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_camel "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_camel "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_camel - さまざまな命名規則を camelCase に変換する（内部用）
##
## 使い方:
##   __sx_str_camel 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   sx_str_camel の内部実装。引数チェックは行わない。
##   sx_str_words で単語分割し、先頭に _ を前置して sx_str_title で
##   タイトルケース化した後、_ を除去して sx_str_squish で空白を除去する。

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_camel() {
	set -- "${1}" "${2-}" "${3:-"_-/.:${SX_STR_SPACE}"}"

	__sx_str_words Q_tmp "${2}" ' ' "${3}"
	__sx_str_title Q_tmp "_${Q_tmp}" ' '
	__sx_str_squish "${1}" "${Q_tmp#?}" ' ' ''

	unset CLEANUP
}
|], [|str_camel|])dnl

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
##   64  引数不正 (SX_EX_USAGE)
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_capital() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_capital "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_nat0_safe ${3:+"${3}"} || return M_EX_USAGE

	__sx_str_capital "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_capital - sx_str_capital の内部実装（内部用）
##
## 使い方:
##   __sx_str_capital 結果変数名 [元文字列 [フラグ]]
##
## 説明:
##   sx_str_capital の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_str Q_out Q_tmp|])dnl

__sx_str_capital() {
	set -- "${1}" "${2-}" "${3:-0}"
	Q_str="${2}"
	Q_out=

	case "$(((${3} & SX_STR_CAPITAL_SENT) != 0))${2}" in 0["${SX_STR_ALPHA}"]* | 1*["${SX_STR_ALPHA}"]*)
		Q_out="${2%%["${SX_STR_ALPHA}"]*}"
		Q_str="${2#"${Q_out}"}"
		__sx_str_upper_cb Q_tmp "${Q_str%"${Q_str#?}"}"
		M_STR_APPEND([|Q_out|], [|"${Q_tmp}"|])
		Q_str="${Q_str#?}"
	esac

	case "$((${3} & SX_STR_CAPITAL_KEEP))" in 0)
		__sx_str_lower Q_str "${Q_str}"
	esac

	M_VAR_SET([|${1}|], [|${Q_out}${Q_str}|])
	unset CLEANUP
}
|], [|str_capital|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_center() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_center "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} ${4+"${#4}"} ${5+"${#5}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3+"${3}"} || return M_EX_USAGE

	__sx_str_center "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_center - 文字列を指定された幅で中央寄せする（内部用）
##
## 使い方:
##   __sx_str_center 結果変数名 文字列 幅 [左埋め文字列 [右埋め文字列]]
##
## 説明:
##   sx_str_center の内部実装。
##   引数チェックは行わないが、左右の埋め文字が両方とも空の場合は何もせず成功を返す。
##   $5 が未指定の場合、最適化パス（左と同じfillで1回のstr_rep）を使用する。

define([|CLEANUP|], [|Q_needed Q_lpad Q_rpad Q_lrep Q_rrep Q_spad Q_epad|])dnl

__sx_str_center() {
	set -- "${1}" "${2-}" "${3-0}" "${4- }" "${5-${4- }}"

	Q_needed=$((${3#-} - ${#2}))

	case "$((0 < Q_needed))${4}${5}" in 0* | 1)
		M_VAR_SET([|${1}|], [|${2}|])
		unset Q_needed
		return M_EX_OK
	esac

	Q_lpad=$(( (Q_needed + (${3} < 0)) / 2 ))
	Q_rpad=$(( Q_needed - Q_lpad ))

	case "${4}" in ?*)
		__sx_str_rep Q_lrep "${4}" "$((((Q_needed + 1) / 2 - 1) / ${#4} + 1))"
	esac

	case "${5}" in
		"${4}") Q_rrep="${Q_lrep}";;
		?*) __sx_str_rep Q_rrep "${5}" "$(((Q_rpad - 1) / ${#5} + 1))";;
	esac

	__sx_str_substr Q_spad "${Q_lrep-}" 0 "${Q_lpad}"
	__sx_str_substr Q_epad "${Q_rrep-}" 0 "${Q_rpad}"

	M_VAR_SET([|${1}|], [|${Q_spad}${2}${Q_epad}|])

	unset CLEANUP
}
|], [|str_center|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  スキーマに含まれる変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_chunk() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_chunk "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_nat0_safe ${4:+"${4}"} ${5:+"${5}"} || return M_EX_USAGE

	case "${3:-1}" in
		*[1-9ABCDEFabcdef]*) ;;
		*) return M_EX_USAGE;;
	esac

	__sx_str_split __sx_str_chunk_ints "${3:-1}" :
	if ! eval __sx_num_is_int_safe_inv "${__sx_str_chunk_ints}"; then
		unset __sx_str_chunk_ints
		return M_EX_USAGE
	fi

	unset __sx_str_chunk_ints

	__sx_str_chunk "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_chunk - 文字列を一定の長さで区切って結果変数に格納する（内部用）
##
## 使い方:
##   __sx_str_chunk 結果変数名 [文字列 [長さ [分割回数]]]
##
## 説明:
##   sx_str_chunk の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_str Q_cycle Q_lim Q_len Q_bwd Q_newcycle Q_cur Q_qm Q_abs Q_next Q_chunk|])dnl

__sx_str_chunk() {
	set -- "${1}" "${2-}" "${3-1}" "${4:-${SX_NUM_I32_MAX}}" "${5:-0}"
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2-}"
	Q_cycle="${3}:"
	Q_lim="${4}"
	Q_len="${#Q_str}"
	Q_bwd=

	# プリパス: interval に ? パターンを埋め込む (1:-2:3 → 1?:-2??:3???:)
	Q_newcycle=
	while M_STR_HAS([|"${Q_cycle}"|], [|:|]); do
		Q_cur="${Q_cycle%%:*}"
		Q_cycle="${Q_cycle#*:}"

		__sx_str_qm Q_qm "${Q_cur#-}"
		M_STR_APPEND([|Q_newcycle|], [|"$((0 <= Q_cur))${Q_qm}:"|])
	done

	Q_cycle="${Q_newcycle}"

	# 第1パス: 文字列長・limit から切り取りサイズリストを構築
	while
		Q_cur="${Q_cycle%%:*}" &&
		Q_qm="${Q_cur#?}" &&
		Q_abs="${#Q_qm}" &&
		M_NUM_BOOL([|Q_abs <= Q_len && 0 < Q_lim|])
	do
		Q_cycle="${Q_cycle#*:}${Q_cur}:"
		: $((Q_len -= Q_abs))
		M_NUM_DECR([|Q_lim|])

		case "${Q_cur}" in 0*)
			M_STR_PREPEND([|Q_bwd|], [|"'${Q_qm}' "|])
			continue
		esac

		Q_next="${Q_str#${Q_qm}}"

		__sx_var_bind Q_bind "${Q_bind}" "${Q_str%"${Q_next}"}" || {
			unset CLEANUP
			return M_EX_OK
		}

		Q_str="${Q_next}"
	done

	# 余り処理: limit 到達 or 文字列不足
	if M_NUM_LT([|0|], [|Q_len|]); then
		__sx_str_qm Q_qm "${Q_len}"

		case "$((
			(Q_len < Q_abs && ${5} & SX_STR_CHUNK_SKIP_SHORT) ||
			(Q_abs < Q_len && ${5} & SX_STR_CHUNK_SKIP_LONG)
		))" in
			0) eval set -- '"${Q_qm}"' "${Q_bwd}";;
		*)
			Q_str="${Q_str#${Q_qm}}"
			eval set -- "${Q_bwd}"
			;;
		esac
	else
		eval set -- "${Q_bwd}"
	fi

	# 第2パス: 切り取りリストを左から処理
	for Q_qm in "${@}"; do
		Q_next="${Q_str#${Q_qm}}"
		Q_chunk=

		__sx_var_bind Q_bind "${Q_bind}" "${Q_str%"${Q_next}"}" || :

		Q_str="${Q_next}"
	done

	unset CLEANUP
}
|], [|str_chunk|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_count() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_count "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_nat0_safe ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_count "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_str_count - 文字列から指定された文字列の出現回数を取得する（内部用）
##
## 使い方:
##   __sx_str_count 結果変数名 [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_count の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_count() {
	__sx_str_find Q_tmp "${2-}" "${3-}" "${4:-0}" || :
	eval __sx_arg_len '"${1}"' "${Q_tmp}"
	unset CLEANUP
}
|], [|str_count|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_cycle() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_cycle "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3:+"${3}"} || return M_EX_USAGE

	__sx_str_cycle "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_cycle - sx_str_cycle の内部実装（内部用）
##
## 使い方:
##   __sx_str_cycle 結果変数名 [元文字列 [シフト量]]
##
## 説明:
##   sx_str_cycle の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_head Q_tail|])dnl

__sx_str_cycle() {
	set -- "${1}" "${2-}" "${3:-1}"
	set -- "${@}" "${#2}"
	set -- "${1}" "${2}" "$((${3} % (${4} ? ${4} : 1)))" "${4}"

	case ${3} in 0)
		M_VAR_SET([|${1}|], [|${2}|])
		return M_EX_OK
	esac

	__sx_str_chunk Q_head:Q_tail: "${2}" "$((0 < ${3} ? ${3} : ${3} + ${4}))" 1
	M_VAR_SET([|${1}|], [|${Q_tail}${Q_head}|])

	unset CLEANUP
}
|], [|str_cycle|])dnl

M_RENAME_Q([|dnl
### sx_str_eq - すべての引数が文字列として一致するか確認する
##
## 使い方:
##   sx_str_eq [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて一致する (または引数が1つ以下)
##    1  一致しない文字列が含まれる

define([|CLEANUP|], [|Q_first Q_arg|])dnl

sx_str_eq() {
	Q_first="${1-}"
	shift "$((0 < ${#}))"

	for Q_arg in "${@}"; do
		case "${Q_arg}" in
			"${Q_first}") ;;
			*)
				unset CLEANUP
				return 1
				;;
		esac
	done

	unset CLEANUP
}
|], [|str_eq|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_escape() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_escape "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_escape "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_escape - 文字列内の指定された文字をエスケープする（内部用）
##
## 使い方:
##   __sx_str_escape 結果変数名 [元文字列 [エスケープ対象文字集合 [開始エスケープ文字列 [終了エスケープ文字列]]]]
##
## 説明:
##   sx_str_escape の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_gs|])dnl

__sx_str_escape() {
	set -- "${1}" "${2-}" "${3-}" "${4:-\\}" "${5:-}"

	case "${3}" in '')
		M_VAR_SET([|${1}|], [|${2}|])
		return M_EX_OK
	esac

	__sx_glob_bracket Q_gs "${3}"

	Q_cb_se="${4}" Q_cb_ee="${5}" __sx_str_sub "${1}:" "${2}" "${Q_gs}" __sx_str_escape_cb '' "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"

	unset CLEANUP
}
|], [|str_escape|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_etrim() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_etrim "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

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
		M_VAR_SET([|${1}|], [|${2}|])
		return M_EX_OK
	esac

	M_VAR_SET([|${1}|], [|M_STR_RTRIM([|2|], [|[!"${3}"]|])|])
}

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_ew() {
	Q_tgt="${1-}"
	shift "$((0 < ${#}))"

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in *"${Q_arg}")
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_ew|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_find() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_find "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_nat0_safe ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_find "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_str_find - 文字列から指定された文字列を前方一致で探す（内部用）
##
## 使い方:
##   __sx_str_find 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_find の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_tgt Q_off Q_pre Q_sts Q_match Q_after Q_text Q_overlap|])dnl

__sx_str_find() {
	set -- "${1}" "${2-}" "${3-}" "${4:-0}"
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_tgt="${2}"
	Q_text=$((${4} & SX_STR_FIND_TEXT))
	Q_overlap=$((${4} & SX_STR_FIND_OVERLAP))
	Q_off=0

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${4} & SX_STR_FIND_GLOB|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		Q_sts=M_EX_OK

		# 空 needle: 全境界位置（0 〜 len）に長さ0で出力
		while M_NUM_LE([|Q_off|], [|${#Q_tgt}|]); do
			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_off}:0" || :;;
				*) __sx_var_bind Q_bind "${Q_bind}" '' || :;;
			esac

			M_NUM_INCR([|Q_off|])
		done
	elif M_NUM_BOOL([|${4} & SX_STR_FIND_GLOB|]); then
		# ==== グロブモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|${3}|]); do
			# マッチ文字列を抽出（__sx_str_sub_cb と同じ手法）
			Q_pre="${Q_tgt%%${3}*}"
			Q_after="${Q_tgt#*${3}}"
			Q_match="${Q_tgt#"${Q_pre}"}"
			Q_match="${Q_match%"${Q_after}"}"
			M_NUM_INCR([|Q_off|], [|${#Q_pre}|])
			: "${Q_sts=M_EX_OK}"

			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_off}:${#Q_match}" || :;;
				*) __sx_var_bind Q_bind "${Q_bind}" "${Q_match}" || :;;
			esac

			case "${Q_overlap}" in
				0)
					: $((Q_off += ${#Q_match}))
					Q_tgt="${Q_tgt#"${Q_pre}${Q_match}"}"
					;;
				*)
					M_NUM_INCR([|Q_off|])
					Q_tgt="${Q_tgt#"${Q_pre}"?}"
					;;
			esac
		done
	else
		# ==== リテラルモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|"${3}"|]); do
			Q_pre="${Q_tgt%%"${3}"*}"
			M_NUM_INCR([|Q_off|], [|${#Q_pre}|])
			: "${Q_sts=M_EX_OK}"

			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_off}:${#3}" || :;;
				*) __sx_var_bind Q_bind "${Q_bind}" "${3}" || :;;
			esac

			case "${Q_overlap}" in
				0)
					: $((Q_off += ${#3}))
					Q_tgt="${Q_tgt#*"${3}"}"
					;;
				*)
					M_NUM_INCR([|Q_off|])
					Q_tgt="${Q_tgt#"${Q_pre}"?}"
					;;
			esac
		done
	fi

	set -- "${Q_sts-1}"
	unset CLEANUP
	return "${1}"
}
|], [|str_find|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_has() {
	Q_tgt="${1-}"
	shift "$((0 < ${#}))"

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in *"${Q_arg}"*)
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_has|])dnl

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

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_charset Q_arg|])dnl

sx_str_is_of() {
	Q_charset="${1}"
	shift

	for Q_arg in "${@}"; do
		case "${Q_arg}" in '' | *[!"${Q_charset}"]*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|str_is_of|])dnl

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
##   sx_str_isep バインド形式 文字列 セパレータ [インターバル [リミット [フラグ]]]
##
## 説明:
##   指定された文字列に対して、指定された間隔（インターバル）ごとにセパレータを挿入して結合する。
##   インターバルが正の場合は前方から、負の場合は後方から数えて挿入する。
##   リミットを指定すると、セパレータの挿入回数を制限できる。
##   インターバルに 0 は指定できない。デフォルトのインターバルは 1。
##   バインド形式で挿入結果と挿入回数を取得できる。
##   例: res:（結果のみ）、res:cnt（結果と回数）。
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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_isep "${@}" || return; return; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${4:+"${4}"} && __sx_num_is_nat0_safe ${5:+"${5}"} ${6:+"${6}"} || return M_EX_USAGE

	case "$((${4:-1}))" in 0)
		return M_EX_USAGE
	esac

	__sx_str_isep "${@}" || return
}

### __sx_str_isep - 文字列に一定の間隔でセパレータを挿入する（内部用）
##
## 使い方:
##   __sx_str_isep バインド形式 文字列 セパレータ [インターバル [リミット [フラグ]]]
##
## 説明:
##   sx_str_isep の内部実装。
##   引数チェックは行わない。
__sx_str_isep() {
	# 位置パラメータ構成:
	# ${1}: bind, ${2}: str, ${3}: sep/cb, ${4}: int, ${5}: lim, ${6}: flags
	# ${7}: out, ${8}: qm, ${9}: count, ${10}: ctx, ${11}: stat
	# 文字列が空の場合は、重複防止のため POST (int>0) または PRE (int<0) フラグを無効化する
	set -- "${1}" "${2-}" "${3-}" "${4:-1}" "${5:-${SX_NUM_I32_MAX}}" "$((${6:-0} & (${#2} != 0 ? ~0 : (${4:-1} > 0 ? ~SX_STR_ISEP_POST : ~SX_STR_ISEP_PRE))))" '' '' 0 ''

	case "$((${6} & SX_STR_ISEP_CB))" in
		0) __sx_str_isep_lit "${@}";;
		*) __sx_str_isep_cb "${@}";;
	esac || return
}

M_RENAME_QI([|dnl
### __sx_str_isep_cb - 文字列に一定の間隔でセパレータを挿入する（コールバックモード、内部用）
##
## 使い方:
##   __sx_str_isep_cb バインド形式 文字列 セパレータ インターバル リミット フラグ out qm count ctx stat
##
## 説明:
##   __sx_str_isep からコールバックモードを抽出した内部関数。
##   バインド形式で挿入結果と成功挿入回数を取得できる。

define([|CLEANUP|], [|Q_ret|])dnl

__sx_str_isep_cb() {
	# 位置パラメータ構成:
	# ${1}: bind, ${2}: str, ${3}: cb, ${4}: int, ${5}: lim, ${6}: flags
	# ${7}: out, ${8}: qm, ${9}: count, ${10}: ctx, ${11}: stat
	#
	# コールバックモードではセパレータの代わりに $3 をコールバック関数名として扱う。
	# 各挿入位置で callback "結果変数" left right count を呼び出し、
	# 戻り値（Q_ret）を挿入文字列として使用する。
	# コールバックが非0を返した場合、stat=$? に記録し、残リミット(${5})を 0 にして
	# 以降の挿入を抑止する。挿入回数(${9})は成功数のまま残るため、そのまま bind できる。

	if M_NUM_LT([|0|], [|${4}|]); then
		# === Forward: 先頭から interval 文字ごとに区切る ===
		# PRE: callback('', str, count+1) → 戻り値を追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_PRE && ${9} < ${5}|]); then
			"${3}" Q_ret '' "${2}" "$((${9} + 1))" && \
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${Q_ret-}" "${8}" "$((${9} + 1))" "${10}" || \
			set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${7}" "${8}" "${9}" "${10}" "${?}"

			unset CLEANUP
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_LT([|${9}|], [|${5}|]); then
			__sx_str_qm __sx_str_isep_qm_ "${4}"
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${__sx_str_isep_qm_}" "${9}" "${10}"
			unset __sx_str_isep_qm_

			while M_STR_MATCH([|"${2}"|], [|${8}?*|]) && M_NUM_LT([|${9}|], [|${5}|]); do
				set -- "${@}" "${2#${8}}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "$((${9} + 1))" "${10}" "${2%"${11}"}"

				"${3}" Q_ret "${10}${11}" "${2}" "${9}" && \
				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${11}${Q_ret-}" "${8}" "${9}" "${10}${11}" || \
				set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${7}${11}" "${8}" "$((${9} - 1))" "${10}${11}" "${?}"

				unset CLEANUP
			done
		fi

		# 残り文字列
		set -- "${1}" '' "${3}" "${4}" "${5}" "${6}" "${7}${2}" "${8}" "${9}" "${10}${2}" ${11+"${11}"}

		# POST: callback(ctx, '', count+1) → 戻り値を追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_POST && ${9} < ${5} && (${#10} % ${4}) == 0|]); then
			"${3}" Q_ret "${10}" '' "$((${9} + 1))" && \
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${Q_ret-}" "${8}" "$((${9} + 1))" "${10}" || \
			set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${7}" "${8}" "${9}" "${10}" "${?}"
			unset CLEANUP
		fi
	else
		# === Backward: 末尾から interval 文字ごとに区切る ===
		# POST: callback(str, '', count+1) → 戻り値を前に追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_POST && ${9} < ${5}|]); then
			"${3}" Q_ret "${2}" '' "$((${9} + 1))" && \
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${Q_ret-}${7}" "${8}" "$((${9} + 1))" "${10}" || \
			set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${7}" "${8}" "${9}" "${10}" "${?}"
			unset CLEANUP
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_LT([|${9}|], [|${5}|]); then
			__sx_str_qm __sx_str_isep_qm_ "${4#-}"
			set -- "${1}" "${2}" "${3}" "${4#-}" "${5}" "${6}" "${7}" "${__sx_str_isep_qm_}" "${9}" "${10}"
			unset __sx_str_isep_qm_

			while M_STR_MATCH([|"${2}"|], [|${8}?*|]) && M_NUM_LT([|${9}|], [|${5}|]); do
				set -- "${@}" "${2%${8}}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "$((${9} + 1))" "${10}" "${2#"${11}"}"

				"${3}" Q_ret "${2}" "${11}${10}" "${9}" && \
				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${Q_ret-}${11}${7}" "${8}" "${9}" "${11}${10}" || \
				set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${11}${7}" "${8}" "$((${9} - 1))" "${11}${10}" "${?}"
				unset CLEANUP
			done
		fi

		# 残り文字列
		set -- "${1}" '' "${3}" "${4}" "${5}" "${6}" "${2}${7}" "${8}" "${9}" "${2}${10}" ${11+"${11}"}

		# PRE: callback('', ctx, count+1) → 戻り値を前に追加
		if M_NUM_BOOL([|${6} & SX_STR_ISEP_PRE && ${9} < ${5} && (${#10} % ${4}) == 0|]); then
			"${3}" Q_ret '' "${10}" "$((${9} + 1))" && \
			set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${Q_ret-}${7}" "${8}" "$((${9} + 1))" "${10}" || \
			set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${7}" "${8}" "${9}" "${10}" "${?}"
			unset CLEANUP
		fi
	fi

	__sx_var_bind_init "${1}"
	__sx_var_bind '' "${1}" "${7}" "${9}" || :

	unset CLEANUP

	return "${11-0}"
}
|], [|str_isep_cb|])dnl

M_RENAME_QI([|dnl
### __sx_str_isep_lit - 文字列に一定の間隔でセパレータを挿入する（リテラルモード、内部用）
##
## 使い方:
##   __sx_str_isep_lit バインド形式 文字列 セパレータ インターバル リミット フラグ out qm
##
## 説明:
##   __sx_str_isep からリテラルモードを抽出した内部関数。
##   バインド形式で挿入結果と挿入回数を取得できる。

define([|CLEANUP|], [|Q_bind Q_str Q_sep Q_int Q_lim Q_flg Q_out Q_qm Q_cnt|])dnl

__sx_str_isep_lit() {
	# 名前付き変数で状態を管理する（速度優先）。
	# __sx_str_isep_cb とは対照的に位置パラメータを使わない。

	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2}"
	Q_sep="${3}"
	Q_int="${4}"
	Q_lim="${5}"
	Q_flg="${6}"
	Q_out=
	Q_cnt=0

	if M_NUM_LT([|0|], [|Q_int|]); then
		# === Forward: 先頭から interval 文字ごとに区切る ===
		# PRE: 先頭の境界
		if M_NUM_BOOL([|Q_flg & SX_STR_ISEP_PRE && Q_cnt < Q_lim|]); then
			Q_out="${Q_sep}"
			M_NUM_INCR([|Q_cnt|])
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_LT([|Q_cnt|], [|Q_lim|]); then
			__sx_str_qm Q_qm "${Q_int}"

			while M_STR_MATCH([|"${Q_str}"|], [|${Q_qm}?*|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
				M_STR_APPEND([|Q_out|], [|"${Q_str%"${Q_str#${Q_qm}}"}${Q_sep}"|])
				Q_str="${Q_str#${Q_qm}}"
				M_NUM_INCR([|Q_cnt|])
			done
		fi

		# 残り文字列を末尾に追加
		M_STR_APPEND([|Q_out|], [|"${Q_str}"|])

		# POST: 末尾の境界（count < lim かつ 残り文字列長 % interval == 0）
		if M_NUM_BOOL([|Q_flg & SX_STR_ISEP_POST && Q_cnt < Q_lim && (${#Q_str} % Q_int) == 0|]); then
			M_STR_APPEND([|Q_out|], [|"${Q_sep}"|])
			M_NUM_INCR([|Q_cnt|])
		fi
	else
		# === Backward: 末尾から interval 文字ごとに区切る ===
		# POST: 末尾の境界（後方処理では最初に処理する境界）
		if M_NUM_BOOL([|Q_flg & SX_STR_ISEP_POST && Q_cnt < Q_lim|]); then
			Q_out="${Q_sep}"
			M_NUM_INCR([|Q_cnt|])
		fi

		# ループ要なら QM を生成してループ実行
		if M_NUM_LT([|Q_cnt|], [|Q_lim|]); then
			__sx_str_qm Q_qm "${Q_int#-}"

			while M_STR_MATCH([|"${Q_str}"|], [|${Q_qm}?*|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
				M_STR_PREPEND([|Q_out|], [|"${Q_sep}${Q_str#"${Q_str%${Q_qm}}"}"|])
				Q_str="${Q_str%${Q_qm}}"
				M_NUM_INCR([|Q_cnt|])
			done
		fi

		# 残り文字列を先頭に追加
		M_STR_PREPEND([|Q_out|], [|"${Q_str}"|])

		# PRE: 先頭の境界（後方処理では最後に処理する境界）
		if M_NUM_BOOL([|Q_flg & SX_STR_ISEP_PRE && Q_cnt < Q_lim && (${#Q_str} % Q_int) == 0|]); then
			M_STR_PREPEND([|Q_out|], [|"${Q_sep}"|])
			M_NUM_INCR([|Q_cnt|])
		fi
	fi

	__sx_var_bind '' "${Q_bind}" "${Q_out}" "${Q_cnt}" || :

	unset CLEANUP
}
|], [|str_isep_lit|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_lower() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_lower "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3:+"${3}"} || return M_EX_USAGE

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
		U) eval "${1}=u";; [|V|]) eval "${1}=v";;
		W) eval "${1}=w";; X) eval "${1}=x";;
		Y) eval "${1}=y";; Z) eval "${1}=z";;
		*) eval "${1}=\"\${2}\"";;
	esac
}

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_match() {
	Q_tgt="${1-}"
	shift "$((0 < ${#}))"

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in ${Q_arg})
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_match|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_pad() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_pad "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} ${4+"${#4}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3+"${3}"} || return M_EX_USAGE

	__sx_str_pad "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_pad - 文字列を指定された長さになるように埋める（内部用）
##
## 使い方:
##   __sx_str_pad 結果変数名 文字列 長さ [埋め込み文字列]
##
## 説明:
##   sx_str_pad の内部実装。
##   引数チェックは行わないが、埋め込み文字列が空の場合は何もせず成功を返す。

define([|CLEANUP|], [|Q_needed Q_rep Q_fill|])dnl

__sx_str_pad() {
	set -- "${1}" "${2-}" "${3-0}" "${4- }"

	Q_needed=$((${3#-} - ${#2}))

	M_NUM_LT([|0|], [|Q_needed|]) && M_STR_NE([|"${4}"|], [|''|]) || {
		M_VAR_SET([|${1}|], [|${2}|])
		unset Q_needed
		return M_EX_OK
	}

	__sx_str_rep Q_rep "${4}" "$(((Q_needed - 1) / ${#4} + 1))"
	__sx_str_substr Q_fill "${Q_rep}" 0 "${Q_needed}"

	case "${3}" in
		-*) M_VAR_SET([|${1}|], [|${2}${Q_fill}|]);;
		*) M_VAR_SET([|${1}|], [|${Q_fill}${2}|]);;
	esac

	unset CLEANUP
}
|], [|str_pad|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_pascal() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_pascal "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_pascal "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_pascal - さまざまな命名規則を PascalCase に変換する（内部用）
##
## 使い方:
##   __sx_str_pascal 結果変数名 [元文字列 [区切り文字セット]]
##
## 説明:
##   sx_str_pascal の内部実装。引数チェックは行わない。
##   sx_str_words で単語分割し、sx_str_title でタイトルケース化し、
##   sx_str_squish で空白を除去して結合する。

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_pascal() {
	set -- "${1}" "${2-}" "${3:-"_-/.:${SX_STR_SPACE}"}"

	__sx_str_words Q_tmp "${2}" ' ' "${3}"
	__sx_str_title Q_tmp "${Q_tmp}" ' '
	__sx_str_squish "${1}" "${Q_tmp}" ' ' ''

	unset CLEANUP
}
|], [|str_pascal|])dnl

### sx_str_quote - 文字列をシングルクォートで囲む
##
## 使い方:
##   sx_str_quote 結果変数名 [元文字列]
##
## 説明:
##   元文字列をシングルクォートで囲み、内部のシングルクォートを
##   '\'' 形式に置換して結果変数に格納する。
##   元文字列が省略された場合は、空文字列を引用した '' を格納する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_quote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_quote "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_str_quote "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_quote - 文字列をシングルクォートで囲む（内部用）
##
## 使い方:
##   __sx_str_quote 結果変数名 [元文字列]
##
## 説明:
##   sx_str_quote の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_str Q_out|])dnl

__sx_str_quote() {
	Q_str="${2-}"
	Q_out=

	while M_STR_HAS([|"${Q_str}"|], [|"'"|]); do
		M_STR_APPEND([|Q_out|], [|"${Q_str%%"'"*}'\\''"|])
		Q_str="${Q_str#*"'"}"
	done

	eval "${1}=\"'\${Q_out}\${Q_str}'\""
	unset CLEANUP
}
|], [|str_quote|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rep "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_nat0_safe ${3+"${3}"} || return M_EX_USAGE

	__sx_str_rep "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_rep - 文字列を繰り返す（内部用）
##
## 使い方:
##   __sx_str_rep 結果変数名 [元文字列 [繰り返し回数]]
##
## 説明:
##   sx_str_rep の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_out|])dnl

__sx_str_rep() {
	set -- "${1}" "${2-}" "$((${3-1}))"

	Q_out=

	while :; do
		case "$((${3} % 2))" in 1)
			M_STR_APPEND([|Q_out|], [|"${2}"|])
		esac

		set -- "${1}" "${2}" "$((${3} / 2))"
		M_STR_NE([|"${3}"|], [|0|]) || break
		set -- "${1}" "${2}${2}" "${3}"
	done

	M_VAR_SET([|${1}|], [|${Q_out}|])
	unset CLEANUP
}
|], [|str_rep|])dnl

M_RENAME_QI([|dnl
### __sx_str_qm - '?'×n を高速生成する（内部用）
##
## 使い方:
##   __sx_str_qm 結果変数名 [繰り返し回数]
##
## 説明:
##   '?' を指定された回数だけ繰り返して、結果変数に格納する。
##   SX_NUM_QM 定数（1〜37 桁）から case で直接参照し、37 桁を超える場合のみ
##   __sx_str_rep で生成する。引数チェックは行わない。

define([|CLEANUP|], [|Q_out|])dnl

__sx_str_qm() {
	case "${2:-1}" in
__sx_m4_gen_qm_case(1)
		*)
			__sx_str_rep "${1}" '?' "${2:-1}"
			return
			;;
	esac

	eval "${1}=\"\${Q_out}\""
	unset CLEANUP
}
|], [|str_qm|])dnl

M_RENAME_QI([|dnl
### __sx_str_zr - "0"×n を高速生成する（内部用）
##
## 使い方:
##   __sx_str_zr 結果変数名 [繰り返し回数]
##
## 説明:
##   "0" を指定された回数だけ繰り返して、結果変数に格納する。
##   SX_NUM_ZR 定数（1〜37 桁）から case で直接参照し、37 桁を超える場合のみ
##   __sx_str_rep で生成する。引数チェックは行わない。

define([|CLEANUP|], [|Q_out|])dnl

__sx_str_zr() {
	case "${2:-1}" in
__sx_m4_gen_zr_case(1)
		*)
			__sx_str_rep "${1}" 0 "${2:-1}"
			return
			;;
	esac

	eval "${1}=\"\${Q_out}\""
	unset CLEANUP
}
|], [|str_zr|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rev() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rev "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3:+"${3}"} || return M_EX_USAGE
	case "$((${3:-1}))" in 0)
		return M_EX_USAGE
	esac

	__sx_str_rev "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_rev - 文字列を反転する（内部用）
##
## 使い方:
##   __sx_str_rev 結果変数名 [元文字列 [チャンクサイズ]]
##
## 説明:
##   sx_str_rev の内部実装。引数チェックは行わない。
##   チャンクサイズが正の場合は先頭基準、負の場合は末尾基準でチャンク単位の反転を行う。

define([|CLEANUP|], [|Q_src Q_out Q_pat Q_tmp|])dnl

__sx_str_rev() {
	set -- "${1}" "${2-}" "${3:-1}"

	Q_src="${2-}"
	Q_out=
	__sx_str_qm Q_pat "${3#-}"

	if M_NUM_LT([|${3}|], [|0|]); then
		set -- "${1}" "${2}" "${3#-}"

		while M_NUM_BOOL([|${3} < ${#Q_src}|]); do
			Q_tmp="${Q_src%${Q_pat}}"
			M_STR_APPEND([|Q_out|], [|"${Q_src#${Q_tmp}}"|])
			Q_src="${Q_tmp}"
		done

		M_VAR_SET([|${1}|], [|${Q_out}${Q_src}|])
	else
		while M_NUM_BOOL([|${3} < ${#Q_src}|]); do
			Q_tmp="${Q_src#${Q_pat}}"
			M_STR_PREPEND([|Q_out|], [|"${Q_src%"${Q_tmp}"}"|])
			Q_src="${Q_tmp}"
		done

		M_VAR_SET([|${1}|], [|${Q_src}${Q_out}|])
	fi

	unset CLEANUP
}
|], [|str_rev|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rfind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rfind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_nat0_safe ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_rfind "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_str_rfind - 文字列から指定された文字列を後方一致で探す（内部用）
##
## 使い方:
##   __sx_str_rfind 結果変数名（またはバインド形式） [元文字列 [検索文字列 [フラグ]]]
##
## 説明:
##   sx_str_rfind の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_tgt Q_off Q_pre Q_sts Q_match Q_after Q_text Q_overlap|])dnl

__sx_str_rfind() {
	set -- "${1}" "${2-}" "${3-}" "${4:-0}"
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_tgt="${2}"
	Q_text=$((${4} & SX_STR_RFIND_TEXT))
	Q_overlap=$((${4} & SX_STR_RFIND_OVERLAP))

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${4} & SX_STR_RFIND_GLOB|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		Q_off="${#Q_tgt}"
		Q_sts=M_EX_OK

		# 空 needle: len から 0 へ
		while M_NUM_LE([|0|], [|Q_off|]); do
			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${Q_off}:0" || :;;
				*) __sx_var_bind Q_bind "${Q_bind}" '' || :;;
			esac

			M_NUM_DECR([|Q_off|])
		done
	elif M_NUM_BOOL([|${4} & SX_STR_RFIND_GLOB|]); then
		# ==== グロブモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|${3}|]); do
			Q_pre="${Q_tgt%${3}*}"
			Q_match="${Q_tgt#${Q_pre}}"
			Q_after="${Q_match#${3}}"
			Q_match="${Q_match%${Q_after}}"
			Q_sts=M_EX_OK

			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${#Q_pre}:${#Q_match}" || :;;
				*) __sx_var_bind Q_bind "${Q_bind}" "${Q_match}" || :;;
			esac

			case "${Q_overlap}" in
				0) Q_tgt="${Q_pre}";;
				*) Q_tgt="${Q_pre}${Q_match%?}";;
			esac
		done
	else
		# ==== リテラルモード ====
		while M_STR_HAS([|"${Q_tgt}"|], [|"${3}"|]); do
			Q_pre="${Q_tgt%"${3}"*}"
			Q_sts=M_EX_OK

			case "${Q_text}" in
				0) __sx_var_ubind Q_bind "${Q_bind}" "${#Q_pre}:${#3}" || :;;
				*) __sx_var_bind Q_bind "${Q_bind}" "${3}" || :;;
			esac

			case "${Q_overlap}" in
				0) Q_tgt="${Q_pre}";;
				*) Q_tgt="${Q_pre}${3%?}";;
			esac
		done
	fi

	set -- "${Q_sts-1}"
	unset CLEANUP
	return "${1}"
}
|], [|str_rfind|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_rot() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_rot "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${4:+"${4}"} || return M_EX_USAGE

	__sx_str_rot "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_rot - sx_str_rot の内部実装（内部用）
##
## 使い方:
##   __sx_str_rot 結果変数名 [元文字列 [文字セット [シフト量]]]
##
## 説明:
##   sx_str_rot の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_rotated|])dnl

__sx_str_rot() {
	set -- "${1}" "${2-}" "${3-${SX_STR_ALPHA}}" "${4:-13}"

	case '' in "${2}" | "${3}")
		M_VAR_SET([|${1}|], [|${2}|])
		return M_EX_OK
	esac

	__sx_str_cycle Q_rotated "${3}" "${4}"
	__sx_str_tr "${1}:" "${2}" "${3}" "${Q_rotated}"

	unset CLEANUP
}
|], [|str_rot|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_splice() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_splice "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3+"${3}"} ${4+"${4}"} || return M_EX_USAGE

	__sx_str_splice "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_splice - 文字列の一部を削除し、そこに新しい文字列を挿入する（内部用）
##
## 使い方:
##   __sx_str_splice 結果変数名 文字列 開始位置 削除数 挿入文字列
##
## 説明:
##   sx_str_splice の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|unset Q_res Q_str Q_off Q_len Q_add Q_left Q_right Q_suffix Q_del|])dnl

__sx_str_splice() {
	Q_res="${1}"
	Q_str="${2-}"
	Q_off="${3-0}"
	Q_len="${4-${SX_NUM_I32_MAX}}"
	Q_add="${5-}"

	# 1. 前半部分を取得 (sx_str_substr は負数 off をサポート済み)
	__sx_str_substr Q_left "${Q_str}" 0 "${Q_off}"

	# 2. 残りの部分（suffix）を抽出
	Q_suffix="${Q_str#"${Q_left}"}"

	# 3. 削除される部分を取得（sx_str_substr の負数 len を利用）
	__sx_str_substr Q_del "${Q_suffix}" 0 "${Q_len}"

	# 4. 後半部分（削除範囲より後ろ）を抽出
	Q_right="${Q_suffix#"${Q_del}"}"

	# 5. 結合して格納
	M_VAR_SET([|${Q_res}|], [|${Q_left}${Q_add}${Q_right}|])

	CLEANUP
}
|], [|str_splice|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_split() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_split "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${4+"${4}"} ${5+"${5}"} || return M_EX_USAGE

	__sx_str_split "${@}"
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_bind Q_str Q_sep Q_lim Q_flg Q_inc Q_out Q_rem Q_mid Q_val|])dnl

__sx_str_split() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2-}"
	Q_sep="${3-}"
	Q_lim=$((${4-${SX_NUM_I32_MAX}}))
	Q_flg=$((${5-0}))
	Q_inc=$(((Q_flg & SX_STR_SPLIT_INC) != 0))

	set --

	# 空区切り文字（一文字ずつ分割）の処理
	if
		M_STR_EQ([|"${Q_sep}"|], [|''|]) ||
		{ M_NUM_BOOL([|Q_flg & SX_STR_SPLIT_GLOB|]) && ! M_STR_HAS([|"${Q_sep}"|], [|*[!*]*|]); }
	then
		if M_NUM_LT([|0|], [|Q_lim|]); then
			# 前方から制限数分だけ分割
			__sx_str_chunk Q_out "${Q_str}" 1 "$((Q_lim - 1))"

			case "$((${#Q_str} < Q_lim))" in 1)
				M_STR_APPEND([|Q_out|], [|"''"|], [| |])
			esac

			M_STR_PREPEND([|Q_out|], [|"''"|], [| |])
		elif M_NUM_LT([|Q_lim|], [|0|]); then
			# 後方から制限数分だけ分割
			: $((Q_lim *= -1))
			__sx_str_chunk Q_out "${Q_str}" -1 "$((Q_lim - 1))"

			case "$((${#Q_str} < Q_lim))" in 1)
				M_STR_PREPEND([|Q_out|], [|"''"|], [| |])
			esac

			M_STR_APPEND([|Q_out|], [|"''"|], [| |])
		else
			# 制限なし：文字列全体をクォートして格納
			__sx_arg_quote Q_out "${Q_str}"
		fi

		case "${Q_inc}" in 1)
			eval __sx_arg_isep Q_out '"${SX_CFG_SEP}"' "${Q_out}"
		esac

		eval __sx_arg_quote '"${Q_bind}"' "${Q_out}"
	elif M_NUM_LE([|0|], [|Q_lim|]); then
		# 前方から分割
		if M_STR_NE([|$((Q_flg & SX_STR_SPLIT_GLOB))|], [|0|]); then
			# グロブ（パターン）による前方分割
			while
				M_STR_HAS([|"${Q_str}"|], [|${Q_sep}|]) &&
				M_STR_NE([|"${Q_lim}"|], [|0|])
			do
				Q_val="${Q_str%%${Q_sep}*}"

				__sx_var_bind Q_bind "${Q_bind}" "${Q_val}" || {
					unset CLEANUP
					return M_EX_OK
				}

				Q_rem="${Q_str#*${Q_sep}}"

				# 区切り文字を含めるフラグがある場合
				case "${Q_inc}" in 1)
					Q_mid="${Q_str#${Q_val}}"
					__sx_var_bind Q_bind "${Q_bind}" "${Q_mid%${Q_rem}}" || {
						unset CLEANUP
						return M_EX_OK
					}
				esac

				Q_str="${Q_rem}"
				M_NUM_DECR([|Q_lim|])
			done
		else
			# 通常の文字列による前方分割
			while
				M_STR_HAS([|"${Q_str}"|], [|"${Q_sep}"|]) &&
				M_STR_NE([|"${Q_lim}"|], [|0|])
			do
				__sx_var_bind Q_bind "${Q_bind}" "${Q_str%%"${Q_sep}"*}" || {
					unset CLEANUP
					return M_EX_OK
				}

				case "${Q_inc}" in 1)
					__sx_var_bind Q_bind "${Q_bind}" "${Q_sep}" || {
						unset CLEANUP
						return M_EX_OK
					}
				esac

				Q_str="${Q_str#*"${Q_sep}"}"
				M_NUM_DECR([|Q_lim|])
			done
		fi

		__sx_var_bind Q_bind "${Q_bind}" "${Q_str}" || :
	else
		# 後方から分割
		if M_STR_NE([|$((Q_flg & SX_STR_SPLIT_GLOB))|], [|0|]); then
			# グロブ（パターン）による後方分割
			while
				M_STR_HAS([|"${Q_str}"|], [|${Q_sep}|]) &&
				M_STR_NE([|"${Q_lim}"|], [|0|])
			do
				set -- "${Q_str##*${Q_sep}}" "${@}"
				Q_rem="${Q_str%${Q_sep}*}"

				# 区切り文字を含めるフラグがある場合
				case "${Q_inc}" in 1)
					Q_mid="${Q_str%${1}}"
					set -- "${Q_mid#${Q_rem}}" "${@}"
				esac

				Q_str="${Q_rem}"
				M_NUM_INCR([|Q_lim|])
			done
		else
			# 通常の文字列による後方分割
			while
				M_STR_HAS([|"${Q_str}"|], [|"${Q_sep}"|]) &&
				M_STR_NE([|"${Q_lim}"|], [|0|])
			do
				set -- "${Q_str##*"${Q_sep}"}" "${@}"

				case "${Q_inc}" in 1)
					set -- "${Q_sep}" "${@}"
				esac

				Q_str="${Q_str%"${Q_sep}"*}"
				M_NUM_INCR([|Q_lim|])
			done
		fi

		__sx_arg_quote "${Q_bind}" "${Q_str}" "${@}"
	fi

	unset CLEANUP
}
|], [|str_split|])dnl

### sx_str_split_ifs - 現在の IFS を使用して文字列を単語分割し、結果を変数に格納する
##
## 使い方:
##   IFS=',' sx_str_split_ifs 結果変数名（またはバインド形式） [文字列 ...]
##
## 説明:
##   現在の IFS（内部フィールド区切り文字）を用いて、第2引数以降の文字列を
##   単語分割（Word Splitting）し、各単語をシングルクォートで囲み、
##   スペース区切りで結合した文字列として結果変数に格納する。
##   第一引数にはバインド形式を指定して分配代入を行うことも可能。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_split_ifs() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_split_ifs "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_split_ifs "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_str_split_ifs - 現在の IFS を使用して文字列を単語分割し、結果を変数に格納する（内部用）
##
## 使い方:
##   __sx_str_split_ifs 結果変数名（またはバインド形式） [文字列 ...]
##
## 説明:
##   sx_str_split_ifs の内部実装。引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_opts|])dnl

__sx_str_split_ifs() {
	Q_bind="${1}"
	Q_opts="${-}"
	shift

	set -f
	set -- ${*}

	case "${Q_opts}" in *f*) ;; *)
		set +f
	esac

	__sx_arg_quote "${Q_bind}" "${@}"

	unset CLEANUP
}
|], [|str_split_ifs|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_squish() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_squish "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_squish "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_squish - XSLT normalize-space 相当（内部用）
##
## 使い方:
##   __sx_str_squish 結果変数名 [文字列 [文字セット [区切り文字]]]
##
## 説明:
##   sx_str_squish の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_str Q_out|])dnl

__sx_str_squish() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}" "${4- }"

	case "${3}" in '')
		M_VAR_SET([|${1}|], [|${2}|])
		return
	esac

	__sx_str_trim Q_str "${2}" "${3}"

	Q_out=
	while M_STR_HAS([|"${Q_str}"|], [|["${3}"]|]); do
		M_STR_APPEND([|Q_out|], [|"${Q_str%%["${3}"]*}${4}"|])
		Q_str="${Q_str#*["${3}"]}"
		Q_str="M_STR_LTRIM([|Q_str|], [|[!"${3}"]|])"
	done

	M_VAR_SET([|${1}|], [|${Q_out}${Q_str}|])
	unset CLEANUP
}
|], [|str_squish|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_strim() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_strim "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

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
		M_VAR_SET([|${1}|], [|${2}|])
		return M_EX_OK
	esac

	M_VAR_SET([|${1}|], [|M_STR_LTRIM([|2|], [|[!"${3}"]|])|])
}

### sx_str_sub - 文字列内のパターンを置換する
##
## 使い方:
##   sx_str_sub バインド形式 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   元文字列の中に含まれる検索パターンを、置換文字列に置き換える。
##   バインド形式で置換結果と置換回数を取得できる。
##   例: res:（結果のみ）、res:cnt（結果と回数）。
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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_sub() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_sub "${@}" || return; return; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${5:+"${5}"} && __sx_num_is_nat0_safe ${6:+"${6}"} || return M_EX_USAGE

	__sx_str_sub "${@}" || return
}

### __sx_str_sub - 文字列内のパターンを置換する（ディスパッチャ）
##
## 使い方:
##   __sx_str_sub バインド形式 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
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

M_RENAME_QI([|dnl
### __sx_str_sub_cb - 文字列内のパターンをコールバック置換する（内部用）
##
## 使い方:
##   __sx_str_sub_cb バインド形式 [元文字列 [検索パターン [コールバック [回数制限 [フラグ]]]]]
##
## 説明:
##   __sx_str_sub からコールバックモードを抽出した内部関数。
##   パターンが空の場合は __sx_str_isep に委譲する。
##   バインド形式で置換結果と成功置換回数を取得できる。
##   コールバックが非0を返した場合、残リミット(${5})を 0 にして
##   以降の置換を抑止する。置換回数(${8})は成功数のまま残るため、そのまま bind できる。

define([|CLEANUP|], [|Q_ret|])dnl

__sx_str_sub_cb() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "${5-}" "$((${6-0} & SX_STR_SUB_GLOB))" '' 0 ''

	if
		M_STR_EQ([|"${3}"|], [|''|]) ||
		{ M_NUM_BOOL([|${6}|]) && ! M_STR_HAS([|"${3}"|], [|*[!*]*|]); }
	then
		__sx_str_sub_isep_adapt_cb_="${4}" __sx_str_isep "${1}" "${2}" __sx_str_sub_isep_adapt "$((${5} < 0 ? -1 : 1))" "$((${5} < 0 ? 0 - ${5} : ${5}))" "$((SX_STR_ISEP_PRE | SX_STR_ISEP_POST | SX_STR_ISEP_CB))" || return
	elif M_NUM_LE([|0|], [|${5}|]); then
		if M_STR_EQ([|"${6}"|], [|0|]); then
			while M_STR_HAS([|"${2}"|], [|"${3}"|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2%%"${3}"*}"
				set -- "${1}" "${2#*"${3}"}" "${3}" "${4}" "${5}" "${6}" "${7}${10}" "$((${8} + 1))" "${9}${10}"

				"${4}" Q_ret "${3}" "${9}" "${2}" "${8}" && \
				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${Q_ret-${3}}" "${8}" "${9}${3}" || \
				set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${7}${3}" "$((${8} - 1))" "${9}${3}" "${?}"

				unset CLEANUP
			done
		else
			while M_STR_HAS([|"${2}"|], [|${3}|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2%%${3}*}" "${2#*${3}}"
				set -- "${@}" "${2#"${10}"}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${7}${10}" "$((${8} + 1))" "${9}${10}" "${12%"${11}"}"

				"${4}" Q_ret "${10}" "${9}" "${2}" "${8}" && \
				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}${Q_ret-${10}}" "${8}" "${9}${10}" || \
				set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${7}${10}" "$((${8} - 1))" "${9}${10}" "${?}"

				unset CLEANUP
			done
		fi

		__sx_var_bind_init "${1}"
		__sx_var_bind '' "${1}" "${7}${2}" "${8}" || :

		unset CLEANUP
		return "${10-0}"
	else
		set -- "${1}" "${2}" "${3}" "${4}" "${5#-}" "${6}" "${7}" "${8}" "${9}"

		if M_STR_EQ([|"${6}"|], [|0|]); then
			while M_STR_HAS([|"${2}"|], [|"${3}"|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2##*"${3}"}"
				set -- "${1}" "${2%"${3}"*}" "${3}" "${4}" "${5}" "${6}" "${10}${7}" "$((${8} + 1))" "${10}${9}"

				"${4}" Q_ret "${3}" "${2}" "${9}" "${8}" && \
				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${Q_ret-${3}}${7}" "${8}" "${3}${9}" || \
				set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${3}${7}" "$((${8} - 1))" "${3}${9}" "${?}"

				unset CLEANUP
			done
		else
			while M_STR_HAS([|"${2}"|], [|${3}|]) && M_NUM_LT([|${8}|], [|${5}|]); do
				set -- "${@}" "${2##*${3}}" "${2%${3}*}"
				set -- "${@}" "${2%"${10}"}"
				set -- "${1}" "${11}" "${3}" "${4}" "${5}" "${6}" "${10}${7}" "$((${8} + 1))" "${10}${9}" "${12#"${11}"}"

				"${4}" Q_ret "${10}" "${2}" "${9}" "${8}" && \
				set -- "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${Q_ret-${10}}${7}" "${8}" "${10}${9}" || \
				set -- "${1}" "${2}" "${3}" "${4}" 0 "${6}" "${10}${7}" "$((${8} - 1))" "${10}${9}" "${?}"

				unset CLEANUP
			done
		fi

		__sx_var_bind_init "${1}"
		__sx_var_bind '' "${1}" "${2}${7}" "${8}" || :

		unset CLEANUP
		return "${10-0}"
	fi
}
|], [|str_sub_cb|])dnl

M_RENAME_QI([|dnl
### __sx_str_sub_lit - 文字列内のパターンをリテラル/Glob置換する（内部用）
##
## 使い方:
##   __sx_str_sub_lit バインド形式 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   __sx_str_sub からリテラル/Globモードを抽出した内部関数。
##   パターンが空の場合は __sx_str_isep に委譲する。
##   バインド形式で置換結果と置換回数を取得できる。

define([|CLEANUP|], [|Q_bind Q_str Q_pat Q_rep Q_lim Q_glob Q_out Q_cnt|])dnl

__sx_str_sub_lit() {
	# 名前付き変数で状態を管理する（__sx_str_isep_lit 準拠）。
	# __sx_str_sub_cb とは対照的に位置パラメータを使わない。

	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2-}"
	Q_pat="${3-}"
	Q_rep="${4-}"
	Q_lim="${5-}"
	Q_glob="$((${6-0} & SX_STR_SUB_GLOB))"
	Q_out=
	Q_cnt=0

	if
		M_STR_EQ([|"${Q_pat}"|], [|''|]) ||
		{ M_NUM_BOOL([|Q_glob|]) && ! M_STR_HAS([|"${Q_pat}"|], [|*[!*]*|]); }
	then
		__sx_str_isep "${Q_bind}" "${Q_str}" "${Q_rep}" "$(( Q_lim < 0 ? -1 : 1 ))" "$(( Q_lim < 0 ? 0 - Q_lim : Q_lim ))" "$((SX_STR_ISEP_PRE | SX_STR_ISEP_POST))"
	elif M_NUM_LE([|0|], [|Q_lim|]); then
		if M_STR_EQ([|"${Q_glob}"|], [|0|]); then
			while M_STR_HAS([|"${Q_str}"|], [|"${Q_pat}"|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
				M_STR_APPEND([|Q_out|], [|"${Q_str%%"${Q_pat}"*}${Q_rep}"|])
				Q_str="${Q_str#*"${Q_pat}"}"
				M_NUM_INCR([|Q_cnt|])
			done
		else
			while M_STR_HAS([|"${Q_str}"|], [|${Q_pat}|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
				M_STR_APPEND([|Q_out|], [|"${Q_str%%${Q_pat}*}${Q_rep}"|])
				Q_str="${Q_str#*${Q_pat}}"
				M_NUM_INCR([|Q_cnt|])
			done
		fi

		__sx_var_bind '' "${Q_bind}" "${Q_out}${Q_str}" "${Q_cnt}" || :
	elif M_NUM_LT([|Q_lim|], [|0|]); then
		Q_lim="${Q_lim#-}"

		if M_STR_EQ([|"${Q_glob}"|], [|0|]); then
			while M_STR_HAS([|"${Q_str}"|], [|"${Q_pat}"|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
				M_STR_PREPEND([|Q_out|], [|"${Q_rep}${Q_str##*"${Q_pat}"}"|])
				Q_str="${Q_str%"${Q_pat}"*}"
				M_NUM_INCR([|Q_cnt|])
			done
		else
			while M_STR_HAS([|"${Q_str}"|], [|${Q_pat}|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
				M_STR_PREPEND([|Q_out|], [|"${Q_rep}${Q_str##*${Q_pat}}"|])
				Q_str="${Q_str%${Q_pat}*}"
				M_NUM_INCR([|Q_cnt|])
			done
		fi

		__sx_var_bind '' "${Q_bind}" "${Q_str}${Q_out}" "${Q_cnt}" || :
	fi

	unset CLEANUP
}
|], [|str_sub_lit|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_substr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_substr "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3+"${3}"} ${4+"${4}"} || return M_EX_USAGE

	__sx_str_substr "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_substr - 文字列の部分文字列を取得する（内部用）
##
## 使い方:
##   __sx_str_substr 結果変数名 [元文字列 [オフセット [長さ]]]
##
## 説明:
##   sx_str_substr の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|unset Q_res Q_str Q_off Q_len Q_total Q_drop Q_qm|])dnl

__sx_str_substr() {
	Q_res="${1}"
	Q_str="${2-}"
	Q_off=$((${3-0}))
	Q_len=$((${4-${SX_NUM_I32_MAX}}))
	Q_total="${#Q_str}"

	# オフセットの正規化 (負数は末尾から)
	case "$((Q_off < 0))" in 1)
		Q_off=$(((Q_off * -1) < Q_total ? Q_total + Q_off : 0))
	esac

	# 1. オフセット分をスキップ
	if M_NUM_LE([|Q_total|], [|Q_off|]); then
		Q_str=
	else
		__sx_str_qm Q_qm "${Q_off}"
		Q_str="${Q_str#${Q_qm}}"
	fi

	# 長さの正規化 (負数は末尾から削る)
	Q_total="${#Q_str}"
	if M_NUM_LE([|0|], [|Q_len|]); then
		Q_drop=$((Q_len < Q_total ? Q_total - Q_len : 0))
	else
		Q_drop=$((Q_len * -1))
	fi

	# 2. 指定長に切り詰め
	if M_NUM_LT([|Q_drop|], [|Q_total|]); then
		__sx_str_qm Q_qm "${Q_drop}"
		Q_str="${Q_str%${Q_qm}}"
	else
		Q_str=
	fi

	M_VAR_SET([|${Q_res}|], [|${Q_str}|])
	CLEANUP
}
|], [|str_substr|])dnl

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_tgt Q_arg|])dnl

sx_str_sw() {
	Q_tgt="${1-}"
	shift "$((0 < ${#}))"

	for Q_arg in "${@}"; do
		case "${Q_tgt}" in "${Q_arg}"*)
			unset CLEANUP
			return M_EX_OK
		esac
	done

	unset CLEANUP
	return 1
}
|], [|str_sw|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_swapcase() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_swapcase "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3:+"${3}"} || return M_EX_USAGE

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_title() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_title "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_title "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_title - 各単語の先頭を大文字、残りを小文字に変換する（内部用）
##
## 使い方:
##   __sx_str_title 結果変数名 [元文字列 [単語区切り文字セット]]
##
## 説明:
##   sx_str_title の内部実装。sx_str_tr で一括小文字化した後、
##   セパレータ+小文字のペアを sx_str_sub のコールバックモードで検出して大文字化する。

define([|CLEANUP|], [|Q_tmp Q_gs|])dnl

__sx_str_title() {
	set -- "${1}" "${2-}" "${3:-${SX_STR_SPACE}}"

	__sx_glob_bracket Q_gs "${3}"
	__sx_str_tr Q_tmp: "${2-}" "${SX_STR_UPPER}" "${SX_STR_LOWER}" "${SX_NUM_I32_MAX}"
	__sx_str_sub Q_tmp: "${3%"${3#?}"}${Q_tmp}" "${Q_gs}[${SX_STR_LOWER}]" __sx_str_title_cb "${SX_NUM_I32_MAX}" "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"

	M_VAR_SET([|${1}|], [|${Q_tmp#?}|])
	unset CLEANUP
}
|], [|str_title|])dnl

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
##   64  引数不正 (SX_EX_USAGE)
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_tr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_tr "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${5:+"${5}"} || return M_EX_USAGE

	__sx_str_tr "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_tr - 文字列内の文字を対応する文字で変換する（内部用）
##
## 使い方:
##   __sx_str_tr バインド形式 [文字列 [from文字列 [to文字列 [limit]]]]
##
## 説明:
##   sx_str_tr の内部実装。引数チェックは行わない。
##   バインド形式で置換結果と置換回数を取得できる。
##   例: res:（結果のみ）、res:cnt:（結果と回数）

define([|CLEANUP|], [|Q_bind Q_str Q_from Q_to Q_out Q_lim Q_cnt Q_pre Q_suf Q_from_pre Q_idx|])dnl

__sx_str_tr() {
	set -- "${1}" "${2-}" "${3-}" "${4-}" "${5-}"

	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	Q_str="${2}"
	Q_from="${3}"
	Q_out=
	Q_lim="${5:-${SX_NUM_I32_MAX}}"
	Q_cnt=0

	case "${3}" in
		'') __sx_var_bind '' "${Q_bind}" "${Q_str}" "${Q_cnt}";;
		*)
			__sx_str_chunk Q_to "${4}" 1
			eval set -- "${Q_to}"

			if M_NUM_LT([|Q_lim|], [|0|]); then
				Q_lim="${Q_lim#-}"

				while M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
					Q_suf="${Q_str##*["${Q_from}"]}"
					Q_str="${Q_str%"${Q_suf}"}"
					Q_pre="${Q_str%?}"
					Q_from_pre="${Q_from%%"${Q_str#"${Q_pre}"}"*}"
					Q_idx="${#Q_from_pre}"

					case "$((Q_idx < ${#}))" in
						1) eval "Q_out=\"\${$((${Q_idx} + 1))}\${Q_suf}\${Q_out}\"";;
						*) M_STR_PREPEND([|Q_out|], [|"${Q_suf}"|]);;
					esac

					Q_str="${Q_pre}"
					M_NUM_INCR([|Q_cnt|])
				done

				__sx_var_bind '' "${Q_bind}" "${Q_str}${Q_out}" "${Q_cnt}"
			else
				while M_STR_HAS([|"${Q_str}"|], [|["${Q_from}"]|]) && M_NUM_LT([|Q_cnt|], [|Q_lim|]); do
					Q_pre="${Q_str%%["${Q_from}"]*}"
					Q_str="${Q_str#"${Q_pre}"}"
					Q_suf="${Q_str#?}"
					Q_from_pre="${Q_from%%"${Q_str%"${Q_suf}"}"*}"
					Q_idx="${#Q_from_pre}"

					case "$((Q_idx < ${#}))" in
						1) eval "Q_out=\"\${Q_out}\${Q_pre}\${$((${Q_idx} + 1))}\"";;
						*) M_STR_APPEND([|Q_out|], [|"${Q_pre}"|]);;
					esac

					Q_str="${Q_suf}"
					M_NUM_INCR([|Q_cnt|])
				done

				__sx_var_bind '' "${Q_bind}" "${Q_out}${Q_str}" "${Q_cnt}"
			fi
			;;
	esac || :

	unset CLEANUP
}
|], [|str_tr|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_trim() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_trim "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_trim "${@}"
}

M_RENAME_QI([|dnl
### __sx_str_trim - 文字列の前後から指定された文字セットを削除する（内部用）
##
## 使い方:
##   __sx_str_trim 結果変数名 [文字列 [文字セット]]
##
## 説明:
##   sx_str_trim の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_trim() {
	set -- "${1}" "${2-}" "${3-${SX_STR_SPACE}}"

	__sx_str_strim Q_tmp "${2}" "${3}"
	__sx_str_etrim "${1}" "${Q_tmp}" "${3}"

	unset CLEANUP
}
|], [|str_trim|])dnl

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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  設定値不正 (SX_EX_CONFIG)
sx_str_upper() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_upper "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_num_is_int_safe_inv ${3:+"${3}"} || return M_EX_USAGE

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
		u) eval "${1}=U";; v) eval "${1}=[|V|]";;
		w) eval "${1}=W";; x) eval "${1}=X";;
		y) eval "${1}=Y";; z) eval "${1}=Z";;
		*) eval "${1}=\"\${2}\"";;
	esac
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
##   65  元文字列の長さが安全範囲外 (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_words() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_words "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

	__sx_num_is_nat0_safe ${2+"${#2}"} || return M_EX_DATAERR

	__sx_str_words "${@}"
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_tmp|])dnl

__sx_str_words() {
	set -- "${1}" "${2-}" "${3:- }" "${4:-"_-/.:${SX_STR_SPACE}"}"

	Q_cb_c="${4%"${4#?}"}" __sx_str_sub Q_tmp: "${2}" "[${SX_STR_UPPER}]" __sx_str_words_cb '' "$((SX_STR_SUB_GLOB | SX_STR_SUB_CB))"
	__sx_str_squish Q_tmp "${Q_tmp}" "${4}" "${3}"
	__sx_str_lower "${1}" "${Q_tmp}"

	unset CLEANUP
}
|], [|str_words|])dnl

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
##   64  結果変数名が無効 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_glob_bracket() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_bracket "${@}"; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM
	case "${2-}" in '')
		return M_EX_USAGE
	esac

	__sx_glob_bracket "${@}"
}

M_RENAME_QI([|dnl
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

define([|CLEANUP|], [|Q_pre Q_suf Q_c Q_rest|])dnl

__sx_glob_bracket() {
	case "${2}" in
		*[!^!]*) ;;
		!*^* | ^*!*)
			M_VAR_SET([|${1}|], [|[[.!.]^]|])
			return M_EX_OK
			;;
		*)
			M_VAR_SET([|${1}|], [|${2%"${2#?}"}|])
			return M_EX_OK
	esac

	case "${2}" in *']'*)
		Q_pre=']'
	esac

	case "${2}" in *'\'*)
		Q_suf='\\'
	esac

	for Q_c in = . : '!' '^' -; do
		case "${2}" in *"${Q_c}"*)
			Q_suf="${Q_suf-}${Q_c}"
		esac
	done

	 __sx_str_tr Q_rest: "${2}" ']\.:=!^-'

	M_STR_WRAP([|Q_rest|], [|"${Q_pre-}"|], [|"${Q_suf-}"|])

	case "${Q_rest}" in '!-' | '^-' | '!^-')
		Q_rest="-${Q_rest%-}"
	esac

	M_VAR_SET([|${1}|], [|[${Q_rest}]|])

	unset CLEANUP
}
|], [|glob_bracket|])dnl

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
##   64  結果変数名が無効 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_glob_escape() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_glob_escape "${@}" || return; return 0;; esac

	sx_var_is_name "${1-}" || return M_EX_USAGE

	__sx_var_is_rw "${1}" || return M_EX_NOPERM

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

M_RENAME_Q([|dnl
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

define([|CLEANUP|], [|Q_arr Q_chk Q_dest Q_err Q_i Q_len Q_pair|])dnl

sx_arr_at() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_at "${@}" || return; return 0;; esac

	# 1. 配列の妥当性チェック
	sx_var_is_arr "${1-}" || case "${?}" in
		1) return M_EX_DATAERR;;
		*) return "${?}";;
	esac

	Q_arr="${1}"
	eval "Q_len=\"\${${1}_len}\""
	shift

	Q_chk=
	for Q_pair in "${@}"; do
		Q_dest="${Q_pair%%=*}"
		Q_i="${Q_pair#*=}"

		__sx_num_is_nat0_base 10 "${Q_i}" || {
			unset Q_arr Q_len Q_chk Q_pair Q_dest Q_i
			return M_EX_USAGE
		}

		# 範囲チェック
		case "$((Q_i < Q_len))" in 0)
			Q_err=
		esac

		case "${Q_pair}" in *?=*)
			# 変数名としての妥当性、および自己参照（ソース配列内への上書き）の禁止
			if
				! sx_var_is_name "${Q_dest}" ||
				M_STR_MATCH([|"${Q_dest}"|], [|"${Q_arr}"|], [|"${Q_arr}"_*|])
			then
				unset Q_arr Q_len Q_chk Q_pair Q_dest Q_i
				return M_EX_USAGE
			fi

			# コピー連鎖式の構築 (src-dest)
			M_STR_APPEND([|Q_chk|], [|" ${Q_arr}_${Q_i}-${Q_dest}"|])
		esac
	done

	case "${Q_err+X}" in X)
		unset Q_arr Q_len Q_chk Q_pair Q_dest Q_i Q_err
		return 1
	esac

	eval set -- "${Q_chk}"
	unset Q_arr Q_len Q_chk Q_pair Q_dest Q_i

	case "${#}" in
		0) return M_EX_OK;;
	esac

	# 2. 書き込み可能性（構造を含む）の一括チェック
	eval __sx_var_is_copyable "${@}" || {
		return M_EX_NOPERM
	}

	__sx_var_copy "${@}"
}
|], [|arr_at|])dnl

M_RENAME_QI([|dnl
### __sx_arr_at - 配列の要素を取得または存在確認する（内部用）
##
## 使い方:
##   __sx_arr_at 配列名 [結果変数名=インデックス | =インデックス | インデックス ...]
##
## 説明:
##   sx_arr_at の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_chk Q_arr Q_len Q_pair Q_i|])dnl

__sx_arr_at() {
	Q_chk=
	Q_arr="${1}"
	eval "Q_len=\"\${${1}_len}\""
	shift

	for Q_pair in "${@}"; do
		Q_i="${Q_pair#*=}"

		# 範囲チェック
		case "$((Q_i < Q_len))" in 0)
			unset CLEANUP
			return 1
		esac

		case "${Q_pair}" in *?=*)
			M_STR_APPEND([|Q_chk|], [|" ${Q_arr}_${Q_i}-${Q_pair%%=*}"|])
		esac
	done

	case "${Q_chk}" in
		'')
			unset CLEANUP
			return M_EX_OK
		;;
	esac

	eval __sx_var_copy "${Q_chk}"
	unset CLEANUP
}
|], [|arr_at|])dnl
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

	sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM

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
	M_VAR_SET([|${1}|], [|${SX_CFG_SIG_ARR}:|], [|${1}_len|], [|0|])

	SX_CFG_ARR_UPDATE=1 __sx_arr_push "${@}"
}

### sx_arr_is_bind - 文字列が配列分配用バインド形式として有効か確認する
##
## 使い方:
##   sx_arr_is_bind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、配列分配用バインド形式として有効かを確認する。
##   sx_var_is_bind の検査に加え、`@` を含む形式を拒否する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
sx_arr_is_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_bind "${@}" || return; return 0;; esac

	__sx_arr_is_bind "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_arr_is_bind - 文字列が配列分配用バインド形式として有効か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_bind [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_arr_is_bind の内部実装。引数チェックは行わない。
##   sx_var_is_bind の検査に加え、`@` を含む形式を拒否する。
##
## 終了ステータス:
##    0  すべて有効な形式である
##    1  無効な形式が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_arr_is_bind() {
	__sx_var_is_bind "${@}" || return 1

	for Q_arg in "${@}"; do
		case "${Q_arg}" in *@*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|arr_is_bind|])dnl

### sx_arr_is_ebind - 文字列が配列分配用拡張バインド形式として有効か確認する
##
## 使い方:
##   sx_arr_is_ebind [文字列1 [文字列2 ...]]
##
## 説明:
##   引数で指定されたすべての文字列が、配列分配用拡張バインド形式として有効かを確認する。
##   sx_var_is_ebind の検査に加え、`@` を含む形式を拒否する。
##
## 終了ステータス:
##    0  すべて有効な形式である (SX_EX_OK)
##    1  無効な形式が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arr_is_ebind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_ebind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_arr_is_ebind "${@}" || return
}

M_RENAME_QI([|dnl
### __sx_arr_is_ebind - 文字列が配列分配用拡張バインド形式として有効か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_ebind [文字列1 [文字列2 ...]]
##
## 説明:
##   sx_arr_is_ebind の内部実装。引数チェックは行わない。
##   sx_var_is_ebind の検査に加え、`@` を含む形式を拒否する。
##
## 終了ステータス:
##    0  すべて有効な形式である
##    1  無効な形式が含まれる

define([|CLEANUP|], [|Q_arg|])dnl

__sx_arr_is_ebind() {
	__sx_var_is_ebind "${@}" || return 1

	for Q_arg in "${@}"; do
		case "${Q_arg}" in *@*)
			unset CLEANUP
			return 1
		esac
	done

	unset CLEANUP
}
|], [|arr_is_ebind|])dnl

### sx_arr_is_bindable - バインド形式が有効であり、かつ配列を含む全変数が書き込み可能か確認する
##
## 使い方:
##   sx_arr_is_bindable [バインド形式1 [バインド形式2 ...]]
##
## 説明:
##   指定されたバインド形式が妥当な名前で構成されており、かつ含まれるすべての変数
##   （配列の _len を含む）が書き込み可能（読み取り専用でない）であることを確認する。
##   数値プレフィックス（N名前）を含むセグメントは配列とみなし、
##   name_len の書き込み可否も検査する。
##   最終セグメントは「残り全て」として配列扱いし、name_len の検査を行う。
##   `@` を含む形式は配列分配用として無効である（sx_arr_is_bind 参照）。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる (SX_EX_NOPERM)
##   64  バインド形式が不正 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_arr_is_bindable() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_is_bindable "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_arr_is_bind "${@}" || return M_EX_USAGE

	__sx_arr_is_bindable "${@}"
}

M_RENAME_QI([|dnl
### __sx_arr_is_bindable - バインド形式に含まれる変数が書き込み可能か確認する（内部用）
##
## 使い方:
##   __sx_arr_is_bindable バインド形式
##
## 説明:
##   sx_arr_is_bindable の内部実装。
##   コロン区切りのバインド形式を解析し、配列セグメントの _len を含む
##   すべての変数名に対して一括で書き込み権限を確認する。
##   引数チェック（構文検査）は行わない。
##
## 終了ステータス:
##    0  すべて書き込み可能 (SX_EX_OK)
##    1  書き込み不可な変数が含まれる

define([|CLEANUP|], [|Q_chk Q_arg Q_name|])dnl

__sx_arr_is_bindable() {
	Q_chk=

	for Q_arg in "${@}"; do
		while
			case "${Q_arg}" in
				[1-9]*)
					Q_name="${Q_arg%%:*}"

					case "${Q_name}" in *["${SX_STR_SWORD}"]*)
						Q_name="M_STR_LTRIM([|Q_name|], [|[!0-9/]|])"
						M_STR_APPEND([|Q_chk|], [|" ${Q_name}"|])
					esac
					;;
				:*) ;;
				*:*) M_STR_APPEND([|Q_chk|], [|" ${Q_arg%%:*}"|]);;
				?*) M_STR_APPEND([|Q_chk|], [|" ${Q_arg}"|]);&
				*) ! :;;
			esac
		do
			Q_arg="${Q_arg#*:}"
		done
	done

	eval set -- "${Q_chk}"
	unset CLEANUP

	__sx_var_is_rw_deep "${@}" || return
}
|], [|arr_is_bindable|])dnl

M_RENAME_Q([|dnl
### sx_arr_bind - 配列対応バインドで変数を順次割り当てる
##
## 使い方:
##   sx_arr_bind bind_res chain_res bind varname1 [varname2 ...]
##
## 説明:
##   拡張バインド形式（sx_var_is_ebind 参照）を解析し、chain（src-dst ペア）
##   と残り bind を生成して __sx_arr_bind に委譲する。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  書き込み権限なし (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bres Q_cres Q_bind|])dnl

sx_arr_bind() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_bind "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name ${1:+"${1}"} "${2-}" || return M_EX_USAGE
	__sx_var_is_rw ${1:+"${1}"} "${2}" || return M_EX_NOPERM
	__sx_arr_is_ebind "${3-!}" || return M_EX_USAGE

	Q_bres="${1}"
	Q_cres="${2}"
	Q_bind="${3}"

	shift 3

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	set -- "${Q_bres}" "${Q_cres}" "${Q_bind}" "${@}"

	unset CLEANUP

	__sx_arr_bind "${@}" || return
}
|], [|arr_bind|])dnl

M_RENAME_QI([|dnl
### __sx_arr_bind - 配列対応バインドで変数を順次割り当てる（内部用）
##
## 使い方:
##   __sx_arr_bind bind_res chain_res bind varname1 [varname2 ...]
##
## 説明:
##   bind文字列を逐次解析し、chain (src-dst) と残りbindを生成する。
##   バインド先が枯渇し、未処理の変数名が残る場合は終了ステータス 1 を返し、
##   bind_res に残りのバインド形式（枯渇時は空文字列）、chain_res に途中までの
##   chain を書き込む。
##
## 終了ステータス:
##    0  全て割り当て、残りのバインド形式と chain を各結果変数に格納した
##    1  バインド先が枯渇したまま変数名が残っている。bind_res へ空文字列を書き込む

define([|CLEANUP|], [|Q_bres Q_cres Q_bind Q_chain Q_seg Q_frac Q_cnt Q_lim Q_vn Q_arg Q_tmp|])dnl

__sx_arr_bind() {
	Q_bres="${1}"
	Q_cres="${2}"
	Q_bind="${3}${3:+:}"
	Q_chain=
	shift 3

	while M_STR_NE([|"${#}"|], [|0|]); do
		case "${Q_bind}" in
			[0-9]*)
				Q_seg="${Q_bind%%:*}"
				Q_frac="${Q_bind%%[!/0-9]*}"
				Q_cnt="${Q_frac%/*}"
				Q_lim="${Q_frac#*/}"
				Q_vn="${Q_seg#"${Q_frac}"}"

				case "${Q_lim}:${Q_vn}" in
					# seg: M/
					:)
						__sx_num_add_nat0 Q_cnt "${Q_cnt}" "${#}"
						shift "${#}"
						;;
					# seg: M/vn
					:*)
						for Q_arg in "${@}"; do
							M_STR_APPEND([|Q_chain|], [|"${Q_arg}-${Q_vn}_${Q_cnt}"|], [| |])
							M_NUM_INCRM1([|Q_cnt|])
						done

						shift "${#}"
						;;
					# seg: M/N
					*:)
						__sx_num_sub_nat0 Q_tmp "${Q_lim}" "${Q_cnt}"
						__sx_num_cmp_nat0 "${Q_tmp}" "${#}" || case "${?}" in [12])
							shift "${Q_tmp}"
							Q_bind="${Q_bind#*:}"
							continue
						esac

						__sx_num_add_nat0 Q_cnt "${Q_cnt}" "${#}"
						shift "${#}"
						;;
					*)
						for Q_arg in "${@}"; do
							shift
							M_STR_APPEND([|Q_chain|], [|"${Q_arg}-${Q_vn}_${Q_cnt}"|], [| |])
							M_NUM_INCRM1([|Q_cnt|])

							case "${Q_cnt}" in "${Q_lim}")
								Q_bind="${Q_bind#*:}"
								continue 2
							esac
						done
						;;
				esac

				Q_bind="${Q_cnt}/${Q_lim}${Q_vn}:${Q_bind#*:}"
				;;
			["${SX_STR_SWORD}"]*) M_STR_APPEND([|Q_chain|], [|"${1}-${Q_bind%%:*}"|], [| |]);&
			:*)
				Q_bind="${Q_bind#*:}"
				shift
				;;
			'')
				case "${Q_bres}" in ?*)
					M_VAR_SET([|${Q_bres}|], [|${Q_bind}|])
				esac

				M_VAR_SET([|${Q_cres}|], [|${Q_chain}|])

				unset CLEANUP
				return 1
				;;
		esac
	done

	case "${Q_bres}" in ?*)
		M_VAR_SET([|${Q_bres}|], [|${Q_bind%:}|])
	esac

	M_VAR_SET([|${Q_cres}|], [|${Q_chain}|])

	unset CLEANUP
}
|], [|arr_bind|])dnl

M_RENAME_Q([|dnl
### sx_arr_cat - 複数の配列を連結する
##
## 使い方:
##   sx_arr_cat bind arr1 [arr2 ...]
##
## 説明:
##   指定された sx 配列（arr1, arr2, ...）の全要素を順方向に連結した要素ストリームを生成する
##   （cat = concatenate）。
##   分配先をバインド形式（sx_arr_is_bind 参照。例: x, 2a:x, a:10b:3c:1d:e）で指定できる。
##   `@` を含む形式は無効である。bind の省略は不可であり、引数なしは引数不正となる。
##   これは拡張機能で、連結したストリームをどの変数群へ割り当てるかを選ぶだけのもの
##   （単一の末尾セグメント（x 等）なら純粋な連結になる）。他の sx_arr_* 関数にも導入される
##   共通オプションである。
##
##   例:
##     sx_arr_cat x      a1 a2   # a1=[a,b,c], a2=[d,e] なら x=[a,b,c,d,e]
##     sx_arr_cat 2a:x   a1 a2   # 上記ストリームなら a=[a,b], x=[c,d,e]
##
##   分配先の扱い（sx_arr_is_bindable と同じ分類）:
##     - 数値先行セグメント（2b 等）と末尾セグメント（x 等）は配列として生成する。
##       割当日が無ければ空配列、一部のみならその要素数で生成する（切り詰め成功）。
##     - 先頭・中間の素セグメント（a:10b... の a 等）はスカラーとして扱い配列化しない。
##
##   トランザクション: まず全書き込み先の書き込み可否を一括検査し、一部でも不可なら
##   一切書き込まず SX_EX_NOPERM を返す（中途半端な書き込みを行わない）。
##
## 注意:
##   分配先に既存配列を使う場合は、事前に sx_var_unset を明示的に呼び出してから呼び出すこと。
##   源配列と分配先の名前が重複する場合は未定義。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_arr_cat() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_cat "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_arr_is_bind "${1-!}" || return M_EX_USAGE

	__sx_arr_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_var_is_arr "${@}" || {
		unset CLEANUP
		return M_EX_DATAERR
	}

	__sx_arr_cat "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|arr_cat|])dnl

M_RENAME_QI([|dnl
### __sx_arr_cat - 配列連結の内部実装
##
## 使い方:
##   __sx_arr_cat bind arr1 [arr2 ...]
##
## 説明:
##   sx_arr_cat の本体実装（chain 構築・一括書き込み・コミット）。
##   引数チェック（bind 形式・変数名・配列判定・書き込み権限）は行わない。

define([|CLEANUP|], [|Q_bind Q_chain Q_borg Q_arr Q_len Q_i Q_blk|])dnl

__sx_arr_cat() {
	__sx_var_to_ebind Q_bind "${1}"
	Q_borg="${Q_bind}"
	Q_chain=
	shift

	# 1) 要素ストリームを1つずつ __sx_arr_bind で処理し、chain を構築する（読み取りのみ）
	for Q_arr in "${@}"; do
		eval "Q_len=\"\${${Q_arr}_len}\""
		Q_i=0

		while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
			__sx_arr_bind Q_bind Q_blk "${Q_bind}" "${Q_arr}_${Q_i}" || break 2
			M_STR_APPEND([|Q_chain|], [|" ${Q_blk}"|])
			M_NUM_INCRM1([|Q_i|])
		done
	done

	# 2) chain 適用とコミット: bind_org と残り bind の後方比較を __sx_arr_bind_commit に委譲する
	eval __sx_arr_bind_commit '"${Q_borg}"' '"${Q_bind}"' "${Q_chain}"

	unset CLEANUP
}
|], [|arr_cat|])dnl

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

				case "${Q_fseg}" in
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
				case "${Q_fseg}" in ?*)
					unset "${Q_oseg}"
				esac
				;;
		esac
	done

	eval unset CLEANUP "${Q_mark}"
}
|], [|arr_bind_commit|])dnl

M_RENAME_Q([|dnl
### sx_arr_pop - 配列の末尾から要素を取り出して割り当てる
##
## 使い方:
##   sx_arr_pop bind 配列名
##
## 説明:
##   指定された sx 配列の末尾から、bind の各セグメントが示す個数ぶんの要素を
##   取り出して割り当てる（または破棄する）拡張 pop。
##   bind は固定スロット形式であり、各セグメントの末尾に「:」を付けて指定する
##   （例: x: はスカラー x へ 1 個、2v: は配列 v へ 2 個、1: は 1 個を破棄）。
##   bind に `@` を含む形式は無効である（sx_arr_is_bind 参照）。
##   合計スロット数は各セグメントの個数の合計であり、元配列の要素数を超える
##   場合は一切書き込まずに 1 を返す（トランザクション）。
##
##   セグメントの種類:
##     - N名前:  配列「名前」へ N 個割り当てる（N は 1 以上の整数）
##     - 名前:   スカラー「名前」へ 1 個割り当てる
##     - N:      値は割り当てずに N 個破棄する
##
##   取り出しは末尾から行い、先頭セグメントが最後の要素を受け取る
##   （例: sx_arr_pop x:y: a （a=[1,2]）なら x=2, y=1 となり a は空になる）。
##   成功すると元配列は残った要素のみになり、長さとリビジョンが更新される。
##
##   末尾「:」の無い bind（x や a:b 等）も bind として受理はされるが、
##   末尾セグメントが「残り全部」扱いになるため実質的に常に要素不足となり 1 を返す。
##
## 注意:
##   分配先に既存配列を使う場合は、事前に sx_var_unset を明示的に呼び出してから呼び出すこと。
##   元配列と分配先の名前が重複する場合は未定義。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##    1  合計スロット数が要素数を超えている（無変更）
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [| |])dnl

sx_arr_pop() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_pop "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_arr_is_bind "${1-!}" || return M_EX_USAGE

	__sx_arr_is_bindable "${1}" || return M_EX_NOPERM

	sx_var_is_name "${2-}" || return M_EX_USAGE

	__sx_var_is_arr "${2}" || return M_EX_DATAERR

	__sx_var_is_rw_deep "${2}" || return M_EX_NOPERM

	__sx_arr_pop "${@}" || return
}
|], [|arr_pop|])dnl

M_RENAME_QI([|dnl
### __sx_arr_pop - 配列から要素を取り出して割り当てる（内部用）
##
## 使い方:
##   __sx_arr_pop bind 配列名
##
## 説明:
##   sx_arr_pop の本体実装。取り出し（chain 構築）とコミットを行う。
##   引数チェック（bind 形式・変数名・配列判定・書き込み権限）は行わない。
##   合計スロット数が要素数を超える場合は 1 を返し、何も書き込まない。

define([|CLEANUP|], [|Q_bind Q_borg Q_chain Q_unset Q_len Q_blk Q_tmp|])dnl

__sx_arr_pop() {
	__sx_var_to_ebind Q_bind "${1}"
	Q_borg="${Q_bind}"
	Q_chain=
	Q_unset=
	eval "Q_len=\"\${${2}_len}\""

	# 1) 要素ストリームを末尾から1つずつ __sx_arr_bind で処理し、chain を構築する（読み取りのみ）
	while M_STR_NE([|0|], [|"${Q_len}"|]); do
		__sx_num_sub1_nat0 Q_tmp "${Q_len}"
		__sx_arr_bind Q_bind Q_blk "${Q_bind}" "${2}_${Q_tmp}" || break

		Q_len="${Q_tmp}"

		M_STR_APPEND([|Q_chain|], [|" ${Q_blk}"|])
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

	case "${SX_CFG_ARR_UPDATE-}" in 1)
		__sx_var_touch "${2}"
	esac

	unset CLEANUP
}
|], [|arr_pop|])dnl

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

	sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_arr "${1}" || return M_EX_DATAERR
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM

	__sx_arr_push "${@}"
}

M_RENAME_QI([|dnl
### __sx_arr_push - 配列の末尾に要素を追加する（内部用）
##
## 使い方:
##   __sx_arr_push 配列名 [値 ...]
##
## 説明:
##   指定された配列の末尾に一つ以上の値を追加し、長さを更新する。
##   この関数は引数の検証や書き込み権限のチェックを行わない。

define([|CLEANUP|], [||])dnl

__sx_arr_push() {
	eval 'shift;' __sx_arr_splice "${1}" "\"\${${1}_len}\"" 0 '"${@}"'
}
|], [|arr_push|])dnl

M_RENAME_Q([|dnl
### sx_arr_splice - 配列の一部を削除し、同位置に値を挿入する
##
## 使い方:
##   sx_arr_splice 配列名 n del [値 ...]
##
## 説明:
##   n（0起点）から del 個の要素を削除し、同位置に値を挿入する。
##   n が長さを超える場合は末尾扱い、del が残りを超える場合は残り全部に
##   丸める（clamp）。del=0 で純挿入、値なしで純削除になる。
##   削除された要素は破棄する。中央の上書き前と余剰尾部は深く掃除するため、
##   要素に配列が含まれていても残骸を残さない。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [| |])dnl

sx_arr_splice() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_splice "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	sx_var_is_name "${1-}" || return M_EX_USAGE
	__sx_var_is_arr "${1}" || return M_EX_DATAERR
	__sx_var_is_rw_deep "${1}" || return M_EX_NOPERM
	__sx_num_is_nat0_base 10 ${2:+"${2}"} ${3:+"${3}"} || return M_EX_USAGE

	__sx_arr_splice "${@}"
}
|], [|arr_splice|])dnl

M_RENAME_QI([|dnl
### __sx_arr_splice - 配列の一部を削除し、同位置に値を挿入する（内部用）
##
## 使い方:
##   __sx_arr_splice 配列名 n del [値 ...]
##
## 説明:
##   sx_arr_splice の本体実装。引数チェック（個数・変数名・配列判定・
##   書き込み権限・数値形式）は行わない。
##   長さ・添字・値個数は文字列数値関数で処理し、シェルの算術幅に依存しない。
##   n と del を配列範囲に丸めた後、cnt と del の大小に応じて尾部を移動する。
##   尾部移動は要素単位の __sx_var_copy で行い、拡大時は後方から前方へ、
##   縮小時は前方から後方へ処理して未読のソースを保護する。
##   尾部移動後に長さと余剰尾部を確定し、中央の各要素を深く掃除してから代入する。

define([|CLEANUP|], [|Q_arr Q_len Q_n Q_del Q_rest Q_cnt Q_new Q_src Q_end Q_val Q_vn|])dnl

__sx_arr_splice() {
	Q_arr="${1}"
	Q_n="${2:-0}"
	Q_del="${3:-${#}}"
	shift "$((1 + 0${2+1} + 0${3+1}))"
	eval "Q_len=\"\${${Q_arr}_len}\""
	Q_cnt="${#}"

	# 1) 範囲の丸め (clamp)。n と len を比較し、次のように処理する。
	#    3: n > len。n を len に丸めて 2) へ落下し、同様に終了する。
	#    2: n = len。尾部は空なので len=n+cnt を確定して終了する。
	#    1: n < len。残り長 len-n を求め、del を残り長以内に丸めた後、
	#       下の 2) へ進み尾部を移動する。
	__sx_num_cmp_nat0 "${Q_n}" "${Q_len}" || case "${?}" in
		3) Q_n="${Q_len}";&
		2) __sx_num_add_nat0 "${Q_arr}_len" "${Q_n}" "${Q_cnt}";;
		1)
			__sx_num_sub_nat0 Q_rest "${Q_len}" "${Q_n}"

			# del が残り長を超える場合は、残り全体の削除に丸める。
			__sx_num_cmp_nat0 "${Q_del}" "${Q_rest}" || case "${?}" in 3)
				Q_del="${Q_rest}"
			esac

		# 2) 尾部の移動 (要素ごと): 削除範囲の後ろ [n+del, len) を
		#    挿入後の位置 [n+cnt, new) へずらす。1要素ずつ __sx_var_copy
		#    で移すことで、巨大配列でも生成スクリプトを1要素ぶんに抑える。
		#    n>=len の末尾追加パスは尾部が空で len 確定済みのため、
		#    上の 2) で終了しここへは到達しない。
		__sx_num_cmp_nat0 "${Q_cnt}" "${Q_del}" || case "${?}" in
			1)
				# 縮小 (cnt < del): ソースと宛先を前方へ進める。
				# src=n+del、end=n+cnt とし、尾部を重複しない順序で移動する。
				__sx_num_add_nat0 Q_src "${Q_n}" "${Q_del}"
				__sx_num_add_nat0 Q_end "${Q_n}" "${Q_cnt}"

				case "${Q_src}" in
					# 尾部がない場合は new=n+cnt=end を再利用する。
					"${Q_len}") Q_new="${Q_end}";;
					*)
						# 通常の縮小では new=len-del+cnt を求めてから尾部を移動する。
						__sx_num_sub_nat0 Q_new "${Q_len}" "${Q_del}"
						__sx_num_add_nat0 Q_new "${Q_new}" "${Q_cnt}"

						while M_STR_NE([|"${Q_src}"|], [|"${Q_len}"|]); do
							__sx_var_copy "${Q_arr}_${Q_src}-${Q_arr}_${Q_end}"
							M_NUM_INCRM1([|Q_src|])
							M_NUM_INCRM1([|Q_end|])
						done
						;;
				esac

				# 長さを確定し、new 以降に残った旧要素を深く掃除する。
				eval "${Q_arr}_len=${Q_new}"

				while M_STR_NE([|"${Q_new}"|], [|"${Q_len}"|]); do
					__sx_var_unset "${Q_arr}_${Q_new}"
					M_NUM_INCRM1([|Q_new|])
				done
				;;
			3)
				# 拡大 (cnt > del): src=n+del を起点に、末尾から逆順で移動する。
				__sx_num_add_nat0 Q_src "${Q_n}" "${Q_del}"

				case "${Q_src}" in
					# 尾部がない場合は new=n+cnt を直接求める。
					"${Q_len}") __sx_num_add_nat0 "${Q_arr}_len" "${Q_n}" "${Q_cnt}";;
					*)
						# 通常の拡大では new=len-del+cnt を求めてから尾部を移動する。
						__sx_num_sub_nat0 Q_new "${Q_len}" "${Q_del}"
						__sx_num_add_nat0 Q_new "${Q_new}" "${Q_cnt}"

						# 長さを確定する。拡大では余剰尾部の掃除は発生しない。
						eval "${Q_arr}_len=${Q_new}"

						while M_STR_NE([|"${Q_len}"|], [|"${Q_src}"|]); do
							M_NUM_DECRM1([|Q_len|])
							M_NUM_DECRM1([|Q_new|])
							__sx_var_copy "${Q_arr}_${Q_len}-${Q_arr}_${Q_new}"
						done
						;;
				esac
				;;
		esac
		;;
	esac

	# 3) 中央の書込み: 尾部移動後、各挿入位置を深く掃除してから
	#    直ちに代入する。スロットは互いに独立しているため、掃除と代入を
	#    一周に統合して添字の多倍長インクリメントを重複させない。
	for Q_val in "${@}"; do
		case "${SX_CFG_ARR_HOLE-}" in '') ;; "${Q_val}")
			__sx_var_unset "${Q_arr}_${Q_n}"
			M_NUM_INCRM1([|Q_n|])
			continue
		esac

		if
			M_STR_NE([|"${SX_CFG_ARR_REF-}"|], [|''|]) && \
			M_STR_MATCH([|"${Q_val}"|], [|"${SX_CFG_ARR_REF-}${SX_STR_SWORD}"*|]) && \
			Q_vn="${Q_val#"${SX_CFG_ARR_REF-}"}" && \
			sx_var_is_name "${Q_vn}"
		then
			__sx_var_copy "${Q_vn}-${Q_arr}_${Q_n}"
			M_NUM_INCRM1([|Q_n|])
			continue
		fi

			__sx_var_unset "${Q_arr}_${Q_n}"
		eval "${Q_arr}_${Q_n}=\"\${Q_val}\""
		M_NUM_INCRM1([|Q_n|])
	done

	# 4) リビジョン更新。長さは尾部処理の各分岐で確定済みである。
	case "${SX_CFG_ARR_UPDATE-}" in 1)
		__sx_var_touch "${Q_arr}"
	esac

	unset CLEANUP
}
|], [|arr_splice|])dnl

M_RENAME_Q([|dnl
### sx_arr_quote - 配列要素をシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arr_quote bind 配列名1 [配列名2 ...]
##
## 説明:
##   指定されたすべての配列の要素をそれぞれシングルクォートで囲み（内部のシングルクォートはエスケープ）、
##   スペース区切りで順方向に結合した文字列を作成して結果変数に格納する。
##   作成された文字列は eval 等で安全に位置パラメータに戻すことができる。
##   未設定の要素（疎配列の穴）は SX_CFG_ARR_HOLE の値で表す。
##   結果はバインド形式（sx_var_is_bind 参照）で指定できる。
##   単一の変数名なら全要素をクォートして結合した文字列になる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_arr_quote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_quote "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1-}"
	shift

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_var_is_arr "${@}" || {
		unset CLEANUP
		return M_EX_DATAERR
	}

	__sx_arr_quote "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|arr_quote|])dnl

M_RENAME_QI([|dnl
### __sx_arr_quote - 配列要素をシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_quote バインド形式 配列名1 [配列名2 ...]
##
## 説明:
##   sx_arr_quote の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_arr Q_len Q_i Q_set Q_val|])dnl

__sx_arr_quote() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift

	for Q_arr in "${@}"; do
		eval "Q_len=\"\${${Q_arr}_len}\""
		Q_i=0

		while M_STR_NE([|"${Q_i}"|], [|"${Q_len}"|]); do
			eval "Q_set=\"\${${Q_arr}_${Q_i}+X}\" Q_val=\"\${${Q_arr}_${Q_i}-}\""

			case "${Q_set}" in
				X) __sx_var_bind Q_bind "${Q_bind}" "${Q_val}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${SX_CFG_ARR_HOLE-}";;
			esac || break 2

			M_NUM_INCRM1([|Q_i|])
		done
	done

	unset CLEANUP
}
|], [|arr_quote|])dnl

M_RENAME_Q([|dnl
### sx_arr_rquote - 配列要素を逆順にシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arr_rquote bind 配列名1 [配列名2 ...]
##
## 説明:
##   指定されたすべての配列の要素を、完全な逆順（最後の配列の最後の要素が先頭）で
##   それぞれシングルクォートで囲み、スペース区切りで結合した文字列を作成して結果変数に格納する。
##   作成された文字列は eval 等で安全に位置パラメータに戻すことができる。
##   未設定の要素（疎配列の穴）は SX_CFG_ARR_HOLE の値で表す。
##   結果はバインド形式（sx_var_is_bind 参照）で指定できる。
##   単一の変数名なら全要素をクォートして結合した文字列になる。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   65  対象が sx 配列ではない (SX_EX_DATAERR)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)

define([|CLEANUP|], [|Q_bind|])dnl

sx_arr_rquote() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arr_rquote "${@}" || return; return 0;; esac

	sx_cfg_is_valid "NUM_RANGE=${SX_CFG_NUM_RANGE-}" || return M_EX_CONFIG

	__sx_var_is_bind "${1-!}" || return M_EX_USAGE

	__sx_var_is_bindable "${1}" || return M_EX_NOPERM

	Q_bind="${1}"
	shift

	sx_var_is_name "${@}" || {
		unset CLEANUP
		return M_EX_USAGE
	}

	__sx_var_is_arr "${@}" || {
		unset CLEANUP
		return M_EX_DATAERR
	}

	__sx_arr_rquote "${Q_bind}" "${@}"
	unset CLEANUP
}
|], [|arr_rquote|])dnl

M_RENAME_QI([|dnl
### __sx_arr_rquote - 配列要素を逆順にシングルクォートで囲み、スペース区切りで結合する（内部用）
##
## 使い方:
##   __sx_arr_rquote バインド形式 配列名1 [配列名2 ...]
##
## 説明:
##   sx_arr_rquote の内部実装。
##   引数チェックは行わない。

define([|CLEANUP|], [|Q_bind Q_argi Q_arr Q_arri Q_set Q_val|])dnl

__sx_arr_rquote() {
	__sx_var_bind_init "${1}"
	Q_bind="${1}"
	shift
	Q_argi="${#}"

	while M_STR_NE([|"${Q_argi}"|], [|0|]); do
		eval "Q_arr=\"\${${Q_argi}}\""
		eval "Q_arri=\"\${${Q_arr}_len}\""

		while M_STR_NE([|"${Q_arri}"|], [|0|]); do
			M_NUM_DECRM1([|Q_arri|])
			eval "Q_set=\"\${${Q_arr}_${Q_arri}+X}\" Q_val=\"\${${Q_arr}_${Q_arri}-}\""

			case "${Q_set}" in
				X) __sx_var_bind Q_bind "${Q_bind}" "${Q_val}";;
				*) __sx_var_bind Q_bind "${Q_bind}" "${SX_CFG_ARR_HOLE-}";;
			esac || break 2
		done

		M_NUM_DECRM1([|Q_argi|])
	done

	unset CLEANUP
}
|], [|arr_rquote|])dnl
