#!/bin/sh

eval "$(shellspec - -c) exit 1"

Include ./spec/support/build.sh

Describe '単位一覧と実ファイルの整合性検査'
  prepare_units() {
    build_prepare_fixture
    cp tools/check-units.py "$SXTEST_BUILD_DIR/tools/"
  }
  check_units() { python3 "$SXTEST_BUILD_DIR/tools/check-units.py"; }
  BeforeEach prepare_units
  AfterEach build_cleanup

  It '空の一覧と空のソース群は一致すること'
    When run check_units
    The status should be success
    The stdout should include '0 単位'
    The stderr should equal ''
  End

  It '登録した実ファイルがあれば一致すること'
    build_add_unit const SX_STR_SAMPLE '' 'readonly SX_STR_SAMPLE=sample'
    When run check_units
    The status should be success
    The stdout should include '1 単位'
    The stderr should equal ''
  End

  It '一覧にある実ファイルの欠落を検出すること'
    printf '%s\n' 'M_UNIT([|SX_STR_SAMPLE|], [|src/const/SX_STR_SAMPLE.m4|])dnl' \
      > "$SXTEST_BUILD_DIR/src/const.m4"
    When run check_units
    The status should be failure
    The stdout should equal ''
    The stderr should include '欠落='
    The stderr should include 'SX_STR_SAMPLE.m4'
  End

  It '一覧に登録されていない実ファイルを検出すること'
    : > "$SXTEST_BUILD_DIR/src/const/SX_STR_SAMPLE.m4"
    When run check_units
    The status should be failure
    The stderr should include '未登録='
    The stderr should include 'SX_STR_SAMPLE.m4'
  End

  It '提供名の重複登録を検出すること'
    build_add_unit const SX_STR_SAMPLE '' 'readonly SX_STR_SAMPLE=sample'
    printf '%s\n' 'M_UNIT([|SX_STR_SAMPLE|], [|src/const/SX_STR_SAMPLE.m4|])dnl' \
      >> "$SXTEST_BUILD_DIR/src/const.m4"
    When run check_units
    The status should be failure
    The stderr should include '単位が重複しています: SX_STR_SAMPLE'
  End

  It '提供名とファイル名の不一致を検出すること'
    printf '%s\n' 'M_UNIT([|SX_STR_SAMPLE|], [|src/const/SX_STR_OTHER.m4|])dnl' \
      > "$SXTEST_BUILD_DIR/src/const.m4"
    When run check_units
    The status should be failure
    The stderr should include '名前とパスが一致しません'
  End

  Context '実ファイル追加時の異常'
    Parameters
      bad-name
      SX_STR_SAMPLE
    End
    It "$1 の未登録ファイルを整合性検査で検出すること"
      build_add_unit const SX_STR_SAMPLE '' 'readonly SX_STR_SAMPLE=sample'
      : > "$SXTEST_BUILD_DIR/src/func/$1.m4"
      When run check_units
      The status should be failure
      The stderr should include '未登録='
      The stderr should include "src/func/$1.m4"
    End
  End

  It '登録名自体の形式不正を検出すること'
    build_add_unit func bad-name '' ':'
    When run check_units
    The status should be failure
    The stderr should include '一覧の書式が不正です'
  End
End
