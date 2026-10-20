#!/bin/sh
# shellcheck shell=sh

include(`m4/common.m4')dnl
divert(-1)dnl

dnl 第1段階: 一覧から名前とファイルの対応を収集する。
define([|__sx_resolve_error|], [|errprint([|sx bundle: $1
|])m4exit(1)|])dnl
define([|M_UNIT|], [|ifdef([|__sx_path_$1|], [|__sx_resolve_error([|定義の重複: $1|])|], [|define([|__sx_path_$1|], [|$2|])|])|])dnl
include([|src/constants.m4|])dnl
include([|src/globals.m4|])dnl
include([|src/functions.m4|])dnl

dnl 第2段階: 読み込み前に訪問済みと記録して循環を止める。
define([|__sx_include_eager|], [|pushdef([|__sx_eager_active|], [|1|])dnl
include(indir([|__sx_path_$1|]))dnl
popdef([|__sx_eager_active|])|])dnl
define([|__sx_include_const|], [|pushdef([|__sx_const_active|], [|1|])dnl
__sx_include_eager([|$1|])dnl
popdef([|__sx_const_active|])|])dnl
define([|__sx_include_unit|], [|ifelse(regexp(indir([|__sx_path_$1|]), [|^src/functions/|]), 0, [|include(indir([|__sx_path_$1|]))|], regexp(indir([|__sx_path_$1|]), [|^src/constants/|]), 0, [|__sx_include_const([|$1|])|], [|__sx_include_eager([|$1|])|])|])dnl
define([|__sx_validate_edge|], [|ifdef([|__sx_const_active|], [|ifelse(regexp(indir([|__sx_path_$1|]), [|^src/constants/|]), 0, [||], [|__sx_resolve_error([|定数から実行時状態への依存: $1|])|])|], [|ifdef([|__sx_eager_active|], [|ifelse(regexp(indir([|__sx_path_$1|]), [|^src/functions/|]), 0, [|__sx_resolve_error([|初期化から関数への依存: $1|])|])|])|])|])dnl
define([|__sx_visit|], [|ifdef([|__sx_path_$1|], [|__sx_validate_edge([|$1|])dnl
ifdef([|__sx_seen_$1|], [|ifdef([|__sx_active_$1|], [|ifdef([|__sx_eager_active|], [|__sx_resolve_error([|初期化依存の循環: $1|])|])|])|], [|define([|__sx_seen_$1|], [|1|])dnl
define([|__sx_active_$1|], [|1|])dnl
__sx_include_unit([|$1|])dnl
undefine([|__sx_active_$1|])dnl
|])|], [|__sx_resolve_error([|未定義の名前: $1|])|])|])dnl
define([|__sx_words|], [|ifelse([|$1|], [||], [||], [|ifelse(index([|$1|], [| |]), -1, [|__sx_visit([|$1|])|], [|__sx_visit(substr([|$1|], 0, index([|$1|], [| |])))__sx_words(substr([|$1|], incr(index([|$1|], [| |]))))|])|])|])dnl
define([|M_REQUIRE|], [|__sx_words([|$1|])|])dnl

ifdef([|SX_SYMBOLS|], [||], [|define([|SX_SYMBOLS|], [||])|])dnl
ifelse(len(defn([|SX_SYMBOLS|])), 0, [|dnl
dnl 空指定では一覧の全単位を起点にし、依存と循環も通常どおり検証する。
define([|M_UNIT|], [|__sx_visit([|$1|])|])dnl
include([|src/constants.m4|])dnl
include([|src/globals.m4|])dnl
include([|src/functions.m4|])dnl
|], [|dnl
ifelse(regexp(defn([|SX_SYMBOLS|]), [|^[A-Za-z_][A-Za-z0-9_]*\( [A-Za-z_][A-Za-z0-9_]*\)*$|]), 0, [||], [|__sx_resolve_error([|SX_SYMBOLS の形式が不正です|])|])dnl
__sx_words(defn([|SX_SYMBOLS|]))dnl
|])dnl

dnl 第3段階: 元の一覧順に選択済み単位だけを出力する。
define([|M_REQUIRE|], [||])dnl
define([|M_UNIT|], [|ifdef([|__sx_seen_$1|], [|include([|$2|])|])|])dnl
divert(0)dnl
include([|src/constants.m4|])dnl
include([|src/globals.m4|])dnl
include([|src/functions.m4|])dnl
