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
define([|M_NUM_NE|], [|M_STR_EQ([|$((__M_NUM_CMP_CHAIN(==, $@)))|], 0)|]) dnl

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
				*) $1_bind_="$(( ${$1_bind_cnt_} - 1 ))${$1_bind_name_}:${$1_bind_#*:}";;
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
readonly SX_ARG_FIND_GLOB=1

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

: "${SX_CFG_SIG_BASE:=${SX_CFG_DEF_SIG_BASE}}"
: "${SX_CFG_SIG_ARR:=${SX_CFG_DEF_SIG_ARR}}"
: "${SX_CFG_SKIP_CHK:=${SX_CFG_DEF_SKIP_CHK}}"
: "${SX_CFG_NUM_RANGE:=${SX_CFG_DEF_NUM_RANGE}}"
: "${SX_CFG_SEP:=${SX_CFG_DEF_SEP}}"
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

		for __sx_cfg_is_valid_vn in NUM_RANGE SKIP_CHK SIG_BASE SIG_ARR SEP; do
			__sx_cfg_is_valid_out="${__sx_cfg_is_valid_out} ${__sx_cfg_is_valid_vn}=\"\${SX_CFG_${__sx_cfg_is_valid_vn}-}\""
		done

		eval set -- "${__sx_cfg_is_valid_out}"
		unset __sx_cfg_is_valid_out __sx_cfg_is_valid_vn

		sx_cfg_is_valid "${@}" || return 1

		return "${SX_EX_OK}"
	esac

	for __sx_cfg_is_valid_arg in "${@}"; do
		case "${__sx_cfg_is_valid_arg}" in
			NUM_RANGE | SKIP_CHK | SIG_BASE | SIG_ARR | SEP) ;;
			NUM_RANGE=32 | NUM_RANGE=64 | NUM_RANGE=128) ;;
			SKIP_CHK=[01] | SEP=?* | SIG_BASE=?* | SIG_ARR=?*) ;;
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
##   または名前を数値に変換し、結果を指定された変数に格納する。
##   引数が指定されない場合は、バインド形式に基づき変数を初期化する。
##
## バインド形式:
##   - `変数名`: 最後の引数の変換結果を格納する。
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

__sx_ex_yield() {
	case "${1-0}" in [A-Z]*)
		__sx_ex_map __sx_ex_yield_s_ "${1}"
		set -- "${__sx_ex_yield_s_}"
		unset __sx_ex_yield_s_
	esac

	return "${1-0}"
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

	__sx_arg_quote __sx_ex_remap_cmd_ "${@}"
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

				case $(( ${3:-0} <= __sx_ex_remap_sts_ && __sx_ex_remap_sts_ <= ${4:-255} )) in 1)
					__sx_ex_remap_sts_="${2}"; break
				esac
				;;
			[A-Z]*)
				__sx_ex_map __sx_ex_remap_n_ "${1}"

				case "${__sx_ex_remap_n_}" in "${__sx_ex_remap_sts_}")
					__sx_ex_remap_sts_="${2}"; break
				esac
				;;
			!*)
				case "${1}" in ![A-Z]*)
					__sx_ex_map __sx_ex_remap_n_ "${1#!}"
					set -- "!${__sx_ex_remap_n_}" "${2}"
				esac

				if M_STR_NE([|"${1#!}"|], [|"${__sx_ex_remap_sts_}"|]); then
					__sx_ex_remap_sts_="${2}"; break
				fi
				;;
		esac
	done

	case "${__sx_ex_remap_sts_}" in [A-Z]*)
		__sx_ex_map __sx_ex_remap_sts_ "${__sx_ex_remap_sts_}"
	esac

	set -- "${__sx_ex_remap_sts_}"
	unset __sx_ex_remap_sts_ __sx_ex_remap_map_ __sx_ex_remap_n_
	return "${1}"
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

### sx_arg_rquote - 引数を逆順にシングルクォートで囲み、スペース区切りで結合する
##
## 使い方:
##   sx_arg_rquote 結果変数名 [値 ...]
##
## 説明:
##   指定された値をそれぞれシングルクォートで囲み、
##   逆順（最後の引数が先頭）にスペース区切りで結合した文字列を作成して結果変数に格納する。
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

		: $(( __sx_arg_rquote_i_ -= 1 ))
	done

	eval ${__sx_arg_rquote_out_:+"${__sx_arg_rquote_bind_}=\"\${__sx_arg_rquote_out_}\""}
	unset CLEANUP
}

define([|V|], [|__sx_arg_isep_$1|])dnl
define([|CLEANUP|], [|V(int) V(lim)|])dnl

### sx_arg_isep - 引数間にセパレータを挿入し、すべてをクォートして結合する
##
## 使い方:
##   sx_arg_isep 結果変数名 セパレータ [インターバル [リミット [値 ...]]]
##   sx_arg_isep 結果変数名 [セパレータ [インターバル [リミット]]] ::: [値 ...]
##
## 説明:
##   引数グループの間にセパレータを挿入し、すべての要素（セパレータを含む）を
##   シングルクォートで囲んでスペース区切りで結合する。
##   インターバルが正の場合は先頭から、負の場合は末尾から数えて挿入する。
##   リミットを指定すると、セパレータの挿入回数を制限できる。
##   インターバルに 0 は指定できない。
##   ::: を使用することで、設定引数と対象データを分離できる。
##   ::: を使用しない場合、第2引数はセパレータ、第3引数はインターバル、
##   第4引数はリミットとして扱われ、データは第5引数から開始される。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_isep "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return

	__sx_arg_isep_int=1 __sx_arg_isep_lim="${SX_NUM_I32_MAX}"

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}") __sx_arg_isep_int="${3}";;
		*) __sx_arg_isep_int="${3-1}" __sx_arg_isep_lim="${4-${SX_NUM_I32_MAX}}";;
	esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${__sx_arg_isep_int+"${__sx_arg_isep_int}"} && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 ${__sx_arg_isep_lim+"${__sx_arg_isep_lim}"} || {
		set -- "${?}"
		unset CLEANUP
		return "${1}"
	}

	case "${__sx_arg_isep_int-1}" in 0)
		unset CLEANUP
		return "${SX_EX_USAGE}"
	esac

	unset CLEANUP
	__sx_arg_isep "${@}"
}

define([|V|], [|__sx_arg_isep_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(out) V(sep) V(int) V(lim) V(eff) V(r) V(j) V(arg) __M_BIND_USEVAR|])dnl

### __sx_arg_isep - 引数間にセパレータを挿入し、すべてをクォートして結合する（内部用）
##
## 使い方:
##   __sx_arg_isep 結果変数名 セパレータ [インターバル [リミット [値 ...]]]
##   __sx_arg_isep 結果変数名 [セパレータ [インターバル [リミット]]] ::: [値 ...]
##
## 説明:
##   引数チェックを行わずにセパレータ挿入とクォート結合処理を行う。
__sx_arg_isep() {
	__sx_var_bind_init "${1}"
	__sx_arg_isep_bind_="${1}"
	__sx_arg_isep_out_=
	__sx_arg_isep_sep_=
	__sx_arg_isep_int_=1
	__sx_arg_isep_lim_="${SX_NUM_I32_MAX}"
	__sx_arg_isep_j_=1

	# ::: の位置を特定 (Bounded Search: $2, $3, $4, $5)
	case "X${SX_CFG_SEP}" in
		"${2+X${2}}") shift 2;;
		"${3+X${3}}")
			__sx_arg_isep_sep_="${2}"
			shift 3
			;;
		"${4+X${4}}")
			__sx_arg_isep_sep_="${2}" __sx_arg_isep_int_="${3}"
			shift 4
			;;
		"${5+X${5}}")
			__sx_arg_isep_sep_="${2}" __sx_arg_isep_int_="${3}" __sx_arg_isep_lim_="${4}"
			shift 5
			;;
		*)
			# 従来形式
			__sx_arg_isep_sep_="${2-}" __sx_arg_isep_int_="${3-1}" __sx_arg_isep_lim_="${4-${SX_NUM_I32_MAX}}"
			shift "$((1 + 0${2+1} + 0${3+1} + 0${4+1}))"
			;;
	esac

	__sx_arg_isep_eff_=$(((${#} - 1) / ${__sx_arg_isep_int_#-}))
	case $((__sx_arg_isep_lim_ <= __sx_arg_isep_eff_)) in 0)
		__sx_arg_isep_lim_="${__sx_arg_isep_eff_}"
	esac

	case "${__sx_arg_isep_int_}" in
		-*) __sx_arg_isep_r_=$((${#} - __sx_arg_isep_lim_ * ${__sx_arg_isep_int_#-}));;
		*) __sx_arg_isep_r_="${__sx_arg_isep_int_}";;
	esac

	for __sx_arg_isep_arg_ in "${@}"; do
		case $((__sx_arg_isep_r_ < __sx_arg_isep_j_ && (__sx_arg_isep_j_ - __sx_arg_isep_r_ - 1) % __sx_arg_isep_int_ == 0 && 0 < __sx_arg_isep_lim_)) in 1)
			__M_BIND_QUOTE([|__sx_arg_isep|], [|"${__sx_arg_isep_sep_}"|], CLEANUP)
			: $(( __sx_arg_isep_lim_ -= 1 ))
		esac
		__M_BIND_QUOTE([|__sx_arg_isep|], [|"${__sx_arg_isep_arg_}"|], CLEANUP)
		: $(( __sx_arg_isep_j_ += 1 ))
	done

	eval ${__sx_arg_isep_out_:+"${__sx_arg_isep_bind_}=\"\${__sx_arg_isep_out_}\""}

	unset CLEANUP
}

define([|V|], [|__sx_arg_find_$1|])dnl
define([|CLEANUP|], [|V(lim) V(flg)|])dnl

### sx_arg_find - 引数リストから指定された値を探し、そのインデックスを取得する
##
## 使い方:
##   sx_arg_find 結果変数名 [検索対象 [上限 [フラグ]]] ::: [値 ...]
##
## 説明:
##   検索対象が、指定された値のリストの中で何番目（1開始）にあるかを探し、
##   そのインデックスを結果変数に格納する。
##   上限 N を指定することで、複数の一致項目をスペース区切りで取得できる。
##     N > 0 : 先頭から最大 N 個探す
##     N < 0 : 末尾から最大 |N| 個探す
##     N = 0 : 検索を行わず空文字列を返す
##   フラグに SX_ARG_FIND_GLOB (1) を指定すると、検索対象を glob パターンとして扱う。
##   見つからない場合は空文字列を格納する。
##
## 終了ステータス:
##    0  1つ以上の一致項目が見つかった (SX_EX_OK)
##    1  一致項目が見つからなかった、または上限が 0 (不一致)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_arg_find() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_arg_find "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" || return

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}" | "${3+X${3}}") ;;
		"${4+X${4}}") __sx_arg_find_lim="${3}";;
		*) __sx_arg_find_lim="${3-1}" __sx_arg_find_flg="${4-0}";;
	esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${__sx_arg_find_lim+"${__sx_arg_find_lim}"} ${__sx_arg_find_flg+"${__sx_arg_find_flg}"} || {
		set -- "${?}"
		unset CLEANUP
		return "${1}"
	}

	unset CLEANUP
	__sx_arg_find "${@}"
}

