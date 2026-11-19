dnl 設定メタ情報マクロ (M_CFG_META_*)
define([|M_CFG_META_NAMES|], [|SIG_ARR SKIP_CHK NUM_RANGE SEP ARR_HOLE NUM_FLOAT_EXP_MAX|])dnl

define([|M_CFG_META_DEF_SIG_ARR|], [|array-sx-sig-27c9d9d5-763d-4c3e-862d-a2f270928a38-5f8a2b1c|])dnl
define([|M_CFG_META_DEF_SKIP_CHK|], [|0|])dnl
define([|M_CFG_META_DEF_NUM_RANGE|], [|32|])dnl
define([|M_CFG_META_DEF_SEP|], [|:::|])dnl
define([|M_CFG_META_DEF_ARR_HOLE|], [||])dnl
define([|M_CFG_META_DEF_NUM_FLOAT_EXP_MAX|], [|65536|])dnl

define([|M_CFG_META_ACCEPT_SIG_ARR|], [|?*|])dnl
define([|M_CFG_META_ACCEPT_SKIP_CHK|], [|[01]|])dnl
define([|M_CFG_META_ACCEPT_NUM_RANGE|], [|32|64|128|])dnl
define([|M_CFG_META_ACCEPT_SEP|], [|?*|])dnl
define([|M_CFG_META_ACCEPT_ARR_HOLE|], [|*|])dnl
define([|M_CFG_META_ACCEPT_NUM_FLOAT_EXP_MAX|], [|*|])dnl

define([|M_CFG_META_REJECT_NUM_FLOAT_EXP_MAX|], [|''|*[!0-9]*|[!1-9]?*|])dnl

define([|__sx_m4_gen_cfg_case_accept|], [|ifdef([|M_CFG_META_ACCEPT_$1|], [|$1=patsubst(defn([|M_CFG_META_ACCEPT_$1|]), [|||], [||$1=|])|])dnl
|])dnl

define([|__sx_m4_gen_cfg_case_reject|], [|ifdef([|M_CFG_META_REJECT_$1|], [|$1=patsubst(defn([|M_CFG_META_REJECT_$1|]), [|||], [| | $1=|])|])dnl
|])dnl

define([|M_CFG_META_DESC_SIG_ARR|], [|配列を識別する署名。|])dnl
define([|M_CFG_META_DESC_SKIP_CHK|], [|1 で公開 API の引数検査を省略する。|])dnl
define([|M_CFG_META_DESC_NUM_RANGE|], [|実行シェルの算術域以下で指定する整数のビット幅（32・64・128）。|])dnl
define([|M_CFG_META_DESC_SEP|], [|設定引数とデータを区切る文字列。|])dnl
define([|M_CFG_META_DESC_ARR_HOLE|], [|sx_arr_quote・sx_arr_rquote で未設定の配列要素を表す値。|])dnl
define([|M_CFG_META_DESC_NUM_FLOAT_EXP_MAX|], [|sx_num_is_float_safe で受理する指数の絶対値の上限（以下の値を受理）。|])dnl
