dnl 数値定数マクロ (M_NUM_*)
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

define([|__sx_m4_gen_qm|], [|define([|M_NUM_QM_$1|], [|$2|])dnl
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_qm(incr($1), $2?)|])|])dnl

define([|__sx_m4_gen_zr|], [|define([|M_NUM_ZR_$1|], [|$2|])dnl
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_zr(incr($1), $2[|0|])|])|])dnl

define([|__sx_m4_gen_qm_case|], [|	$1) __sx_str_qm_out_="indir([|M_NUM_QM_$1|])";;
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_qm_case(incr($1))|])|])dnl
define([|__sx_m4_gen_zr_case|], [|	$1) __sx_str_zr_out_="indir([|M_NUM_ZR_$1|])";;
ifelse([|$1|], [|37|], [||], [|__sx_m4_gen_zr_case(incr($1))|])|])dnl

__sx_m4_gen_qm(1, ?)
__sx_m4_gen_zr(1, 0)

define([|M_NUM_DBL_MAX|], [|1.7976931348623157e+308|])dnl
define([|M_NUM_DBL_MIN|], [|2.2250738585072014e-308|])dnl
define([|M_NUM_DBL_EPSILON|], [|2.2204460492503131e-16|])dnl
define([|M_NUM_FLT_MAX|], [|3.402823466e+38|])dnl
define([|M_NUM_FLT_MIN|], [|1.175494351e-38|])dnl
define([|M_NUM_FLT_EPSILON|], [|1.192092896e-07|])dnl

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

define([|M_NUM_REJECT_NAT0|], [|''|[!0-9]*|[!1-9][!0-7]|[!0]*[!0-9]*|[!1-9][!1-7Xx]*?|*[!0]*[!0-9ABCDEFabcdef]*|[!1-9][!Xx]*[!0-7]*|?[!0-9][!1-9ABCDEFabcdef]*?*|])dnl
define([|M_NUM_REJECT_NAT0_BASE8|], [|''|?|[!0]*|*[!0-7]*|?[!1-7]*?*|])dnl
define([|M_NUM_REJECT_NAT0_BASE10|], [|''|*[!0-9]*|[!1-9]?*|])dnl
define([|M_NUM_REJECT_NAT0_BASE16|], [|''|?|*[!0-9ABCDEFabcdef]|?[!Xx]*|*[!0]*[!0-9ABCDEFabcdef]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*?*|])dnl

define([|M_NUM_REJECT_NAT1|], [|''|[!1-9]|?[!0-9]|[!0-9]*|[!1-9][!1-7Xx]*|?[!0-9][!1-9ABCDEFabcdef]*|[!0]*[!0-9]*|*[!0]*[!0-9ABCDEFabcdef]*|[!1-9][!Xx]*[!0-7]*|])dnl
define([|M_NUM_REJECT_NAT1_BASE8|], [|''|?|[!0]*|*[!0-7]*|?[!1-7]*|])dnl
define([|M_NUM_REJECT_NAT1_BASE10|], [|''|[!1-9]*|*[!0-9]*|])dnl
define([|M_NUM_REJECT_NAT1_BASE16|], [|''|?|*[!0-9ABCDEFabcdef]|?[!Xx]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*|*[!0]*[!0-9ABCDEFabcdef]*|])dnl

define([|M_NUM_REJECT_INT|], [|''|*[!0-9ABCDEFabcdef]|[!+0-9-]*|[!+1-9-][!0-7]|[!0][!0-9]*|[!+1-9-][!1-7Xx]?*|[!0]?[!0-9Xx]*|*[!+0-]*[!0-9ABCDEFabcdef]*|*[!0-9A-FXa-fx][!1-9][!0-7Xx]*|[!+1-9-][!Xx]*[!0-7]*|[!0-9][!1-9][!1-7Xx]*?|[!0-9][!1-9][!Xx]*[!0-7]*|[!0]?[!Xx]*[!0-9]*|?*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*?*|])dnl
define([|M_NUM_REJECT_INT_BASE8|], [|''|?|[!0]?|[!0][!0]*|?*[!0-7]*|[!+-][!1-7]?*|[!0]?[!1-7]*?*|])dnl
define([|M_NUM_REJECT_INT_BASE10|], [|''|*[!0-9]|?*[!0-9]*|[!+1-9-]*?*|*[!0-9][!1-9]*?|])dnl
define([|M_NUM_REJECT_INT_BASE16|], [|''|?|??|[!+-][!Xx]*|[!0]??|[!0]?[!Xx]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!Xx]*|*?[!0]*[!0-9ABCDEFabcdef]*|])dnl

