#!/bin/sh
# shellcheck disable=SC2016 # 変数参照は検査対象のソースに残す。
# shellcheck disable=SC2288 # Parameters の値はコマンドではない。

eval "$(shellspec - -c) exit 1"
Include ./spec/support/build.sh

Describe '分割単位の依存宣言'
  It '全単位の宣言が展開後の直接参照と一致すること'
    When run python3 tools/check-dependencies.py
    The status should be success
    The output should include '依存宣言を照合しました'
  End
End

Describe '書込可否検査に渡す名前と値の参照の区別'
  prepare_dependencies() {
    build_prepare_fixture
    cp tools/check-dependencies.py tools/dependency_headers.py "$SXTEST_BUILD_DIR/tools/"
    build_add_unit var SX_CFG_ARR_HOLE '' 'SX_CFG_ARR_HOLE='
    build_add_unit var SX_CFG_ARR_REF '' 'SX_CFG_ARR_REF='
    build_add_unit func __sx_var_is_rw '' '__sx_var_is_rw() { :; }'
  }
  check_dependencies() { python3 "$SXTEST_BUILD_DIR/tools/check-dependencies.py"; }
  BeforeEach prepare_dependencies
  AfterEach build_cleanup

  Context 'リテラルの変数名'
    Parameters
      'SX_CFG_ARR_HOLE SX_CFG_ARR_REF'
      '"SX_CFG_ARR_HOLE" "SX_CFG_ARR_REF"'
      "'SX_CFG_ARR_HOLE' 'SX_CFG_ARR_REF'"
    End

    It '書込可否検査の引数だけに現れる名前を依存に含めないこと'
      build_add_unit func __sx_probe __sx_var_is_rw "__sx_probe() { __sx_var_is_rw $1; }"
      When run check_dependencies
      The status should be success
      The stdout should include '依存宣言を照合しました'
      The stderr should equal ''
    End
  End

  Context '同じ変数の値を参照する場合'
    Parameters
      ': "${SX_CFG_ARR_HOLE}"'
      ': "$SX_CFG_ARR_HOLE"'
      ': "$((SX_CFG_ARR_HOLE + 1))"'
      '__sx_var_is_rw "${SX_CFG_ARR_HOLE}"'
      '__sx_var_is_rw SX_CFG_ARR_REF "${SX_CFG_ARR_HOLE}"'
      '__sx_var_is_rw "SX_CFG_ARR_REF${SX_CFG_ARR_HOLE}"'
    End

    It '名前を検査していても値の参照に必要な依存の不足を検出すること'
      build_add_unit func __sx_probe __sx_var_is_rw "__sx_probe() {
  __sx_var_is_rw SX_CFG_ARR_HOLE SX_CFG_ARR_REF; $1
}"
      When run check_dependencies
      The status should be failure
      The stdout should include "不足=['SX_CFG_ARR_HOLE'"
      The stderr should include '依存宣言の不一致'
    End
  End
End
