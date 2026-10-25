#!/bin/sh
# shellcheck disable=SC2016 # m4 と生成コードの文字列。
eval "$(shellspec - -c) exit 1"
Include ./spec/support/build.sh

Describe '分割関数の個別展開と結合'
  prepare_functions() {
    build_prepare_project
    LC_ALL=C m4 -- m4/common.m4 src/func.m4 > "$SXTEST_BUILD_DIR/functions.sh"
    build_unit_names src/func.m4 > "$SXTEST_BUILD_DIR/expected-names"
    build_function_names "$SXTEST_BUILD_DIR/functions.sh" > "$SXTEST_BUILD_DIR/actual-names"
    {
      printf '%s\n' '#!/bin/sh'
      LC_ALL=C m4 -- m4/common.m4 src/const.m4 src/var.m4 src/func.m4 | LC_ALL=C awk -f tools/compact.awk
    } > "$SXTEST_BUILD_DIR/assembled.sh"
  }
  # m4 の ifelse/ifdef が外側の CLEANUP の保存と未定義状態の復元を検査する。
  expand_function() {
    LC_ALL=C m4 -- m4/common.m4 - > "$SXTEST_BUILD_DIR/scope.sh" <<M4
define([|CLEANUP|], [|SAVED_CLEANUP|])dnl
include([|$1|])dnl
ifelse(defn([|CLEANUP|]), [|SAVED_CLEANUP|], [||], [|m4exit(1)|])dnl
undefine([|CLEANUP|])dnl
SPLIT_FUNCTION_SCOPE_SEPARATOR
include([|$1|])dnl
ifdef([|CLEANUP|], [|m4exit(1)|])dnl
M4
    awk -v before="$SXTEST_BUILD_DIR/before.sh" -v after="$SXTEST_BUILD_DIR/after.sh" '
      /^SPLIT_FUNCTION_SCOPE_SEPARATOR$/ { second=1; next }
      { print > (second ? after : before) }
    ' "$SXTEST_BUILD_DIR/scope.sh"
    cmp "$SXTEST_BUILD_DIR/before.sh" "$SXTEST_BUILD_DIR/after.sh" || return
    LC_ALL=C awk -f tools/compact.awk "$SXTEST_BUILD_DIR/before.sh" > "$SXTEST_BUILD_DIR/compact.sh"
    LC_ALL=C awk '/(^|[^A-Za-z0-9_])(Q_[A-Za-z0-9_]*|M_[A-Za-z0-9_]*|__M_[A-Za-z0-9_]*|__sx_m4_gen_[A-Za-z0-9_]*|CLEANUP)([^A-Za-z0-9_]|$)/ { print NR ":" $0 }' \
      "$SXTEST_BUILD_DIR/compact.sh" > "$SXTEST_BUILD_DIR/unexpanded"
    LC_ALL=C.UTF-8 yash -o posix -n "$SXTEST_BUILD_DIR/compact.sh" || return
    build_function_names "$1" > "$SXTEST_BUILD_DIR/source-names"
    build_function_names "$SXTEST_BUILD_DIR/before.sh"
  }
  BeforeAll prepare_functions
  AfterAll build_cleanup

  It '単位一覧と実ファイルが一致すること'
    When run python3 tools/check-units.py
    The status should be success
    The stdout should include '単位'
    The stderr should equal ''
  End

  It '関数を一覧順に一度ずつ展開すること'
    When run cmp "$SXTEST_BUILD_DIR/expected-names" "$SXTEST_BUILD_DIR/actual-names"
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  Context '各関数の単独展開'
    Parameters:dynamic
      # shellcheck disable=SC2044 # 単位のパスは一覧検査で名前の形式を検証する。
      for path in $(find src/func -type f -name '*.m4' | LC_ALL=C sort); do
        %data "$path"
      done
    End
    It "$1 がスコープ・定義名・マクロ展開・POSIX 構文を満たすこと"
      function_name=${1##*/}
      function_name=${function_name%.m4}
      When run expand_function "$1"
      The status should be success
      The stdout should equal "$function_name"
      The stderr should equal ''
      The contents of file "$SXTEST_BUILD_DIR/source-names" should equal "$function_name"
      The contents of file "$SXTEST_BUILD_DIR/unexpanded" should equal ''
    End
  End

  Context '親と共有するコールバックの名前空間'
    Parameters
      __sx_str_escape_cb str_escape cb_se
      __sx_str_sub_isep_adapt str_sub cb
    End
    It "$1 が親 $2 の名前空間を使うこと"
      When run m4 -- m4/common.m4 "src/func/str/$1.m4"
      The status should be success
      The stdout should include "__sx_${2}_${3}_"
      The stdout should not include "${1}_${3}_"
      The stderr should equal ''
    End
  End

  It '全一覧を直接結合した内容が生成済みの全体版とバイト単位で一致すること'
    When run cmp "$SXTEST_BUILD_DIR/assembled.sh" sx.sh
    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End
End