define([|V|], [|__sx_arg_find_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(tgt) V(lim) V(flg) V(glob) V(out) V(i) V(arg) V(sts) __M_BIND_USEVAR|])dnl

### __sx_arg_find - 引数リストから指定された値を探し、そのインデックスを取得する（内部用）
##
## 使い方:
##   __sx_arg_find 結果変数名 [検索対象 [上限 [フラグ]]] ::: [値 ...]
##
## 説明:
##   sx_arg_find の内部実装。
##   引数チェックは行わない。
__sx_arg_find() {
	__sx_var_bind_init "${1}"
	__sx_arg_find_bind_="${1}"
	__sx_arg_find_tgt_=
	__sx_arg_find_lim_=1
	__sx_arg_find_flg_=0
	__sx_arg_find_sts_=1
	__sx_arg_find_out_=

	case "X${SX_CFG_SEP}" in
		"${2+X${2}}") shift 2;;
		"${3+X${3}}")
			__sx_arg_find_tgt_="${2}"
			shift 3
			;;
		"${4+X${4}}")
			__sx_arg_find_tgt_="${2}" __sx_arg_find_lim_=$((${3-1}))
			shift 4
			;;
		"${5+X${5}}")
			__sx_arg_find_tgt_="${2}" __sx_arg_find_lim_=$((${3-1})) __sx_arg_find_flg_=${4-0}
			shift 5
			;;
		*)
			__sx_arg_find_tgt_="${2-}" __sx_arg_find_lim_=$((${3-1})) __sx_arg_find_flg_=${4-0}
			shift "$((1 + 0${2+1} + 0${3+1} + 0${4+1}))"
			;;
	esac

	__sx_arg_find_glob_=$(( (__sx_arg_find_flg_ & SX_ARG_FIND_GLOB) != 0 ))

	if M_NUM_LT([|__sx_arg_find_lim_|], [|0|]); then
		# 逆方向検索
		__sx_arg_find_i_="${#}"

		while M_NUM_LT([|0|], [|__sx_arg_find_i_|]); do
			eval __sx_arg_find_arg_=\"\${${__sx_arg_find_i_}}\"

			case "${__sx_arg_find_glob_}${__sx_arg_find_arg_}" in "0${__sx_arg_find_tgt_}" | 1${__sx_arg_find_tgt_})
				__M_BIND_UNQUOTE([|__sx_arg_find|], [|"${__sx_arg_find_i_}"|], CLEANUP)

				__sx_arg_find_sts_="${SX_EX_OK}"
				: $(( __sx_arg_find_lim_ += 1 ))

				case "${__sx_arg_find_lim_}" in 0) break; esac
			esac

			: $(( __sx_arg_find_i_ -= 1 ))
		done
	elif M_NUM_LT([|0|], [|__sx_arg_find_lim_|]); then
		# 順方向検索
		__sx_arg_find_i_=1

		for __sx_arg_find_arg_ in "${@}"; do
			case "${__sx_arg_find_glob_}${__sx_arg_find_arg_}" in "0${__sx_arg_find_tgt_}" | 1${__sx_arg_find_tgt_})
				__M_BIND_UNQUOTE([|__sx_arg_find|], [|"${__sx_arg_find_i_}"|], CLEANUP)

				__sx_arg_find_sts_="${SX_EX_OK}"
				: $(( __sx_arg_find_lim_ -= 1 ))

				case "${__sx_arg_find_lim_}" in 0) break; esac
			esac

			: $(( __sx_arg_find_i_ += 1 ))
		done
	fi

	eval ${__sx_arg_find_out_:+"${__sx_arg_find_bind_}=\"\${__sx_arg_find_out_# }\""}

	set -- "${__sx_arg_find_sts_}"

	unset CLEANUP
	return "${1}"
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

__sx_arg_range() {
	__sx_arg_range_res_="${1}"
	shift
	__sx_num_range __sx_arg_range_idxs_ "${@}"

	case "${__sx_arg_range_idxs_}" in
		'') __sx_var_set "${__sx_arg_range_res_}=";;
		*)
			__sx_str_sub __sx_arg_range_tmp_ "${__sx_arg_range_idxs_}" ' ' '}" "${'
			__sx_var_set "${__sx_arg_range_res_}=\"\${${__sx_arg_range_tmp_}}\""
			;;
	esac

	unset __sx_arg_range_res_ __sx_arg_range_idxs_ __sx_arg_range_tmp_
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
			__sx_str_rep __sx_arg_norm_tmp_ " ${__sx_arg_norm_pl_}" "${__sx_arg_norm_arg_}"
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