define([|M_NUM_REJECT_NZINT|], [|''|[!1-9]|[!+0-9-]*|[!1-9][!1-9]|[!+1-9-][!1-7Xx]*|[!0][!0-9]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!1-7]|[!+0-]*[!0-9]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!1-7Xx]*|?*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*|[!+1-9-][!Xx]*[!0-7]*|[!0][!0]*[!0-9]*|[!0-9][!1-9][!Xx]*[!0-7]*|*?*[!0]*[!0-9ABCDEFabcdef]*|])dnl
define([|M_NUM_REJECT_NZINT_BASE8|], [|''|?|[!0]?|[!+-][!1-7]*|[!0][!0]*|?*[!0-7]*|*[!0-7]?[!1-7]*|])dnl
define([|M_NUM_REJECT_NZINT_BASE10|], [|''|[!1-9]|[!+1-9-]*|[!1-9][!1-9]*|?*[!0-9]*|])dnl
define([|M_NUM_REJECT_NZINT_BASE16|], [|''|?|*[!0-9ABCDEFabcdef]|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]|[!+-][!Xx]*|*[!0-9A-FXa-fx][!0]*|*[!+0-]*[!0-9ABCDEFabcdef]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!Xx]*|])dnl

define([|M_NUM_REJECT_NNINT|], [|''|*[!0-9ABCDEFabcdef]|[!+0-9-]*|[!+1-9][!0-7Xx]*|[!0][!0-9]*|[!+0-]*[!0-9]*|*[!+0-9A-FXa-fx]*[!0Xx]*|*[!+0-]*[!0-9ABCDEFabcdef]*|*[!0-9A-FXa-fx][!1-9][!0-7Xx]*|[!+1-9-][!1-7Xx]*?*|[!+1-9][!Xx]*[!0-7Xx]*|[!0][!0]*[!0-9]*|[!0-9][!1-9][!Xx]*[!0-7]*|[!1-9][!1-9][!1-9A-FXa-fx]*?*|[!0-9][!1-9][!1-7][!1-9ABCDEFabcdef]*?*|])dnl
define([|M_NUM_REJECT_NNINT_BASE8|], [|''|?|[!0]?|[!0][!0]*|?*[!0-7]*|[!+0]*[!0]*|[!+-][!1-7]*?*|[!0]?[!1-7]?*|])dnl
define([|M_NUM_REJECT_NNINT_BASE10|], [|''|*[!0-9]|?*[!0-9]*|[!+1-9-]*?*|[!+1-9]*[!0]*|*[!0-9][!1-9]*?*|])dnl
define([|M_NUM_REJECT_NNINT_BASE16|], [|''|?|??|[!0]??|[!0][!0]*|?[!Xx][!Xx]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!Xx]*|*[!+0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*[!0Xx]*|*[!+-]*?*[!0-9ABCDEFabcdef]*|])dnl

define([|M_NUM_REJECT_NPINT|], [|''|*[!0-9ABCDEFabcdef]|[!+0-]*|?[!1-9][!0-7]|*[!0-9A-FXa-fx][!0-9]*|[!-]*[!0Xx]*|?[!0]*[!0-9]*|[!+-]*[!Xx]*?|?[!1-9][!1-7Xx]*?*|?[!1-9][!Xx]*[!0-7]*|*?*[!0]*[!0-9ABCDEFabcdef]*|*?*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*?*|])dnl
define([|M_NUM_REJECT_NPINT_BASE8|], [|''|?|[!0]?|?[!0]*|?*[!0-7]*|[!+-]?*?|*[!0-7-]*[!0]*|??[!1-7]*?|])dnl
define([|M_NUM_REJECT_NPINT_BASE10|], [|''|[!0]|[!+-]?*|?*[!0-9]*|*[!0-9-]*[!0]*|?[!1-9]*?*|])dnl
define([|M_NUM_REJECT_NPINT_BASE16|], [|''|?|??|[!+-][!Xx]*|[!0]??|[!-]*[!0Xx]*|*[!+0-]*[!0-9ABCDEFabcdef]*|*[!0-9A-FXa-fx]?[!Xx]*|*?*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]?*|])dnl

