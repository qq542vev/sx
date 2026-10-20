dnl 定義と依存宣言はこのファイルで管理する。
divert(-1)dnl
changequote([|, |])dnl
changecom()dnl

dnl 分割ファイルの依存メタ情報。全体展開時には実行時コードを出力しない。
define([|M_REQUIRE|], [||])dnl
define([|M_UNIT|], [|include([|$2|])|])dnl

define([|M_STR_NE|], [|case $1 in $2) ! :;; esac|])dnl
define([|M_VAR_SET|], [|ifelse($#, 1, [|ifelse($1, , [|eval|], [|eval "$1="|])|], [|eval "$1="'"$2"'__M_VAR_SET_REST(shift(shift($@)))|])|])dnl
define([|__M_VAR_SET_REST|], [|ifelse(eval(1 < $#), 1, [| "$1="'"$2"'ifelse($#, 2, , [|__M_VAR_SET_REST(shift(shift($@)))|])|], [|ifelse($1, , , [| "$1="|])|])|])dnl
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

# 生の文字列をシェルの単一引用符で囲む。バックスラッシュ・制御文字もそのまま保持する。
# 単一引用符は引用の外でエスケープし、連続部分の間に生じる空の引用をまとめて除く。
# 各段階で m4 の引用を保持し、値に含まれるマクロ名・カンマ・括弧の再解釈を防ぐ。
define([|M_SH_QUOTE|], [|'__M_SH_QUOTE_JOIN(__M_SH_QUOTE_APOS([|$1|]))'|])dnl
define([|__M_SH_QUOTE_APOS|], [|patsubst([|[|$1|]|], [|'|], [|'\\''|])|])dnl
define([|__M_SH_QUOTE_JOIN|], [|ifelse(regexp([|$1|], [|\\'''\\'|]), -1, [|[|$1|]|], [|__M_SH_QUOTE_JOIN(patsubst([|[|$1|]|], [|\\'''\\'|], [|\\'\\'|]))|])|])dnl

# 接頭辞なしの定数名から M_* の値を展開し、readonly SX_* の宣言を生成する。
# 非空で Portable Filename Character Set の文字だけを含む値は引用を省略する。
# それ以外は M_SH_QUOTE に渡す。判定中と出力時も m4 の引用を保持する。
define([|M_CONST|], [|readonly SX_$1=__M_CONST_VALUE(indir([|M_$1|]))|])dnl
define([|__M_CONST_VALUE|], [|ifelse([|$1|], [||], [|M_SH_QUOTE([||])|], len(translit([|[|$1|]|], [|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-|])), 0, [|[|$1|]|], [|M_SH_QUOTE([|$1|])|])|])dnl

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
{ case $1 in $2);; *) ! :;; esac ifelse(eval(2 < $#), 1, [|&& __M_STR_EQ_REST(shift($@))|]); }dnl
|])dnl
define([|__M_STR_EQ_REST|], [|dnl
case $1 in $2);; *) ! :;; esac ifelse(eval(2 < $#), 1, [| && __M_STR_EQ_REST(shift($@))|])dnl
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

# 定数マクロ
# 固定定数の値は M_* で管理する。
# 引数の区切りになる固定値は、定義側で展開後も引用を保持する。
# トークン境界の保護が必要な合成では、合成側に空引用を置く。
# 合成もビルド時に完了させ、実行時の定数参照を生成しない。

define([|M_EX_STS0|], [|OK|])dnl
define([|M_EX_STS64|], [|USAGE|])dnl
define([|M_EX_STS65|], [|DATAERR|])dnl
define([|M_EX_STS66|], [|NOINPUT|])dnl
define([|M_EX_STS67|], [|NOUSER|])dnl
define([|M_EX_STS68|], [|NOHOST|])dnl
define([|M_EX_STS69|], [|UNAVAILABLE|])dnl
define([|M_EX_STS70|], [|SOFTWARE|])dnl
define([|M_EX_STS71|], [|OSERR|])dnl
define([|M_EX_STS72|], [|OSFILE|])dnl
define([|M_EX_STS73|], [|CANTCREAT|])dnl
define([|M_EX_STS74|], [|IOERR|])dnl
define([|M_EX_STS75|], [|TEMPFAIL|])dnl
define([|M_EX_STS76|], [|PROTOCOL|])dnl
define([|M_EX_STS77|], [|NOPERM|])dnl
define([|M_EX_STS78|], [|CONFIG|])dnl

define([|M_EX_MSG0|], [|EX_OK(0): successful termination|])dnl
define([|M_EX_MSG64|], [|EX_USAGE(64): command line usage error|])dnl
define([|M_EX_MSG65|], [|EX_DATAERR(65): data format error|])dnl
define([|M_EX_MSG66|], [|EX_NOINPUT(66): cannot open input|])dnl
define([|M_EX_MSG67|], [|EX_NOUSER(67): addressee unknown|])dnl
define([|M_EX_MSG68|], [|EX_NOHOST(68): host name unknown|])dnl
define([|M_EX_MSG69|], [|EX_UNAVAILABLE(69): service unavailable|])dnl
define([|M_EX_MSG70|], [|EX_SOFTWARE(70): internal software error|])dnl
define([|M_EX_MSG71|], [|EX_OSERR(71): system error (e.g., can't fork)|])dnl
define([|M_EX_MSG72|], [|EX_OSFILE(72): critical OS file missing|])dnl
define([|M_EX_MSG73|], [|EX_CANTCREAT(73): can't create (user) output file|])dnl
define([|M_EX_MSG74|], [|EX_IOERR(74): input/output error|])dnl
define([|M_EX_MSG75|], [|EX_TEMPFAIL(75): temp failure; user is invited to retry|])dnl
define([|M_EX_MSG76|], [|EX_PROTOCOL(76): remote error in protocol|])dnl
define([|M_EX_MSG77|], [|EX_NOPERM(77): permission denied|])dnl
define([|M_EX_MSG78|], [|EX_CONFIG(78): configuration error|])dnl

define([|M_STR_SOH|], [|format([|%c|], 1)|])dnl
define([|M_STR_STX|], [|format([|%c|], 2)|])dnl
define([|M_STR_ETX|], [|format([|%c|], 3)|])dnl
define([|M_STR_EOT|], [|format([|%c|], 4)|])dnl
define([|M_STR_ENQ|], [|format([|%c|], 5)|])dnl
define([|M_STR_ACK|], [|format([|%c|], 6)|])dnl
define([|M_STR_BEL|], [|format([|%c|], 7)|])dnl
define([|M_STR_BS|], [|format([|%c|], 8)|])dnl
define([|M_STR_HT|], [|format([|%c|], 9)|])dnl
define([|M_STR_LF|], [|format([|%c|], 10)|])dnl
define([|M_STR_VT|], [|format([|%c|], 11)|])dnl
define([|M_STR_FF|], [|format([|%c|], 12)|])dnl
define([|M_STR_CR|], [|format([|%c|], 13)|])dnl
define([|M_STR_SO|], [|format([|%c|], 14)|])dnl
define([|M_STR_SI|], [|format([|%c|], 15)|])dnl
define([|M_STR_DLE|], [|format([|%c|], 16)|])dnl
define([|M_STR_DC1|], [|format([|%c|], 17)|])dnl
define([|M_STR_DC2|], [|format([|%c|], 18)|])dnl
define([|M_STR_DC3|], [|format([|%c|], 19)|])dnl
define([|M_STR_DC4|], [|format([|%c|], 20)|])dnl
define([|M_STR_NAK|], [|format([|%c|], 21)|])dnl
define([|M_STR_SYN|], [|format([|%c|], 22)|])dnl
define([|M_STR_ETB|], [|format([|%c|], 23)|])dnl
define([|M_STR_CAN|], [|format([|%c|], 24)|])dnl
define([|M_STR_EM|], [|format([|%c|], 25)|])dnl
define([|M_STR_SUB|], [|format([|%c|], 26)|])dnl
define([|M_STR_ESC|], [|format([|%c|], 27)|])dnl
define([|M_STR_FS|], [|format([|%c|], 28)|])dnl
define([|M_STR_GS|], [|format([|%c|], 29)|])dnl
define([|M_STR_RS|], [|format([|%c|], 30)|])dnl
define([|M_STR_US|], [|format([|%c|], 31)|])dnl
define([|M_STR_DEL|], [|format([|%c|], 127)|])dnl

define([|M_STR_BLANK|], [|M_STR_HT() |])dnl
define([|M_STR_SPACE|], [|M_STR_HT()M_STR_LF()M_STR_VT()M_STR_FF()M_STR_CR() |])dnl
define([|M_STR_CNTRL|], [|M_STR_SOH()M_STR_STX()M_STR_ETX()M_STR_EOT()M_STR_ENQ()M_STR_ACK()M_STR_BEL()M_STR_BS()M_STR_HT()M_STR_LF()M_STR_VT()M_STR_FF()M_STR_CR()M_STR_SO()M_STR_SI()M_STR_DLE()M_STR_DC1()M_STR_DC2()M_STR_DC3()M_STR_DC4()M_STR_NAK()M_STR_SYN()M_STR_ETB()M_STR_CAN()M_STR_EM()M_STR_SUB()M_STR_ESC()M_STR_FS()M_STR_GS()M_STR_RS()M_STR_US()M_STR_DEL()|])dnl
define([|M_STR_OCT|], [|01234567|])dnl
define([|M_STR_DIGIT|], [|0123456789|])dnl
define([|M_STR_XDIGIT|], [|0123456789ABCDEFabcdef|])dnl
define([|M_STR_UPPER|], [|ABCDEFGHIJKLMNOPQRSTUVWXYZ|])dnl
define([|M_STR_LOWER|], [|abcdefghijklmnopqrstuvwxyz|])dnl
define([|M_STR_PUNCT|], [|[|!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~|]|])dnl
define([|M_STR_ALPHA|], [|M_STR_UPPER()[||]M_STR_LOWER()|])dnl
define([|M_STR_ALNUM|], [|M_STR_DIGIT()M_STR_ALPHA()|])dnl
define([|M_STR_WORD|], [|_[||]M_STR_ALNUM()|])dnl
define([|M_STR_SWORD|], [|_[||]M_STR_ALPHA()|])dnl
define([|M_STR_GRAPH|], [|M_STR_PUNCT()M_STR_ALNUM()|])dnl
define([|M_STR_PRINT|], [| M_STR_GRAPH()|])dnl
define([|M_STR_ASCII|], [|M_STR_CNTRL()M_STR_PRINT()|])dnl

# sx_str_split 等で使用するフラグ
define([|M_STR_SPLIT_GLOB|], [|1|])dnl
define([|M_STR_SPLIT_INC|], [|2|])dnl
define([|M_STR_SUB_GLOB|], [|1|])dnl
define([|M_STR_SUB_CB|], [|2|])dnl
define([|M_STR_CAPITAL_KEEP|], [|1|])dnl
define([|M_STR_CAPITAL_SENT|], [|2|])dnl
define([|M_ARG_PAD_CB|], [|1|])dnl
define([|M_ARG_RESIZE_PAD_LEFT|], [|2|])dnl
define([|M_STR_ISEP_CB|], [|1|])dnl
define([|M_STR_ISEP_PRE|], [|2|])dnl
define([|M_STR_ISEP_POST|], [|4|])dnl
define([|M_ARG_ISEP_CB|], [|1|])dnl
define([|M_ARG_ISEP_PRE|], [|2|])dnl
define([|M_ARG_ISEP_POST|], [|4|])dnl
define([|M_ARG_FIND_GLOB|], [|1|])dnl
define([|M_ARG_FIND_TEXT|], [|4|])dnl
define([|M_ARG_FIND_CB|], [|2|])dnl
define([|M_ARG_RFIND_GLOB|], [|1|])dnl
define([|M_ARG_RFIND_TEXT|], [|4|])dnl
define([|M_ARG_RFIND_CB|], [|2|])dnl
define([|M_ARG_COUNT_GLOB|], [|1|])dnl
define([|M_ARG_COUNT_CB|], [|2|])dnl
define([|M_STR_FIND_GLOB|], [|1|])dnl
define([|M_STR_FIND_OVERLAP|], [|2|])dnl
define([|M_STR_FIND_TEXT|], [|4|])dnl
define([|M_STR_RFIND_GLOB|], [|1|])dnl
define([|M_STR_RFIND_OVERLAP|], [|2|])dnl
define([|M_STR_RFIND_TEXT|], [|4|])dnl
define([|M_STR_COUNT_GLOB|], [|1|])dnl
define([|M_STR_COUNT_OVERLAP|], [|2|])dnl
define([|M_STR_CHUNK_SKIP_SHORT|], [|1|])dnl
define([|M_STR_CHUNK_SKIP_LONG|], [|2|])dnl
define([|M_STR_RCHUNK_SKIP_SHORT|], [|1|])dnl
define([|M_STR_RCHUNK_SKIP_LONG|], [|2|])dnl

# 数値定数 (8bit / 16bit / 32bit / 64bit / 128bit 整数限界)
define([|M_NUM_I8_MAX|], [|127|])dnl
define([|M_NUM_I8_MIN|], [|-128|])dnl
define([|M_NUM_I8_WLEN|], [|1|])dnl
define([|M_NUM_I8_QM|], [|?|])dnl
define([|M_NUM_I8_ZR|], [|0|])dnl
define([|M_NUM_U8_MAX|], [|255|])dnl
define([|M_NUM_U8_WLEN|], [|2|])dnl
define([|M_NUM_U8_QM|], [|??|])dnl
define([|M_NUM_U8_ZR|], [|00|])dnl
define([|M_NUM_I16_MAX|], [|32767|])dnl
define([|M_NUM_I16_MIN|], [|-32768|])dnl
define([|M_NUM_I16_WLEN|], [|4|])dnl
define([|M_NUM_I16_QM|], [|????|])dnl
define([|M_NUM_I16_ZR|], [|0000|])dnl
define([|M_NUM_U16_MAX|], [|65535|])dnl
define([|M_NUM_U16_WLEN|], [|4|])dnl
define([|M_NUM_U16_QM|], [|????|])dnl
define([|M_NUM_U16_ZR|], [|0000|])dnl
define([|M_NUM_I32_MAX|], [|2147483647|])dnl
define([|M_NUM_I32_MIN|], [|-2147483648|])dnl
define([|M_NUM_I32_WLEN|], [|9|])dnl
define([|M_NUM_I32_QM|], [|?????????|])dnl
define([|M_NUM_I32_ZR|], [|000000000|])dnl
define([|M_NUM_U32_MAX|], [|4294967295|])dnl
define([|M_NUM_U32_WLEN|], [|9|])dnl
define([|M_NUM_U32_QM|], [|?????????|])dnl
define([|M_NUM_U32_ZR|], [|000000000|])dnl
define([|M_NUM_I64_MAX|], [|9223372036854775807|])dnl
define([|M_NUM_I64_MIN|], [|-9223372036854775808|])dnl
define([|M_NUM_I64_WLEN|], [|18|])dnl
define([|M_NUM_I64_QM|], [|??????????????????|])dnl
define([|M_NUM_I64_ZR|], [|000000000000000000|])dnl
define([|M_NUM_U64_MAX|], [|18446744073709551615|])dnl
define([|M_NUM_U64_WLEN|], [|18|])dnl
define([|M_NUM_U64_QM|], [|??????????????????|])dnl
define([|M_NUM_U64_ZR|], [|000000000000000000|])dnl
define([|M_NUM_I128_MAX|], [|170141183460469231731687303715884105727|])dnl
define([|M_NUM_I128_MIN|], [|-170141183460469231731687303715884105728|])dnl
define([|M_NUM_I128_WLEN|], [|37|])dnl
define([|M_NUM_I128_QM|], [|?????????????????????????????????????|])dnl
define([|M_NUM_I128_ZR|], [|0000000000000000000000000000000000000|])dnl
define([|M_NUM_U128_MAX|], [|340282366920938463463374607431768211455|])dnl
define([|M_NUM_U128_WLEN|], [|38|])dnl
define([|M_NUM_U128_QM|], [|??????????????????????????????????????|])dnl
define([|M_NUM_U128_ZR|], [|00000000000000000000000000000000000000|])dnl

# 最適乗算チャンク用動的定数の事前定義 (1〜37桁)
define([|__sx_m4_gen_qm|], [|define([|M_NUM_QM_$1|], [|$2|])dnl
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_qm(incr($1), $2?)|])|])dnl

define([|__sx_m4_gen_zr|], [|define([|M_NUM_ZR_$1|], [|$2|])dnl
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_zr(incr($1), $2[|0|])|])|])dnl

# __sx_str_qm / __sx_str_zr 用の 37 分岐 case を生成する（定数生成と同一の 37 境界）
define([|__sx_m4_gen_qm_case|], [|	$1) __sx_str_qm_out_="${SX_NUM_QM_$1}";;
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_qm_case(incr($1))|])|])dnl
define([|__sx_m4_gen_zr_case|], [|	$1) __sx_str_zr_out_="${SX_NUM_ZR_$1}";;
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_zr_case(incr($1))|])|])dnl

# 浮動小数点数限界 (IEEE 754 準拠)
define([|M_NUM_DBL_MAX|], [|1.7976931348623157e+308|])dnl
define([|M_NUM_DBL_MIN|], [|2.2250738585072014e-308|])dnl
define([|M_NUM_DBL_EPSILON|], [|2.2204460492503131e-16|])dnl
define([|M_NUM_FLT_MAX|], [|3.402823466e+38|])dnl
define([|M_NUM_FLT_MIN|], [|1.175494351e-38|])dnl
define([|M_NUM_FLT_EPSILON|], [|1.192092896e-07|])dnl

# 数学定数 (bc などの外部コマンド利用時用)
define([|M_NUM_PI|], [|3.14159265358979323846|])dnl
define([|M_NUM_TAU|], [|6.28318530717958647692|])dnl
define([|M_NUM_E|], [|2.71828182845904523536|])dnl
define([|M_NUM_SQRT2|], [|1.41421356237309504880|])dnl
define([|M_NUM_SQRT3|], [|1.73205080756887729352|])dnl
define([|M_NUM_SQRT5|], [|2.23606797749978969640|])dnl
define([|M_NUM_PHI|], [|1.61803398874989484820|])dnl
define([|M_NUM_LN2|], [|0.69314718055994530941|])dnl
define([|M_NUM_LN10|], [|2.30258509299404568401|])dnl

define([|M_NUM_BASE8_PREFIX|], [|0|])dnl
define([|M_NUM_BASE8_CHARS|], [|01234567|])dnl
define([|M_NUM_BASE10_PREFIX|], [||])dnl
define([|M_NUM_BASE10_CHARS|], [|0123456789|])dnl
define([|M_NUM_BASE16_PREFIX|], [|0[Xx]|])dnl
define([|M_NUM_BASE16_CHARS|], [|0123456789ABCDEFabcdef|])dnl

# 設定項目名の唯一の一覧。検証・全リセットの引数列もビルド時に生成する。
define([|M_CFG_META_NAMES|], [|SIG_ARR SKIP_CHK NUM_RANGE SEP ARR_UPDATE ARR_HOLE ARR_REF|])dnl

# 配列を識別するためのシグネチャ。外部コマンドに依存せず、十分に長く複雑な値をデフォルトとする。
define([|M_CFG_META_DEF_SIG_ARR|], [|array-sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c|])dnl
define([|M_CFG_META_DEF_SKIP_CHK|], [|0|])dnl
define([|M_CFG_META_DEF_NUM_RANGE|], [|32|])dnl
define([|M_CFG_META_DEF_SEP|], [|:::|])dnl
define([|M_CFG_META_DEF_ARR_UPDATE|], [|1|])dnl
define([|M_CFG_META_DEF_ARR_HOLE|], [||])dnl
define([|M_CFG_META_DEF_ARR_REF|], [||])dnl

# 受理する glob パターンを | で区切る。各選択肢に設定名を付けて case を生成する。
define([|M_CFG_META_PATTERN_SIG_ARR|], [|?*|])dnl
define([|M_CFG_META_PATTERN_SKIP_CHK|], [|[01]|])dnl
define([|M_CFG_META_PATTERN_NUM_RANGE|], [|32|64|128|])dnl
define([|M_CFG_META_PATTERN_SEP|], [|?*|])dnl
define([|M_CFG_META_PATTERN_ARR_UPDATE|], [|[01]|])dnl
define([|M_CFG_META_PATTERN_ARR_HOLE|], [|*|])dnl
define([|M_CFG_META_PATTERN_ARR_REF|], [|*|])dnl

define([|__sx_m4_gen_cfg_pattern|], [|M_CONST([|CFG_META_PATTERN_$1|])
|])dnl
define([|__sx_m4_gen_cfg_case|], [|$1=patsubst(defn([|M_CFG_META_PATTERN_$1|]), [|||], [| | $1=|])) ;;
|])dnl

define([|M_CFG_META_DESC_SIG_ARR|], [|配列を識別する署名。|])dnl
define([|M_CFG_META_DESC_SKIP_CHK|], [|1 で公開 API の引数検査を省略する。|])dnl
define([|M_CFG_META_DESC_NUM_RANGE|], [|実行シェルの算術域以下で指定する整数のビット幅（32・64・128）。|])dnl
define([|M_CFG_META_DESC_SEP|], [|設定引数とデータを区切る文字列。|])dnl
define([|M_CFG_META_DESC_ARR_UPDATE|], [|0 で sx_arr_push・sx_arr_pop によるリビジョン更新を抑制する。|])dnl
define([|M_CFG_META_DESC_ARR_HOLE|], [|sx_arr_quote・sx_arr_rquote で未設定の配列要素を表す値。|])dnl
define([|M_CFG_META_DESC_ARR_REF|], [|配列への値指定で変数参照を示す接頭辞。空文字で参照指定を無効にする。|])dnl

M_RENAME_QI([|dnl
define([|__sx_m4_gen_uri_enc_case|], [|dnl
ifelse(eval(($1 >= 48 && $1 <= 57) || ($1 >= 65 && $1 <= 90) || ($1 >= 97 && $1 <= 122) || $1 == 45 || $1 == 46 || $1 == 95 || $1 == 126), 0, [|dnl
format([|					$'\x%02X') M_STR_APPEND([|Q_out|], [|'%%%02X'|]);;
|], $1, $1)|])dnl
ifelse($1, 255, [||], [|__sx_m4_gen_uri_enc_case(incr($1))|])|])dnl
|], [|uri_enc|])dnl

__sx_m4_gen_qm(1, ?)
__sx_m4_gen_zr(1, 0)
divert(0)dnl