# ========================================
#  VAR (Variable)
# ========================================

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
	__sx_arg_quote __sx_var_copy_esc_ "${@}"
	__sx_var_list_copy __sx_var_copy_ls_ "${@}"
	eval set -- "${__sx_var_copy_ls_}"

	# 1. 値のキャプチャと代入式の生成
	__sx_var_copy_asg_=

	for __sx_var_copy_pair_ in "${@}"; do
		__sx_var_copy_dst_="${__sx_var_copy_pair_%%=*}"
		__sx_var_copy_src_="${__sx_var_copy_pair_#*=}"

		if sx_var_is_set "${__sx_var_copy_src_}"; then
			eval __sx_arg_quote __sx_var_copy_val_ "\"\${${__sx_var_copy_src_}}\""
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

	__sx_var_list_dep __sx_var_dump_ls_ "${@}"
	eval set -- "${__sx_var_dump_ls_}"

	for __sx_var_dump_vn_ in "${@}"; do
		if sx_var_is_set "${__sx_var_dump_vn_}"; then
			eval __sx_arg_quote __sx_var_dump_val_ "\"\${${__sx_var_dump_vn_}}\""
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
			*=*) ! M_STR_MATCH([|"${__sx_var_is_chain_arg}"|], [|*[!_0-9A-Za-z=]*|], [|*==*|], [|=*|], [|*=|], [|[0-9]*|], [|*=[0-9]*|]);;
			*-*) ! M_STR_MATCH([|"${__sx_var_is_chain_arg}"|], [|*[!_0-9A-Za-z-]*|], [|*--*|], [|-*|], [|*-|], [|[0-9]*|], [|*-[0-9]*|]);;
			*) sx_var_is_name "${__sx_var_is_chain_arg}";;
		esac || {
			unset __sx_var_is_chain_arg
			return 1
		}
	done

	unset __sx_var_is_chain_arg
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
			*[!_0-9A-Za-z:]* | 0* | *:0*)
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
	__sx_var_list_copy __sx_var_is_copyable_ls_ "${@}"
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
		case "${__sx_var_is_name_arg}" in '' | [0-9]* | *[!_0-9A-Za-z]*)
			unset __sx_var_is_name_arg
			return 1
		esac
	done

	unset __sx_var_is_name_arg
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
	__sx_var_list_dep __sx_var_is_rw_all_ls_ "${@}"
	eval set -- "${__sx_var_is_rw_all_ls_}"
	unset __sx_var_is_rw_all_ls_

	__sx_var_is_rw "${@}" || return
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
				__sx_var_list_dep __sx_var_list_copy_ls_ "${__sx_var_list_copy_src_}"
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
				: $(( __sx_var_list_dep_i_ += 1 ))
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

	IFS="${SX_STR_LF}" sx_util_eval '
		for __sx_var_list_ro_ln_ in $(readonly -p); do
			__sx_var_list_ro_vn_="${__sx_var_list_ro_ln_#readonly }"
			__sx_var_list_ro_vn_="${__sx_var_list_ro_vn_%%=*}"

			if
				M_STR_NE([|"${__sx_var_list_ro_vn_}"|], [|"${__sx_var_list_ro_ln_}"|]) &&
				sx_var_is_name "${__sx_var_list_ro_vn_}" &&
				sx_var_is_ro "${__sx_var_list_ro_vn_}" &&
				! M_STR_HAS([|"${__sx_var_list_ro_out_}"|], [|" ${__sx_var_list_ro_vn_} "|])
			then
				__sx_var_list_ro_out_="${__sx_var_list_ro_out_}${__sx_var_list_ro_vn_} "
			fi
		done
	'

	__sx_var_list_ro_out_="${__sx_var_list_ro_out_# }"
	__sx_var_set "${__sx_var_list_ro_res_}=${__sx_var_list_ro_out_% }"
	unset __sx_var_list_ro_res_ __sx_var_list_ro_out_ __sx_var_list_ro_ln_ __sx_var_list_ro_vn_
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
	__sx_var_list_set_set_="$(set)"
	__sx_var_list_set_res_="${1}"
	__sx_var_list_set_out_=' '

	IFS="${SX_STR_LF}" sx_util_eval '
		for __sx_var_list_set_ln_ in ${__sx_var_list_set_set_}; do
			__sx_var_list_set_vn_="${__sx_var_list_set_ln_%%=*}"

			if
				M_STR_NE([|"${__sx_var_list_set_vn_}"|], [|"${__sx_var_list_set_ln_}"|]) &&
				sx_var_is_set "${__sx_var_list_set_vn_}" &&
				! M_STR_HAS([|"${__sx_var_list_set_out_}"|], [|" ${__sx_var_list_set_vn_} "|])
			then
				__sx_var_list_set_out_="${__sx_var_list_set_out_}${__sx_var_list_set_vn_} "
			fi
		done
	'

	__sx_var_list_set_out_="${__sx_var_list_set_out_# }"
	__sx_var_set "${__sx_var_list_set_res_}=${__sx_var_list_set_out_% }"
	unset __sx_var_list_set_set_ __sx_var_list_set_res_ __sx_var_list_set_out_ __sx_var_list_set_ln_ __sx_var_list_set_vn_
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
	__sx_arr_gen __sx_var_swap_arr

	for __sx_var_swap_arg in "${@}"; do
		__sx_arr_push __sx_var_swap_arr ''
		__sx_var_swap_tmp="__sx_var_swap_arr_$((__sx_var_swap_arr_len - 1))"

		case "${__sx_var_swap_arg}" in
			*=*)
				__sx_var_copy "${__sx_var_swap_arg%%=*}-${__sx_var_swap_tmp}"
				__sx_var_swap_out="${__sx_var_swap_out} ${__sx_var_swap_arg}=${__sx_var_swap_tmp}"
				;;
			*-*)
				__sx_var_copy "${__sx_var_swap_arg##*-}-${__sx_var_swap_tmp}"
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
	__sx_arr_gen __sx_var_swap_arr_

	for __sx_var_swap_arg_ in "${@}"; do
		__sx_arr_push __sx_var_swap_arr_ ''
		__sx_var_swap_tmp_="__sx_var_swap_arr__$((__sx_var_swap_arr__len - 1))"

		case "${__sx_var_swap_arg_}" in
			*=*)
				__sx_var_copy "${__sx_var_swap_arg_%%=*}-${__sx_var_swap_tmp_}"
				__sx_var_swap_out_="${__sx_var_swap_out_} ${__sx_var_swap_arg_}=${__sx_var_swap_tmp_}"
				;;
			*-*)
				__sx_var_copy "${__sx_var_swap_arg_##*-}-${__sx_var_swap_tmp_}"
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
		: $(( SX_SYS_REV += 1 ))
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
	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${@}" || return

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
	while M_STR_NE([|"${#}"|], [|0|]); do
		if __sx_var_is_arr "${1}"; then
			eval "__sx_var_unset_len_=\"\${${1}_len}\""
			set -- "${@}" "${1}_len"

			__sx_var_unset_i_=0
			while M_STR_NE([|"${__sx_var_unset_i_}"|], [|"${__sx_var_unset_len_}"|]); do
				set -- "${@}" "${1}_${__sx_var_unset_i_}"
				: $(( __sx_var_unset_i_ += 1 ))
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

### sx_num_eq - すべての引数が数値として等しいか確認する
##
## 使い方:
##   sx_num_eq [数値1 [数値2 ...]]
##
## 終了ステータス:
##    0  すべて等しい (SX_EX_OK)
##    1  等しくない数値が含まれる
##   64  数値でない引数が含まれる、または範囲外 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_eq() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_eq "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int "${@}" || return
	__sx_num_eq "${@}" || return
}

### __sx_num_eq - すべての引数が数値として等しいか確認する（内部用）
##
## 使い方:
##   __sx_num_eq [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_eq の内部実装。
##   引数チェックは行わない。
__sx_num_eq() {
	while M_STR_EQ([|"${2+X}"|], [|X|]); do
		case "$((${1} == ${2}))" in 0) return 1; esac

		shift
	done
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

	__sx_num_is_int_width_core "${@}" || return
}

### __sx_num_is_int_width_core - 指定されたビット幅の符号付き整数の範囲内か確認する（内部ロジック）
__sx_num_is_int_width_core() {
	__sx_num_is_int_width_bits_="${1}"
	shift

	# 基数8のパラメータ計算
	__sx_num_is_int_width_olenn_=$(((__sx_num_is_int_width_bits_ - 1) / 3 + 2))
	__sx_num_is_int_width_oleadn_=$((1 << ((__sx_num_is_int_width_bits_ - 1) % 3)))
	__sx_num_is_int_width_olenp_=$((__sx_num_is_int_width_olenn_ - (__sx_num_is_int_width_oleadn_ == 1)))
	__sx_num_is_int_width_oleadp_=$((__sx_num_is_int_width_oleadn_ == 1 ? 7 : __sx_num_is_int_width_oleadn_ - 1))
	# 基数10のパラメータ計算
		eval "__sx_num_is_int_width_dmax_=\"\${SX_NUM_I${__sx_num_is_int_width_bits_}_MAX}\""
	__sx_num_is_int_width_dmin_="${__sx_num_is_int_width_dmax_%7}8"
	__sx_num_is_int_width_dlen_=${#__sx_num_is_int_width_dmax_}
	# 基数16のパラメータ計算
	__sx_num_is_int_width_xlen_=$((__sx_num_is_int_width_bits_ / 4 + 2))

	for __sx_num_is_int_width_arg_ in "${@}"; do
		# $1: 値（符号正規化）, $2: 数値部分の長さ
		set -- "${__sx_num_is_int_width_arg_#+}" "${#__sx_num_is_int_width_arg_}"
		case "${1}" in
			+* | -*) set -- "${1}" "$((${2} - 1))";;
		esac

		case "${1}" in
			0[Xx]* | -0[Xx]*)
				if
					M_NUM_LT([|__sx_num_is_int_width_xlen_|], [|${2}|]) || {
						M_STR_EQ([|"${__sx_num_is_int_width_xlen_}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[Xx][9A-Fa-f]*|], [|-0[Xx]8*[!0]*|], [|0[Xx][89A-Fa-f]*|])
					}
				then
					unset __sx_num_is_int_width_arg_ __sx_num_is_int_width_bits_ __sx_num_is_int_width_dmax_ __sx_num_is_int_width_dmin_ __sx_num_is_int_width_dlen_ __sx_num_is_int_width_xlen_ __sx_num_is_int_width_olenn_ __sx_num_is_int_width_oleadn_ __sx_num_is_int_width_olenp_ __sx_num_is_int_width_oleadp_
					return 1
				fi
				;;
			0?* | -0?*)
				# $3: 制限長さ, $4: 制限先頭文字
				case "${1}" in
					-*) set -- "${1}" "${2}" "${__sx_num_is_int_width_olenn_}" "${__sx_num_is_int_width_oleadn_}";;
					*)  set -- "${1}" "${2}" "${__sx_num_is_int_width_olenp_}" "${__sx_num_is_int_width_oleadp_}";;
				esac

				if
					M_NUM_LT([|${3}|], [|${2}|]) || {
						M_STR_EQ([|"${3}"|], [|"${2}"|]) &&
						M_STR_MATCH([|"${1}"|], [|-0[!1-${4}]*|], [|-0${4}*[!0]*|], [|0[!1-${4}-]*|])
					}
				then
					unset __sx_num_is_int_width_arg_ __sx_num_is_int_width_bits_ __sx_num_is_int_width_dmax_ __sx_num_is_int_width_dmin_ __sx_num_is_int_width_dlen_ __sx_num_is_int_width_xlen_ __sx_num_is_int_width_olenn_ __sx_num_is_int_width_oleadn_ __sx_num_is_int_width_olenp_ __sx_num_is_int_width_oleadp_
					return 1
				fi
				;;
			*)
				if M_NUM_LT([|__sx_num_is_int_width_dlen_|], [|${2}|]); then
					unset __sx_num_is_int_width_arg_ __sx_num_is_int_width_bits_ __sx_num_is_int_width_dmax_ __sx_num_is_int_width_dmin_ __sx_num_is_int_width_dlen_ __sx_num_is_int_width_xlen_ __sx_num_is_int_width_olenn_ __sx_num_is_int_width_oleadn_ __sx_num_is_int_width_olenp_ __sx_num_is_int_width_oleadp_
					return 1
				elif M_STR_EQ([|"${__sx_num_is_int_width_dlen_}"|], [|"${2}"|]); then
					# $1: 絶対値, $2: 制限値
					case "${1}" in
						-*) set -- "${1#-}" "${__sx_num_is_int_width_dmin_}";;
						*)  set -- "${1}"   "${__sx_num_is_int_width_dmax_}";;
					esac

					while :; do
						case "${1}" in
							?????????*)
								# $3, $4 に残りを退避
								set -- "${1}" "${2}" "${1#?????????}" "${2#?????????}"
								# $1, $2 に先頭9桁をセット
								set -- "${1%${3}}" "${2%${4}}" "${3}" "${4}"
								;;
							*)
								# 9桁未満。 $3, $4 を空にして最終周とする
								set -- "${1}" "${2}" '' ''
								;;
						esac

						if M_NUM_LT([|${2}|], [|${1}|]); then
							unset __sx_num_is_int_width_arg_ __sx_num_is_int_width_bits_ __sx_num_is_int_width_dmax_ __sx_num_is_int_width_dmin_ __sx_num_is_int_width_dlen_ __sx_num_is_int_width_xlen_ __sx_num_is_int_width_olenn_ __sx_num_is_int_width_oleadn_ __sx_num_is_int_width_olenp_ __sx_num_is_int_width_oleadp_
							return 1
						elif M_NUM_LT([|${1}|], [|${2}|]) || M_STR_EQ([|"${3}"|], [|''|]); then
							# 小さければ確定または残りがなければ終了
							break
						fi

						# 残りを次の比較対象へ
						shift 2
					done
				fi
				;;
		esac
	done

	unset __sx_num_is_int_width_arg_ __sx_num_is_int_width_bits_ __sx_num_is_int_width_dmax_ __sx_num_is_int_width_dmin_ __sx_num_is_int_width_dlen_ __sx_num_is_int_width_xlen_ __sx_num_is_int_width_olenn_ __sx_num_is_int_width_oleadn_ __sx_num_is_int_width_olenp_ __sx_num_is_int_width_oleadp_
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
			sx_num_is_base_int 10 "${__sx_num_is_float_arg#*[Ee]}"
		esac && sx_num_is_fixed "${__sx_num_is_float_arg%%[Ee]*}" || {
			unset __sx_num_is_float_arg
			return 1
		}
	done

	unset __sx_num_is_float_arg
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
					__sx_str_pad __sx_num_norm_in_ "${__sx_num_norm_dig_}" "-$((__sx_num_norm_dlen_ + __sx_num_norm_shift_))" 0
				else
					: $((__sx_num_norm_shift_ *= -1))

					if M_NUM_LT([|__sx_num_norm_shift_|], [|__sx_num_norm_dlen_|]); then
						__sx_str_splice __sx_num_norm_in_ "${__sx_num_norm_dig_}" "$((__sx_num_norm_dlen_ - __sx_num_norm_shift_))" 0 .
					else
						__sx_str_pad __sx_num_norm_in_ "${__sx_num_norm_dig_}" "${__sx_num_norm_shift_}" 0
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
	__sx_num_is_int_width_core "${SX_CFG_NUM_RANGE}" "${@}" || return
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
	__sx_num_is_int_width_core "${SX_CFG_NUM_RANGE}" "${@}" || return
}

