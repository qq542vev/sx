dnl 定義と依存宣言はこのファイルで管理する。
divert(-1)dnl
changequote([|, |])dnl
changecom()dnl

dnl 分割ファイルの依存メタ情報。全体展開時には実行時コードを出力しない。
define([|M_REQUIRE|], [||])dnl
define([|M_UNIT|], [|include([|$2|])|])dnl

dnl 有限な動的定数参照の依存候補を示すメタ情報。実行時コードは出力しない。
define([|M_DYNAMIC_CONSTS|], [||])dnl

dnl 設定検査用の依存は、関数の明示依存だけから収集する。
dnl 単独展開でも同じ結果になるよう、最初の利用時に関数一覧を読み込む。
dnl 収集中は検査マクロを無効にし、生成した検査からの逆流を防ぐ。
define([|__M_CFG_ERROR|], [|errprint([|sx cfg: $1
|])m4exit(1)|])dnl
define([|__M_CFG_EACH|], [|ifelse([|$2|], [||], [||], [|ifelse(index([|$2|], [| |]), -1, [|indir([|$1|], [|$2|], [|$3|])|], [|indir([|$1|], substr([|$2|], 0, index([|$2|], [| |])), [|$3|])[||]__M_CFG_EACH([|$1|], substr([|$2|], incr(index([|$2|], [| |]))), [|$3|])|])|])|])dnl
define([|__M_CFG_UNIT|], [|define([|__M_cfg_function_$1|], [|1|])dnl
pushdef([|__M_cfg_current|], [|$1|])dnl
include([|$2|])dnl
popdef([|__M_cfg_current|])|])dnl
define([|__M_CFG_CAPTURE_REQUIRE|], [|define([|__M_cfg_deps_|]defn([|__M_cfg_current|]), [|$1|])|])dnl
define([|__M_CFG_LOAD|], [|define([|__M_cfg_loaded|], [|1|])dnl
define([|__M_cfg_query|], [|0|])dnl
pushdef([|__M_cfg_diversion|], divnum)dnl
divert(-1)dnl
pushdef([|M_CFG_CHECK|], [||])dnl
pushdef([|M_REQUIRE|], defn([|__M_CFG_CAPTURE_REQUIRE|]))dnl
pushdef([|M_UNIT|], defn([|__M_CFG_UNIT|]))dnl
include([|src/func.m4|])dnl
popdef([|M_UNIT|])dnl
popdef([|M_REQUIRE|])dnl
popdef([|M_CFG_CHECK|])dnl
divert(defn([|__M_cfg_diversion|]))dnl
popdef([|__M_cfg_diversion|])|])dnl
define([|__M_CFG_MARK|], [|ifelse([|$1|], [|SKIP_CHK|], [||], index([| |]M_CFG_META_NAMES[| |], [| $1 |]), -1, [||], [|ifelse(ifdef([|__M_cfg_mark_$1|], [|indir([|__M_cfg_mark_$1|])|]), defn([|__M_cfg_query|]), [||], [|define([|__M_cfg_mark_$1|], defn([|__M_cfg_query|]))define([|__M_cfg_path_|]defn([|__M_cfg_root|])[|_$1|], [|$2 SX_CFG_$1|])|])|])|])dnl
define([|__M_CFG_EDGE|], [|ifdef([|__M_cfg_function_$1|], [|__M_CFG_WALK([|$1|], [|$2|])|], [|ifelse(regexp([|$1|], [|^SX_CFG_|]), 0, [|__M_CFG_MARK(substr([|$1|], 7), [|$2|])|])|])|])dnl
define([|__M_CFG_WALK|], [|ifelse([|$1|], [|sx_cfg_is_valid|], [||], [|$1|], [|__sx_cfg_is_valid|], [||], [|$1|], [|sx_cfg_set|], [||], [|$1|], [|__sx_cfg_set|], [||], [|ifelse(ifdef([|__M_cfg_seen_$1|], [|indir([|__M_cfg_seen_$1|])|]), defn([|__M_cfg_query|]), [||], [|define([|__M_cfg_seen_$1|], defn([|__M_cfg_query|]))__M_CFG_EACH([|__M_CFG_EDGE|], indir([|__M_cfg_deps_$1|]), [|$2$1 |])|])|])|])dnl
define([|__M_CFG_PICK|], [|ifelse(ifdef([|__M_cfg_mark_$1|], [|indir([|__M_cfg_mark_$1|])|]), defn([|__M_cfg_query|]), [| $1|])|])dnl
define([|__M_CFG_PREPARE|], [|ifdef([|__M_cfg_loaded|], [||], [|__M_CFG_LOAD()|])dnl
ifdef([|__M_cfg_function_$1|], [||], [|__M_CFG_ERROR([|未知の関数名: $1|])|])dnl
ifdef([|__M_cfg_result_$1|], [||], [|define([|__M_cfg_query|], incr(defn([|__M_cfg_query|])))dnl
pushdef([|__M_cfg_root|], [|$1|])dnl
__M_CFG_WALK([|$1|], [||])dnl
define([|__M_cfg_result_$1|], patsubst(__M_CFG_EACH([|__M_CFG_PICK|], M_CFG_META_NAMES), [|^ |], [||]))dnl
popdef([|__M_cfg_root|])|])|])dnl
define([|__M_CFG_ARG|], [| "${SX_CFG_$1+$1=${SX_CFG_$1}}"|])dnl
define([|__M_CFG_DEP|], [| SX_CFG_$1|])dnl
define([|__M_CFG_REQUIRE_GENERATED|], [||])dnl
define([|__M_CFG_EMIT|], [|ifelse([|$2|], [||], [||], [|__M_CFG_REQUIRE_GENERATED([|__sx_cfg_is_valid|]__M_CFG_EACH([|__M_CFG_DEP|], [|$2|]))dnl
__sx_cfg_is_valid[||]__M_CFG_EACH([|__M_CFG_ARG|], [|$2|]) || return M_EX_CONFIG|])|])dnl
define([|M_CFG_CHECK|], [|ifdef([|SX_CFG_SCAN|], [||], [|ifelse(regexp([|$1|], [|^sx_[a-z0-9_]+$|]), 0, [|__M_CFG_PREPARE([|$1|])[||]__M_CFG_EMIT([|$1|], indir([|__M_cfg_result_$1|]))|], [|__M_CFG_ERROR([|公開関数名が不正です: $1|])|])|])|])dnl
define([|__M_CFG_DEPS|], [|ifelse([|$1|], [||], [||], [|__sx_cfg_is_valid[||]__M_CFG_EACH([|__M_CFG_DEP|], [|$1|])|])|])dnl
define([|M_CFG_DEPS|], [|__M_CFG_PREPARE([|$1|])[||]__M_CFG_DEPS(indir([|__M_cfg_result_$1|]))|])dnl
define([|__M_CFG_REPORT_ITEM|], [|$2	$1	patsubst(indir([|__M_cfg_path_$2_$1|]), [| +|], [| -> |])
|])dnl
define([|M_CFG_REPORT|], [|__M_CFG_PREPARE([|$1|])[||]__M_CFG_EACH([|__M_CFG_REPORT_ITEM|], indir([|__M_cfg_result_$1|]), [|$1|])|])dnl

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
# 末尾に番兵を付け、値末尾の [ が m4 の引用終端 |] と重ならないようにする。
define([|M_SH_QUOTE|], [|__M_SH_QUOTE_PADDED([|$1X|])|])dnl
define([|__M_SH_QUOTE_PADDED|], [|__M_SH_QUOTE_END(__M_SH_QUOTE_JOIN(__M_SH_QUOTE_APOS([|$1|])))|])dnl
define([|__M_SH_QUOTE_END|], [|patsubst([|[|'$1'|]|], [|X'\(..\)$|], [|'\1|])|])dnl
define([|__M_SH_QUOTE_APOS|], [|patsubst([|[|$1|]|], [|'|], [|'\\''|])|])dnl
define([|__M_SH_QUOTE_JOIN|], [|ifelse(regexp([|$1|], [|\\'''\\'|]), -1, [|[|$1|]|], [|__M_SH_QUOTE_JOIN(patsubst([|[|$1|]|], [|\\'''\\'|], [|\\'\\'|]))|])|])dnl

# 生の文字列をドル単一引用符の内側用に変換する。引用符自体は付けない。
# バックスラッシュを先に二重化し、次に単一引用符をエスケープする。$ はそのまま保持する。
# 各段階で m4 の引用を保持し、値に含まれるマクロ名・カンマ・括弧の再解釈を防ぐ。
define([|M_SH_ESCAPE|], [|__M_SH_ESCAPE_APOS(patsubst([|[|$1|]|], [|\\|], [|\\\\|]))|])dnl
define([|__M_SH_ESCAPE_APOS|], [|patsubst([|[|$1|]|], [|'|], [|\\'|])|])dnl

# 接頭辞なしの定数名から M_* の値を展開し、readonly SX_* の宣言を生成する。
# 非空で Portable Filename Character Set の文字だけを含む値は引用を省略する。
# それ以外は通常の単一引用符で囲む。判定中と出力時も m4 の引用を保持する。
define([|M_CONST|], [|readonly SX_$1=__M_CONST_VALUE(indir([|M_$1|]))|])dnl
# 判定・出力の両方で値末尾を保護する。番兵は m4 の引用を保持したまま除去する。
define([|__M_CONST_BARE|], [|patsubst([|[|$1|]|], [|X\(..\)$|], [|\1|])|])dnl
define([|__M_CONST_VALUE|], [|ifelse(regexp([|$1!|], [|^[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-]+!$|]), 0, [|__M_CONST_BARE([|$1X|])|], [|__M_SH_QUOTE_PADDED([|$1X|])|])|])dnl

# M_* に保持したエスケープ列を POSIX.1-2024 のドル単一引用符で宣言する。
# 入力は引用済みの値ではなく、\xHH 等のエスケープ列（単一引用符は \'）とする。
# 通常の定数宣言とは異なり、バックスラッシュは実行時に解釈される。
define([|M_CONST_ESC|], [|readonly SX_$1=__M_CONST_ESC_VALUE(indir([|M_$1|]))|])dnl
define([|__M_CONST_ESC_VALUE|], [|$'[|$1|]'|])dnl

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

# 定数マクロのインクルード（依存関係順：str → num → uri → cfg → glob）
# uri.m4 は M_STR_DIGIT, M_STR_XDIGIT を参照するため str.m4 より後に配置する。
include([|m4/const/ex.m4|])dnl
include([|m4/const/str.m4|])dnl
include([|m4/const/sh.m4|])dnl
include([|m4/const/num.m4|])dnl

dnl URI エンコードの生成マクロ。uri_enc シンボルを守る。
M_RENAME_QI([|dnl
define([|__sx_m4_gen_uri_enc_case|], [|dnl
ifelse(eval(($1 >= 48 && $1 <= 57) || ($1 >= 65 && $1 <= 90) || ($1 >= 97 && $1 <= 122) || $1 == 45 || $1 == 46 || $1 == 95 || $1 == 126), 0, [|dnl
format([|					$'\x%02X') M_STR_APPEND([|Q_out|], [|'%%%02X'|]);;
|], $1, $1)|])dnl
ifelse($1, 255, [||], [|__sx_m4_gen_uri_enc_case(incr($1))|])|])dnl
|], [|uri_enc|])dnl

include([|m4/const/uri.m4|])dnl
include([|m4/const/cfg.m4|])dnl
include([|m4/const/glob.m4|])dnl
include([|m4/const/arg.m4|])dnl

divert(0)dnl