define([|M_NUM_REJECT_PINT|], [|''|[!1-9]|[!+0-9]*|[!1-9][!1-9]|[!+1-9][!1-7Xx]*|[!0][!0-9]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!1-7]|[!+0]*[!0-9]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!1-7Xx]*|?*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*|[!+1-9][!Xx]*[!0-7]*|[!0][!0]*[!0-9]*|[!0-9][!1-9][!Xx]*[!0-7]*|*?*[!0]*[!0-9ABCDEFabcdef]*|])dnl
define([|M_NUM_REJECT_PINT_BASE8|], [|''|?|[!0]?|[!+][!1-7]*|[!0][!0]*|?*[!0-7]*|*[!0-7]?[!1-7]*|])dnl
define([|M_NUM_REJECT_PINT_BASE10|], [|''|[!1-9]|[!+1-9]*|[!1-9][!1-9]*|?*[!0-9]*|])dnl
define([|M_NUM_REJECT_PINT_BASE16|], [|''|?|*[!0-9ABCDEFabcdef]|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]|[!+][!Xx]*|*[!0-9A-FXa-fx][!0]*|*[!+0]*[!0-9ABCDEFabcdef]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!Xx]*|])dnl

define([|M_NUM_REJECT_NINT|], [|''|*[!0-9ABCDEFabcdef]|[!-]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]|*[!0-9A-FXa-fx][!0-9]*|*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef][!1-7Xx]*|?[!0]*[!0-9]*|?[!1-9][!1-7][!1-9ABCDEFabcdef]*|?[!1-9][!Xx]*[!0-7]*|*?*[!0]*[!0-9ABCDEFabcdef]*|])dnl
define([|M_NUM_REJECT_NINT_BASE8|], [|''|*[!0-7]|[!-]*|*[!0-7]?|*[!0-7][!0]*|?*[!0-7]*|*[!0-7]?[!1-7]*|])dnl
define([|M_NUM_REJECT_NINT_BASE10|], [|''|?|[!-]*|*[!0-9][!1-9]*|?*[!0-9]*|])dnl
define([|M_NUM_REJECT_NINT_BASE16|], [|''|*[!0-9ABCDEFabcdef]|??|[!-]*|*[!0-9A-FXa-fx]?[!Xx]*|*[!0-]*[!0-9ABCDEFabcdef]*|*?*[!0-9ABCDEFabcdef][!1-9ABCDEFabcdef]*|])dnl

define([|M_NUM_REJECT_FIXED|], [|''|*[!0-9]|[!1-9+-][!.]*|*?[!0-9.]*|[!0-9][!1-9][!.]*|*[!0-9+-]*[!0-9]*|])dnl
define([|M_NUM_REJECT_UFIXED|], [|''|*[!0-9]|*[!.0-9]*|[!1-9][!.]*|*[!0-9]*[!0-9]*|])dnl

define([|M_NUM_REJECT_FLOAT|], [|''|*[!0-9]|[!1-9+-][!.Ee]*|*[!0-9][!0-9+-]*|*[!Ee][!0-9Ee.]*|*[!0-9.+-]*[!0-9+-]*|*[!0-9+-]*[!0-9Ee+-]*|*[!0-9.][!1-9+-][!Ee.]*|])dnl
define([|M_NUM_REJECT_UFLOAT|], [|''|*[!0-9]|[!1-9][!.Ee]*|*[!0-9Ee][!0-9]*|*[!Ee][!.0-9Ee]*|*[!.0-9][!+1-9-]*?|*[!0-9]*[!Ee][!0-9Ee]*|*[!.0-9]*?*[!0-9]*|])dnl