### sx_num_is_sx_num - すべての引数が有効な数値（整数または実数）であるか確認する
##
## 使い方:
##   sx_num_is_sx_num [文字列1 [文字列2 ...]]
##
## 説明:
##   引数が 16進数または 8進数の形式（0x または 0[0-9] で始まる）である場合は
##   sx_num_is_sx_int で、それ以外の場合は sx_num_is_float で検証を行う。
##
## 終了ステータス:
##    0  すべて有効な数値である (SX_EX_OK)
##    1  有効な数値ではない値が含まれる
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_is_sx_num() {
	for __sx_num_is_sx_num_arg in "${@}"; do
		case "${__sx_num_is_sx_num_arg}" in
			*[Xx]* | [+-]0[0-9]* | 0[0-9]*) sx_num_is_sx_int "${__sx_num_is_sx_num_arg}";;
			*) sx_num_is_float "${__sx_num_is_sx_num_arg}";;
		esac || {
			set -- "${?}"
			unset __sx_num_is_sx_num_arg
			return "${1}"
		}
	done

	unset __sx_num_is_sx_num_arg
}

### sx_num_ge - 引数が降順（等号を含む）に並んでいるか確認する
##
## 使い方:
##   sx_num_ge [数値1 [数値2 ...]]
##
## 終了ステータス:
##    0  数値1 >= 数値2 >= ... である (SX_EX_OK)
##    1  条件を満たさない
##   64  数値でない引数が含まれる、または範囲外 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_ge() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_ge "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int "${@}" || return
	__sx_num_ge "${@}" || return
}

### __sx_num_ge - 引数が降順（等号を含む）に並んでいるか確認する（内部用）
##
## 使い方:
##   __sx_num_ge [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_ge の内部実装。
##   引数チェックは行わない。
__sx_num_ge() {
	while M_STR_EQ([|"${2+X}"|], [|X|]); do
		M_STR_EQ([|"$((${1} >= ${2}))"|], [|1|]) || return 1

		shift
	done
}

### sx_num_gt - 引数が厳密な降順に並んでいるか確認する
##
## 使い方:
##   sx_num_gt [数値1 [数値2 ...]]
##
## 終了ステータス:
##    0  数値1 > 数値2 > ... である (SX_EX_OK)
##    1  条件を満たさない
##   64  数値でない引数が含まれる、または範囲外 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_gt() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_gt "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" __sx_num_is_sx_int "${@}" || return
	__sx_num_gt "${@}" || return
}

### __sx_num_gt - 引数が厳密な降順に並んでいるか確認する（内部用）
##
## 使い方:
##   __sx_num_gt [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_gt の内部実装。
##   引数チェックは行わない。
__sx_num_gt() {
	while M_STR_EQ([|"${2+X}"|], [|X|]); do
		M_STR_EQ([|"$((${1} > ${2}))"|], [|1|]) || return 1

		shift
	done
}

### sx_num_le - 引数が昇順（等号を含む）に並んでいるか確認する
##
## 使い方:
##   sx_num_le [数値1 [数値2 ...]]
##
## 終了ステータス:
##    0  数値1 <= 数値2 <= ... である (SX_EX_OK)
##    1  条件を満たさない
##   64  数値でない引数が含まれる、または範囲外 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_le() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_le "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int "${@}" || return
	__sx_num_le "${@}" || return
}

### __sx_num_le - 引数が昇順（等号を含む）に並んでいるか確認する（内部用）
##
## 使い方:
##   __sx_num_le [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_le の内部実装。
##   引数チェックは行わない。
__sx_num_le() {
	while M_STR_EQ([|"${2+X}"|], [|X|]); do
		M_STR_EQ([|"$((${1} <= ${2}))"|], [|1|]) || return 1

		shift
	done
}

### sx_num_lt - 引数が厳密な昇順に並んでいるか確認する
##
## 使い方:
##   sx_num_lt [数値1 [数値2 ...]]
##
## 終了ステータス:
##    0  数値1 < 数値2 < ... である (SX_EX_OK)
##    1  条件を満たさない
##   64  数値でない引数が含まれる、または範囲外 (SX_EX_USAGE)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_num_lt() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_num_lt "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int "${@}" || return
	__sx_num_lt "${@}" || return
}

### __sx_num_lt - 引数が厳密な昇順に並んでいるか確認する（内部用）
##
## 使い方:
##   __sx_num_lt [数値1 [数値2 ...]]
##
## 説明:
##   sx_num_lt の内部実装。
##   引数チェックは行わない。
__sx_num_lt() {
	while M_STR_EQ([|"${2+X}"|], [|X|]); do
		M_STR_EQ([|"$((${1} < ${2}))"|], [|1|]) || return 1

		shift
	done
}

### sx_num_rel - 数値間の関係を確認する
##
## 使い方:
##   sx_num_rel [数値1 [演算子1 数値2 ...]]
##
## 説明:
##   数値と演算子を交互に指定し、すべての関係が満たされるかを確認する。
##   演算子には以下が使用可能：
##     eq, =   : 等しい
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

		sx_num_is_sx_num "${__sx_num_rel_arg}" || {
			set -- "${?}"
			unset __sx_num_rel_arg
			case "${1}" in
				1) return "${SX_EX_USAGE}";;
				*) return "${1}";;
			esac
		}
	done

	unset __sx_num_rel_arg

	__sx_num_rel "${@}" || return
}

### __sx_num_rel_classify - 比較方式を分類する（内部用）
##
## 結果:
##   arith  算術展開比較
##   dec    10進整数文字列比較
##   norm   正規化数値比較
__sx_num_rel_classify() {
	__sx_num_rel_classify_res_="${1}"
	__sx_num_rel_classify_arg_="${2}"

	case "${__sx_num_rel_classify_arg_}" in
		*.* | *[Ee]*) eval "${__sx_num_rel_classify_res_}=norm";;
		0[Xx]* | [+-]0[Xx]* | 0[0-9]* | [+-]0[0-9]*) eval "${__sx_num_rel_classify_res_}=arith";;
		*)
			__sx_num_rel_classify_abs_="${__sx_num_rel_classify_arg_#+}"
			case "${__sx_num_rel_classify_abs_}" in
				-*) __sx_num_rel_classify_abs_="${__sx_num_rel_classify_abs_#-}";;
			esac

			case "$((${#__sx_num_rel_classify_abs_} <= __sx_num_rel_wlen_))" in
				1) eval "${__sx_num_rel_classify_res_}=arith";;
				*) eval "${__sx_num_rel_classify_res_}=dec";;
			esac
			;;
	esac

	unset __sx_num_rel_classify_res_ __sx_num_rel_classify_arg_ __sx_num_rel_classify_abs_
}

### __sx_num_rel_cmp_fast_int - 整数を算術展開で比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_rel_cmp_fast_int() {
	case "$(( ${1} < ${2} ))" in 1) return 1; esac
	case "$(( ${1} > ${2} ))" in 1) return 3; esac
	return 2
}

### __sx_num_rel_cmp_dec_chunk - 同じ長さの10進整数文字列を左から比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_rel_cmp_dec_chunk() {
	set -- "${1}" "${2}"

	while M_STR_NE([|"${1}"|], [|''|]); do
		__sx_str_substr __sx_num_rel_cmp_dec_chunk_lhs_ "${1}" 0 "${__sx_num_rel_wlen_}"
		__sx_str_substr __sx_num_rel_cmp_dec_chunk_rhs_ "${2}" 0 "${__sx_num_rel_wlen_}"

		if M_NUM_LT([|${__sx_num_rel_cmp_dec_chunk_lhs_}|], [|${__sx_num_rel_cmp_dec_chunk_rhs_}|]); then
			unset __sx_num_rel_cmp_dec_chunk_lhs_ __sx_num_rel_cmp_dec_chunk_rhs_
			return 1
		elif M_NUM_LT([|${__sx_num_rel_cmp_dec_chunk_rhs_}|], [|${__sx_num_rel_cmp_dec_chunk_lhs_}|]); then
			unset __sx_num_rel_cmp_dec_chunk_lhs_ __sx_num_rel_cmp_dec_chunk_rhs_
			return 3
		fi

		set -- "${1#"${__sx_num_rel_cmp_dec_chunk_lhs_}"}" "${2#"${__sx_num_rel_cmp_dec_chunk_rhs_}"}"
	done

	unset __sx_num_rel_cmp_dec_chunk_lhs_ __sx_num_rel_cmp_dec_chunk_rhs_
	return 2
}

### __sx_num_rel_cmp_uint_dec - 符号なし10進整数文字列を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_rel_cmp_uint_dec() {
	case 1 in
		"$((${#1} < ${#2}))") return 1;;
		"$((${#2} < ${#1}))") return 3;;
	esac

	__sx_num_rel_cmp_dec_chunk "${1}" "${2}" || return "${?}"
}

### __sx_num_rel_cmp_dec_int - 10進整数文字列を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_rel_cmp_dec_int() {
	case "${1}" in
		-*)
			__sx_num_rel_cmp_dec_int_lsgn_='-'
			__sx_num_rel_cmp_dec_int_labs_="${1#-}"
			;;
		*)
			__sx_num_rel_cmp_dec_int_lsgn_='+'
			__sx_num_rel_cmp_dec_int_labs_="${1#+}"
			;;
	esac

	case "${2}" in
		-*)
			__sx_num_rel_cmp_dec_int_rsgn_='-'
			__sx_num_rel_cmp_dec_int_rabs_="${2#-}"
			;;
		*)
			__sx_num_rel_cmp_dec_int_rsgn_='+'
			__sx_num_rel_cmp_dec_int_rabs_="${2#+}"
			;;
	esac

	case "${__sx_num_rel_cmp_dec_int_lsgn_}${__sx_num_rel_cmp_dec_int_rsgn_}" in
		-+)
			unset __sx_num_rel_cmp_dec_int_lsgn_ __sx_num_rel_cmp_dec_int_labs_ __sx_num_rel_cmp_dec_int_rsgn_ __sx_num_rel_cmp_dec_int_rabs_
			return 1
			;;
		+-)
			unset __sx_num_rel_cmp_dec_int_lsgn_ __sx_num_rel_cmp_dec_int_labs_ __sx_num_rel_cmp_dec_int_rsgn_ __sx_num_rel_cmp_dec_int_rabs_
			return 3
			;;
	esac

	if M_STR_EQ([|"${__sx_num_rel_cmp_dec_int_lsgn_}"|], [|-|]); then
		__sx_num_rel_cmp_uint_dec "${__sx_num_rel_cmp_dec_int_rabs_}" "${__sx_num_rel_cmp_dec_int_labs_}" || set -- "${?}"
	else
		__sx_num_rel_cmp_uint_dec "${__sx_num_rel_cmp_dec_int_labs_}" "${__sx_num_rel_cmp_dec_int_rabs_}" || set -- "${?}"
	fi
	unset __sx_num_rel_cmp_dec_int_lsgn_ __sx_num_rel_cmp_dec_int_labs_ __sx_num_rel_cmp_dec_int_rsgn_ __sx_num_rel_cmp_dec_int_rabs_
	return "${1}"
}

### __sx_num_rel_cmp_frac - 小数部を左から比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_rel_cmp_frac() {
	set -- "${1-}" "${2-}"

	while :; do
		case "${1}" in
			'') case "${2}" in
				'')
					unset __sx_num_rel_cmp_frac_lhs_ __sx_num_rel_cmp_frac_rhs_ __sx_num_rel_cmp_frac_lpad_ __sx_num_rel_cmp_frac_rpad_
					return 2
					;;
				*)
					unset __sx_num_rel_cmp_frac_lhs_ __sx_num_rel_cmp_frac_rhs_ __sx_num_rel_cmp_frac_lpad_ __sx_num_rel_cmp_frac_rpad_
					return 1
					;;
			esac;;
		esac

		case "${2}" in
			'')
				unset __sx_num_rel_cmp_frac_lhs_ __sx_num_rel_cmp_frac_rhs_ __sx_num_rel_cmp_frac_lpad_ __sx_num_rel_cmp_frac_rpad_
				return 3
				;;
		esac

		__sx_str_substr __sx_num_rel_cmp_frac_lhs_ "${1}" 0 "${__sx_num_rel_wlen_}"
		__sx_str_substr __sx_num_rel_cmp_frac_rhs_ "${2}" 0 "${__sx_num_rel_wlen_}"
		__sx_str_pad __sx_num_rel_cmp_frac_lpad_ "${__sx_num_rel_cmp_frac_lhs_}" "-${__sx_num_rel_wlen_}" 0
		__sx_str_pad __sx_num_rel_cmp_frac_rpad_ "${__sx_num_rel_cmp_frac_rhs_}" "-${__sx_num_rel_wlen_}" 0

		if M_NUM_LT([|${__sx_num_rel_cmp_frac_lpad_}|], [|${__sx_num_rel_cmp_frac_rpad_}|]); then
			unset __sx_num_rel_cmp_frac_lhs_ __sx_num_rel_cmp_frac_rhs_ __sx_num_rel_cmp_frac_lpad_ __sx_num_rel_cmp_frac_rpad_
			return 1
		elif M_NUM_LT([|${__sx_num_rel_cmp_frac_rpad_}|], [|${__sx_num_rel_cmp_frac_lpad_}|]); then
			unset __sx_num_rel_cmp_frac_lhs_ __sx_num_rel_cmp_frac_rhs_ __sx_num_rel_cmp_frac_lpad_ __sx_num_rel_cmp_frac_rpad_
			return 3
		fi

		set -- "${1#"${__sx_num_rel_cmp_frac_lhs_}"}" "${2#"${__sx_num_rel_cmp_frac_rhs_}"}"
	done
}

### __sx_num_rel_cmp_norm_abs - 正規化済み絶対値同士を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_rel_cmp_norm_abs() {
	case "${1}" in
		*.*) set -- "${1%%.*}" "${2}" "${1#*.}";;
		*) set -- "${1}" "${2}" '';;
	esac

	case "${2}" in
		*.*) set -- "${1}" "${2%%.*}" "${3}" "${2#*.}";;
		*) set -- "${1}" "${2}" "${3}" '';;
	esac

	__sx_num_rel_cmp_uint_dec "${1}" "${2}" || case "${?}" in 1 | 3)
		return "${?}"
	esac

	__sx_num_rel_cmp_frac "${3}" "${4}" || return "${?}"
}

### __sx_num_rel_cmp_norm - 正規化済み数値を比較する（内部用）
##
## 終了ステータス:
##   1  左辺 < 右辺
##   2  左辺 = 右辺
##   3  左辺 > 右辺
__sx_num_rel_cmp_norm() {
	set -- "${1#[+-]}" "${2#[+-]}" "${1%%[!-]*}" "${2%%[!-]*}"

	case "${3:-+}${4:-+}" in
		-+) return 1;;
		+-) return 3;;
	esac

	case "${3}" in
		-*) __sx_num_rel_cmp_norm_abs "${2}" "${1}";;
		*) __sx_num_rel_cmp_norm_abs "${1}" "${2}";;
	esac || return "${?}"
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
	__sx_num_rel_op_='=='
	__sx_num_rel_wlen_=$(((SX_CFG_NUM_RANGE - 1) * 30103 / 100000))
	case "${__sx_num_rel_wlen_}" in 0) __sx_num_rel_wlen_=1;; esac

	for __sx_num_rel_arg_ in "${@}"; do
		case "${__sx_num_rel_arg_}" in
			eq | '==')  __sx_num_rel_op_='==';;
			ne | '!=') __sx_num_rel_op_='!=';;
			lt | '<')  __sx_num_rel_op_='<';;
			le | '<=') __sx_num_rel_op_='<=';;
			gt | '>')  __sx_num_rel_op_='>';;
			ge | '>=') __sx_num_rel_op_='>=';;
			*) ! :;;
		esac && continue

		case "${__sx_num_rel_lhs_+X}" in X)
			__sx_num_rel_classify __sx_num_rel_lcls_ "${__sx_num_rel_lhs_}"
			__sx_num_rel_classify __sx_num_rel_rcls_ "${__sx_num_rel_arg_}"

			case "${__sx_num_rel_lcls_}:${__sx_num_rel_rcls_}" in
				arith:arith)
					__sx_num_rel_cmp_fast_int "${__sx_num_rel_lhs_}" "${__sx_num_rel_arg_}" || __sx_num_rel_cmp_="${?}"
					unset __sx_num_rel_rhs_norm_
					;;
				dec:dec)
					__sx_num_rel_cmp_dec_int "${__sx_num_rel_lhs_}" "${__sx_num_rel_arg_}" || __sx_num_rel_cmp_="${?}"
					unset __sx_num_rel_rhs_norm_
					;;
				*)
					case "${__sx_num_rel_lhs_norm_+X}" in '')
						__sx_num_norm __sx_num_rel_lhs_norm_ "${__sx_num_rel_lhs_}"
					esac

					__sx_num_norm __sx_num_rel_rhs_norm_ "${__sx_num_rel_arg_}"
					__sx_num_rel_cmp_norm "${__sx_num_rel_lhs_norm_}" "${__sx_num_rel_rhs_norm_}" || __sx_num_rel_cmp_="${?}"
					;;
			esac

			case "${__sx_num_rel_op_}:${__sx_num_rel_cmp_}" in
				'==:2' | '!=:1' | '!=:3' | '<:1' | '<=:1' | '<=:2' | '>:3' | '>=:2' | '>=:3') ;;
				*)
					unset __sx_num_rel_op_ __sx_num_rel_wlen_ __sx_num_rel_lhs_ __sx_num_rel_lhs_norm_ __sx_num_rel_lcls_ __sx_num_rel_rcls_ __sx_num_rel_rhs_norm_ __sx_num_rel_cmp_ __sx_num_rel_arg_
					return 1
					;;
			esac

			case "${__sx_num_rel_rhs_norm_+X}" in
				'') unset __sx_num_rel_lhs_norm_;;
				*) __sx_num_rel_lhs_norm_="${__sx_num_rel_rhs_norm_}";;
			esac
		esac

			__sx_num_rel_lhs_="${__sx_num_rel_arg_}"
	done

	unset __sx_num_rel_op_ __sx_num_rel_wlen_ __sx_num_rel_lhs_ __sx_num_rel_lhs_norm_ __sx_num_rel_lcls_ __sx_num_rel_rcls_ __sx_num_rel_rhs_norm_ __sx_num_rel_cmp_ __sx_num_rel_arg_
}

### sx_num_range - 数値の範囲を生成する (Python range 互換)
##
## 使い方:
##   sx_num_range 宛先 終了
##   sx_num_range 宛先 開始 終了
##   sx_num_range 宛先 開始 終了 増分
##
## 説明:
##   指定された範囲の数値をスペース区切りで生成し、宛先変数に格納する。
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

	case $((${4-1})) in 0)
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
			: $(( __sx_num_range_cur_ += ${3} ))
		done
	else
		while M_NUM_LT([|${2}|], [|${__sx_num_range_cur_}|]); do
			__M_BIND_UNQUOTE([|__sx_num_range|], [|"${__sx_num_range_cur_}"|], CLEANUP)
			: $(( __sx_num_range_cur_ += ${3} ))
		done
	fi

	eval ${__sx_num_range_out_:+"${__sx_num_range_bind_}=\"\${__sx_num_range_out_}\""}

	unset CLEANUP
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

### sx_str_chunk - 文字列を一定の長さで区切って結果変数（またはバインドチェーン）に格納する
##
## 使い方:
##   sx_str_chunk スキーマ [文字列 [長さ [分割回数]]]
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
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  スキーマに含まれる変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_chunk() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_chunk "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${3+"${3}"} && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 ${4+"${4}"} || return
	case $((${3-1})) in 0) return "${SX_EX_USAGE}"; esac

	__sx_str_chunk "${@}"
}

define([|V|], [|__sx_str_chunk_$1_|])dnl
define([|CLEANUP|], [|V(bind) V(str) V(len) V(lim) V(out) V(qm) V(next) __M_BIND_USEVAR|])dnl

### __sx_str_chunk - 文字列を一定の長さで区切って結果変数に格納する（内部用）
##
## 使い方:
##   __sx_str_chunk 結果変数名 [文字列 [長さ [分割回数]]]
##
## 説明:
##   sx_str_chunk の内部実装。
##   引数チェックは行わない。
__sx_str_chunk() {
	__sx_var_bind_init "${1}"
	__sx_str_chunk_bind_="${1}"
	__sx_str_chunk_str_="${2-}"
	__sx_str_chunk_len_="$((${3-1}))"
	__sx_str_chunk_lim_="$((${4-${SX_NUM_I32_MAX}}))"

		__sx_str_rep __sx_str_chunk_qm_ '?' "${__sx_str_chunk_len_#[+-]}"

	if M_NUM_LT([|0|], [|__sx_str_chunk_len_|]); then
		# Forward: 早期終了をサポート
		__sx_str_chunk_out_=

		while
			M_NUM_LE([|__sx_str_chunk_len_|], [|${#__sx_str_chunk_str_}|]) &&
			M_STR_NE([|"${__sx_str_chunk_lim_}"|], [|0|])
		do
			__sx_str_chunk_next_="${__sx_str_chunk_str_#${__sx_str_chunk_qm_}}"
			__M_BIND_QUOTE([|__sx_str_chunk|], [|"${__sx_str_chunk_str_%"${__sx_str_chunk_next_}"}"|], CLEANUP)

			__sx_str_chunk_str_="${__sx_str_chunk_next_}"
			: $(( __sx_str_chunk_lim_ -= 1 ))
		done

		case "${__sx_str_chunk_str_}" in ?*)
			__M_BIND_QUOTE([|__sx_str_chunk|], [|"${__sx_str_chunk_str_}"|], CLEANUP)
		esac

		eval ${__sx_str_chunk_out_:+"${__sx_str_chunk_bind_}=\"\${__sx_str_chunk_out_}\""}
	else
		# Backward: 全走査が必要なため set -- で収集
		set --
		: $((__sx_str_chunk_len_ *= -1))

		while
			M_NUM_LE([|__sx_str_chunk_len_|], [|${#__sx_str_chunk_str_}|]) &&
			M_STR_NE([|"${__sx_str_chunk_lim_}"|], [|0|])
		do
			__sx_str_chunk_next_="${__sx_str_chunk_str_%${__sx_str_chunk_qm_}}"
			set -- "${__sx_str_chunk_str_#${__sx_str_chunk_next_}}" "${@}"
			__sx_str_chunk_str_="${__sx_str_chunk_next_}"
			: $(( __sx_str_chunk_lim_ -= 1 ))
		done

		case "${__sx_str_chunk_str_}" in ?*)
			set -- "${__sx_str_chunk_str_}" "${@}"
		esac

		__sx_arg_quote "${__sx_str_chunk_bind_}" "${@}"
	fi

	unset CLEANUP
}

### sx_str_isep - 文字列に一定の間隔でセパレータを挿入する
##
## 使い方:
##   sx_str_isep 結果変数名 文字列 セパレータ [インターバル [リミット]]
##
## 説明:
##   指定された文字列に対して、指定された間隔（インターバル）ごとにセパレータを挿入して結合する。
##   インターバルが正の場合は前方から、負の場合は後方から数えて挿入する。
##   リミットを指定すると、セパレータの挿入回数を制限できる。
##   インターバルに 0 は指定できない。デフォルトのインターバルは 1。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_isep() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_isep "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && \
	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${4+"${4}"} && \
	__sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_nat0 ${5+"${5}"} || return

	case $((${4-1})) in 0)
		return "${SX_EX_USAGE}"
	esac

	__sx_str_isep "${@}"
}

define([|V|], [|__sx_str_isep_$1_|])dnl
define([|CLEANUP|], [|V(res) V(str) V(sep) V(int) V(lim) V(out) V(qm) V(next)|])dnl

### __sx_str_isep - 文字列に一定の間隔でセパレータを挿入する（内部用）
##
## 使い方:
##   __sx_str_isep 結果変数名 文字列 セパレータ [インターバル [リミット]]
##
## 説明:
##   sx_str_isep の内部実装。
##   引数チェックは行わない。
__sx_str_isep() {
	__sx_str_isep_res_="${1}"
	__sx_str_isep_str_="${2-}"
	__sx_str_isep_sep_="${3-}"
	__sx_str_isep_int_="${4-1}"
	__sx_str_isep_lim_="$((${5-${SX_NUM_I32_MAX}}))"
	__sx_str_isep_out_=

	__sx_str_rep __sx_str_isep_qm_ '?' "${__sx_str_isep_int_#[+-]}"

	if M_NUM_LT([|0|], [|__sx_str_isep_int_|]); then
		# Forward
		while
			M_NUM_LT([|__sx_str_isep_int_|], [|${#__sx_str_isep_str_}|]) &&
			M_STR_NE([|"${__sx_str_isep_lim_}"|], [|0|])
		do
			__sx_str_isep_next_="${__sx_str_isep_str_#${__sx_str_isep_qm_}}"
			__sx_str_isep_out_="${__sx_str_isep_out_}${__sx_str_isep_str_%"${__sx_str_isep_next_}"}${__sx_str_isep_sep_}"
			__sx_str_isep_str_="${__sx_str_isep_next_}"
			: $((__sx_str_isep_lim_ -= 1))
		done

		__sx_str_isep_out_="${__sx_str_isep_out_}${__sx_str_isep_str_}"
	else
		# Backward
		: $((__sx_str_isep_int_ *= -1))

		while
			M_NUM_LT([|__sx_str_isep_int_|], [|${#__sx_str_isep_str_}|]) &&
			M_STR_NE([|"${__sx_str_isep_lim_}"|], [|0|])
		do
			__sx_str_isep_next_="${__sx_str_isep_str_%${__sx_str_isep_qm_}}"
			__sx_str_isep_out_="${__sx_str_isep_sep_}${__sx_str_isep_str_#${__sx_str_isep_next_}}${__sx_str_isep_out_}"
			__sx_str_isep_str_="${__sx_str_isep_next_}"
			: $((__sx_str_isep_lim_ -= 1))
		done

		__sx_str_isep_out_="${__sx_str_isep_str_}${__sx_str_isep_out_}"
	fi

	__sx_var_set "${__sx_str_isep_res_}=${__sx_str_isep_out_}"

	unset CLEANUP
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

### sx_str_is_hex - すべての引数が数字のみで構成されている（空でない）か確認する
##
## 使い方:
##   sx_str_is_hex [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて数字のみで構成されている (SX_EX_OK)
##    1  数字以外が含まれる、または空文字列が含まれる
sx_str_is_hex() {
	for __sx_str_is_hex_arg in "${@}"; do
		case "${__sx_str_is_hex_arg}" in '' | *[!0-9A-Fa-f]*)
			unset __sx_str_is_hex_arg
			return 1
		esac
	done

	unset __sx_str_is_hex_arg
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
	for __sx_str_is_digit_arg in "${@}"; do
		case "${__sx_str_is_digit_arg}" in '' | *[!0-9]*)
			unset __sx_str_is_digit_arg
			return 1
		esac
	done

	unset __sx_str_is_digit_arg
}

### sx_str_is_oct - すべての引数が8進数（0-7）のみで構成されている（空でない）か確認する
##
## 使い方:
##   sx_str_is_oct [文字列1 [文字列2 ...]]
##
## 終了ステータス:
##    0  すべて8進数のみで構成されている (SX_EX_OK)
##    1  8進数以外が含まれる、または空文字列が含まれる
sx_str_is_oct() {
	for __sx_str_is_oct_arg in "${@}"; do
		case "${__sx_str_is_oct_arg}" in '' | *[!0-7]*)
			unset __sx_str_is_oct_arg
			return 1
		esac
	done

	unset __sx_str_is_oct_arg
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

	while M_STR_NE([|"${3}"|], [|0|]); do
		case "$((${3} % 2))" in 1)
			__sx_str_rep_out_="${__sx_str_rep_out_}${2}"
		esac

		set -- "${1}" "${2}${2}" "$((${3} / 2))"
	done

	__sx_var_set "${1}=${__sx_str_rep_out_}"
	unset __sx_str_rep_out_
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

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${3+"${3}"} || return

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

	__sx_str_rep __sx_str_pad_rep_ "${4}" "$(( (__sx_str_pad_needed_ - 1) / ${#4} + 1 ))"
	__sx_str_substr __sx_str_pad_fill_ "${__sx_str_pad_rep_}" 0 "${__sx_str_pad_needed_}"

	case "${3}" in
		-*) __sx_var_set "${1}=${2}${__sx_str_pad_fill_}";;
		*) __sx_var_set "${1}=${__sx_str_pad_fill_}${2}";;
	esac

	unset __sx_str_pad_needed_ __sx_str_pad_rep_ __sx_str_pad_fill_
}

### sx_str_center - 文字列を指定された幅で中央寄せする
##
## 使い方:
##   sx_str_center 結果変数名 文字列 幅 [埋め込み文字列]
##
## 説明:
##   文字列の長さが「幅」の絶対値に満たない場合、埋め込み文字列で中央寄せするように埋める。
##   幅が正の場合、余り（奇数の場合）は右側に振る。
##   幅が負の場合、余りは左側に振る。
##   埋め込み文字列が指定されない場合は半角スペースを使用する。
##   埋め込み文字列が明示的に空の場合は何もせずそのまま返す。
##   元の文字列が既に指定された幅以上の場合は、そのまま返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
sx_str_center() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_center "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${3+"${3}"} || return

	__sx_str_center "${@}"
}

### __sx_str_center - 文字列を指定された幅で中央寄せする（内部用）
##
## 使い方:
##   __sx_str_center 結果変数名 文字列 幅 [埋め込み文字列]
##
## 説明:
##   sx_str_center の内部実装。
##   引数チェックは行わないが、埋め込み文字列が空の場合は何もせず成功を返す。
__sx_str_center() {
	set -- "${1}" "${2-}" "${3-0}" "${4- }"

	__sx_str_center_needed_=$((${3#-} - ${#2}))

	M_NUM_LT([|0|], [|__sx_str_center_needed_|]) && M_STR_NE([|"${4}"|], [|''|]) || {
		__sx_var_set "${1}=${2}"
		unset __sx_str_center_needed_
		return "${SX_EX_OK}"
	}

	__sx_str_rep __sx_str_center_rep_ "${4}" "$(( ( (__sx_str_center_needed_ + 1) / 2 - 1 ) / ${#4} + 1 ))"
	__sx_str_substr __sx_str_center_spad_ "${__sx_str_center_rep_}" 0 "$(( (__sx_str_center_needed_ + (${3} < 0)) / 2 ))"

	__sx_str_substr __sx_str_center_epad_ "${__sx_str_center_rep_}" 0 "$(( __sx_str_center_needed_ - ${#__sx_str_center_spad_} ))"

	__sx_var_set "${1}=${__sx_str_center_spad_}${2}${__sx_str_center_epad_}"

	unset __sx_str_center_needed_ __sx_str_center_rep_ __sx_str_center_spad_ __sx_str_center_epad_
}

### sx_str_split - 文字列を分割して結果変数に格納する
##
## 使い方:
##   sx_str_split 結果変数名 [文字列 [区切り文字 [分割回数 [フラグ]]]]
##
## 説明:
##   指定された文字列を区切り文字で分割し、
##   各要素をシングルクォートで囲み、スペース区切りで結合した文字列として結果変数に格納する。
##   分割回数（limit）が指定された場合、最大でその回数分だけ分割を行う。
##   分割回数が正の場合は前方から、負の場合は後方から分割する。
##   フラグに SX_STR_SPLIT_GLOB を指定すると、区切り文字を glob パターンとして扱う。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  変数が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_split() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_split "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_bindable "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${4+"${4}"} ${5+"${5}"} || return

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
	if M_STR_EQ([|"${__sx_str_split_sep_}"|], [|''|]); then
		if M_NUM_LT([|0|], [|__sx_str_split_lim_|]); then
			# 前方から制限数分だけ分割
			__sx_str_chunk __sx_str_split_out_ "${__sx_str_split_str_}" 1 "$((__sx_str_split_lim_ - 1))"

			case $((${#__sx_str_split_str_} < __sx_str_split_lim_)) in 1)
				__sx_str_split_out_="${__sx_str_split_out_} ''"
			esac

			__sx_str_split_out_="'' ${__sx_str_split_out_# }"
		elif M_NUM_LT([|__sx_str_split_lim_|], [|0|]); then
			# 後方から制限数分だけ分割
			__sx_str_split_lim_=$((__sx_str_split_lim_ * -1))
			__sx_str_chunk __sx_str_split_out_ "${__sx_str_split_str_}" -1 "$((__sx_str_split_lim_ - 1))"

			case $((${#__sx_str_split_str_} < __sx_str_split_lim_)) in 1)
				__sx_str_split_out_="'' ${__sx_str_split_out_}"
			esac

			__sx_str_split_out_="${__sx_str_split_out_% } ''"
		else
			# 制限なし：文字列全体をクォートして格納
			__sx_arg_quote __sx_str_split_out_ "${__sx_str_split_str_}"
		fi

		case "${__sx_str_split_inc_}" in 1)
			eval __sx_arg_isep __sx_str_split_out_ "${SX_CFG_SEP}" "${__sx_str_split_out_}"
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
				: $(( __sx_str_split_lim_ -= 1 ))
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
				: $(( __sx_str_split_lim_ -= 1 ))
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
				: $(( __sx_str_split_lim_ += 1 ))
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
				: $(( __sx_str_split_lim_ += 1 ))
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

	case "${__sx_str_split_ifs_opts_}" in *f*)
		set +f
	esac

	__sx_arg_quote "${__sx_str_split_ifs_res_}" "${@}"

	unset __sx_str_split_ifs_res_ __sx_str_split_ifs_opts_
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
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_sub() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_sub "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${5+"${5}"} ${6+"${6}"} || return

	__sx_str_sub "${@}"
}

### __sx_str_sub - 文字列内のパターンを置換する（内部用）
##
## 使い方:
##   __sx_str_sub 結果変数名 [元文字列 [検索パターン [置換文字列 [回数制限 [フラグ]]]]]
##
## 説明:
##   sx_str_sub の内部実装。
##   引数チェックは行わない。
__sx_str_sub() {
	__sx_str_sub_res_="${1}"
	__sx_str_sub_str_="${2-}"
	__sx_str_sub_pat_="${3-}"
	__sx_str_sub_rep_="${4-}"
	__sx_str_sub_lim_="$((${5-${SX_NUM_I32_MAX}}))"
	__sx_str_sub_flg_="$((${6-0}))"
	__sx_str_sub_out_=

	# パターンが空の場合は、文字間および両端に挿入（回数制限に従う）
	if M_STR_EQ([|"${__sx_str_sub_pat_}"|], [|''|]); then
		if M_NUM_LT([|0|], [|__sx_str_sub_lim_|]); then
			# 前向き挿入
			__sx_str_isep __sx_str_sub_out_ "${__sx_str_sub_str_}" "${__sx_str_sub_rep_}" 1 $((__sx_str_sub_lim_ - 1))
			__sx_str_sub_out_="${__sx_str_sub_rep_}${__sx_str_sub_out_}"
			case $((${#__sx_str_sub_str_} != 0 && ${#__sx_str_sub_str_} < __sx_str_sub_lim_)) in 1)
				__sx_str_sub_out_="${__sx_str_sub_out_}${__sx_str_sub_rep_}"
			esac
		elif M_NUM_LT([|__sx_str_sub_lim_|], [|0|]); then
			# 後ろ向き挿入
			__sx_str_sub_lim_=$((__sx_str_sub_lim_ * -1))
			__sx_str_isep __sx_str_sub_out_ "${__sx_str_sub_str_}" "${__sx_str_sub_rep_}" -1 $((__sx_str_sub_lim_ - 1))
			__sx_str_sub_out_="${__sx_str_sub_out_}${__sx_str_sub_rep_}"
			case $((${#__sx_str_sub_str_} != 0 && ${#__sx_str_sub_str_} < __sx_str_sub_lim_)) in 1)
				__sx_str_sub_out_="${__sx_str_sub_rep_}${__sx_str_sub_out_}"
			esac
		else
			__sx_str_sub_out_="${__sx_str_sub_str_}"
		fi
	elif M_NUM_LE([|0|], [|__sx_str_sub_lim_|]); then
		# 前向き置換 (Forward)
		if M_NUM_NE([|$((__sx_str_sub_flg_ & SX_STR_SUB_GLOB))|], [|0|]); then
			while
				M_STR_HAS([|"${__sx_str_sub_str_}"|], [|${__sx_str_sub_pat_}|]) &&
				M_STR_NE([|"${__sx_str_sub_lim_}"|], [|0|])
			do
				__sx_str_sub_val_="${__sx_str_sub_str_%%${__sx_str_sub_pat_}*}"
				__sx_str_sub_out_="${__sx_str_sub_out_}${__sx_str_sub_val_}${__sx_str_sub_rep_}"
				__sx_str_sub_str_="${__sx_str_sub_str_#${__sx_str_sub_val_}}"
				__sx_str_sub_tmp_="${__sx_str_sub_str_#${__sx_str_sub_pat_}}"
				__sx_str_sub_str_="${__sx_str_sub_tmp_}"
				: $(( __sx_str_sub_lim_ -= 1 ))
			done
		else
			while
				M_STR_HAS([|"${__sx_str_sub_str_}"|], [|"${__sx_str_sub_pat_}"|]) &&
				M_STR_NE([|"${__sx_str_sub_lim_}"|], [|0|])
			do
				__sx_str_sub_out_="${__sx_str_sub_out_}${__sx_str_sub_str_%%"${__sx_str_sub_pat_}"*}${__sx_str_sub_rep_}"
				__sx_str_sub_str_="${__sx_str_sub_str_#*"${__sx_str_sub_pat_}"}"
				: $(( __sx_str_sub_lim_ -= 1 ))
			done
		fi

		__sx_str_sub_out_="${__sx_str_sub_out_}${__sx_str_sub_str_}"
	else
		# 後ろ向き置換 (Backward)
		if M_NUM_NE([|$((__sx_str_sub_flg_ & SX_STR_SUB_GLOB))|], [|0|]); then
			while
				M_STR_HAS([|"${__sx_str_sub_str_}"|], [|${__sx_str_sub_pat_}|]) &&
				M_STR_NE([|"${__sx_str_sub_lim_}"|], [|0|])
			do
				__sx_str_sub_val_="${__sx_str_sub_str_##*${__sx_str_sub_pat_}}"
				__sx_str_sub_out_="${__sx_str_sub_rep_}${__sx_str_sub_val_}${__sx_str_sub_out_}"
				__sx_str_sub_str_="${__sx_str_sub_str_%${__sx_str_sub_val_}}"
				__sx_str_sub_tmp_="${__sx_str_sub_str_%${__sx_str_sub_pat_}}"
				__sx_str_sub_str_="${__sx_str_sub_tmp_}"
				: $(( __sx_str_sub_lim_ += 1 ))
			done
		else
			while
				M_STR_HAS([|"${__sx_str_sub_str_}"|], [|"${__sx_str_sub_pat_}"|]) &&
				M_STR_NE([|"${__sx_str_sub_lim_}"|], [|0|])
			do
				__sx_str_sub_out_="${__sx_str_sub_rep_}${__sx_str_sub_str_##*"${__sx_str_sub_pat_}"}${__sx_str_sub_out_}"
				__sx_str_sub_str_="${__sx_str_sub_str_%"${__sx_str_sub_pat_}"*}"
				: $(( __sx_str_sub_lim_ += 1 ))
			done
		fi

		__sx_str_sub_out_="${__sx_str_sub_str_}${__sx_str_sub_out_}"
	fi

	__sx_var_set "${__sx_str_sub_res_}=${__sx_str_sub_out_}"
	unset __sx_str_sub_res_ __sx_str_sub_str_ __sx_str_sub_pat_ __sx_str_sub_rep_ __sx_str_sub_lim_ __sx_str_sub_flg_ __sx_str_sub_out_ __sx_str_sub_next_ __sx_str_sub_val_ __sx_str_sub_tmp_
}

### sx_str_substr - 文字列の指定した位置から指定した長さの部分文字列を取得する
##
## 使い方:
##   sx_str_substr 結果変数名 [元文字列 [オフセット [長さ]]]
##
## 説明:
##   元文字列のオフセット（0開始）から指定された長さ分だけ抽出し、結果変数に格納する。
##   長さが省略された場合、または末尾を超える場合は末尾まで抽出する。
##   オフセットが文字列長以上の場合は空文字列を返す。
##
## 終了ステータス:
##    0  成功 (SX_EX_OK)
##   64  引数不正 (SX_EX_USAGE)
##   77  結果変数名が読み取り専用 (SX_EX_NOPERM)
##   78  SX_CFG_NUM_RANGE の値が不正 (SX_EX_CONFIG)
sx_str_substr() {
	case "${SX_CFG_SKIP_CHK-}" in 1) __sx_str_substr "${@}" || return; return 0;; esac

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${3+"${3}"} ${4+"${4}"} || return

	__sx_str_substr "${@}"
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

	__sx_ex_remap "1:${SX_EX_NOPERM}" sx_var_is_rw_all "${1-}" && __sx_ex_remap "1:${SX_EX_USAGE}" sx_num_is_sx_int ${3+"${3}"} ${4+"${4}"} || return

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

undefine([|CLEANUP|]) dnl
undefine([|V|]) dnl

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
	case $((V(off) < 0)) in 1)
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

undefine([|CLEANUP|]) dnl
undefine([|V|]) dnl

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

	__sx_str_strim __sx_str_trim_tmp_ "${2}" "${3}"
	__sx_str_etrim "${1}" "${__sx_str_trim_tmp_}" "${3}"

	unset __sx_str_trim_tmp_
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
		case $((__sx_arr_at_i < __sx_arr_at_len)) in 0)
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
		case $((__sx_arr_at_i_ < __sx_arr_at_len_)) in 0)
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
	__sx_arg_norm __sx_arr_pop_args - "${@}"
	eval set -- "${__sx_arr_pop_args}"
	unset __sx_arr_pop_args

	# 要素数チェック
	case $((${#} <= __sx_arr_pop_len)) in 0)
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
		: $(( __sx_arr_pop_i -= 1 ))

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
	__sx_arg_norm __sx_arr_pop_args_ - "${@}"
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

	case $((${#} <= __sx_arr_pop0_len_)) in 0)
		unset __sx_arr_pop0_arr_ __sx_arr_pop0_len_
		return 1
	esac

	for __sx_arr_pop0_dest_ in "${@}"; do
		: $(( __sx_arr_pop0_len_ -= 1 ))
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
			eval __sx_arg_quote __sx_arr_quote_esc_ "\"\${${__sx_arr_quote_arr_}_${1}}\""
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
			eval __sx_arg_quote __sx_arr_rquote_esc_ "\"\${${__sx_arr_rquote_arr_}_${1}}\""
			__sx_arr_rquote_out_=" ${__sx_arr_rquote_esc_}${__sx_arr_rquote_out_}"

			set -- "$((${1} + 1))" "${2}"
		done
	done

	__sx_var_set "${__sx_arr_rquote_res_}=${__sx_arr_rquote_out_# }"

	unset __sx_arr_rquote_res_ __sx_arr_rquote_out_ __sx_arr_rquote_arr_ __sx_arr_rquote_esc_
}
