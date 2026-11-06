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

Describe '動的定数参照の依存候補'
  prepare_dynamic_constants() {
    build_prepare_fixture
    cp tools/check-dependencies.py tools/dependency_headers.py "$SXTEST_BUILD_DIR/tools/"
    build_add_unit const SX_EX_OK '' 'readonly SX_EX_OK=0'
    build_add_unit const SX_EX_USAGE '' 'readonly SX_EX_USAGE=64'
    build_add_unit const SX_EX_MSG64 '' 'readonly SX_EX_MSG64=usage'
  }
  check_dependencies() { python3 "$SXTEST_BUILD_DIR/tools/check-dependencies.py"; }
  probe_body() {
    cat <<'EOF'
__sx_probe() {
  case "${1-}" in [!0-9]*) eval "set -- \"\${SX_EX_${1}}\"";; esac
}
M_DYNAMIC_CONSTS([|SX_EX_|], [|OK USAGE|])dnl
EOF
  }
  probe_body_unknown() {
    cat <<'EOF'
__sx_probe() {
  case "${1-}" in [!0-9]*) eval "set -- \"\${SX_EX_${1}}\"";; esac
}
M_DYNAMIC_CONSTS([|SX_EX_|], [|OK UNKNOWN|])dnl
EOF
  }
  BeforeEach prepare_dynamic_constants
  AfterEach build_cleanup

  It '宣言した候補の定数だけを依存として受理すること'
    build_add_unit func __sx_probe 'SX_EX_OK SX_EX_USAGE' "$(probe_body)"
    When run check_dependencies
    The status should be success
    The stdout should include '依存宣言を照合しました'
    The stderr should equal ''
  End

  It '候補の定数が依存宣言から欠けた場合に検出すること'
    build_add_unit func __sx_probe 'SX_EX_OK' "$(probe_body)"
    When run check_dependencies
    The status should be failure
    The stdout should include "不足=['SX_EX_USAGE']"
    The stderr should include '依存宣言の不一致'
  End

  It '提供元のない定数を候補に含めた場合に検出すること'
    build_add_unit func __sx_probe 'SX_EX_OK SX_EX_USAGE SX_EX_UNKNOWN' "$(probe_body_unknown)"
    When run check_dependencies
    The status should be failure
    The stderr should include '動的定数の依存先に提供元がありません'
  End
End

Describe '書込可否検査に渡す名前と値の参照の区別'
  prepare_dependencies() {
    build_prepare_fixture
    cp tools/check-dependencies.py tools/dependency_headers.py "$SXTEST_BUILD_DIR/tools/"
    build_add_unit var SX_CFG_ARR_HOLE '' 'SX_CFG_ARR_HOLE='
    build_add_unit var SX_CFG_SEP '' 'SX_CFG_SEP='
    build_add_unit func __sx_var_is_rw '' '__sx_var_is_rw() { :; }'
  }
  check_dependencies() { python3 "$SXTEST_BUILD_DIR/tools/check-dependencies.py"; }
  BeforeEach prepare_dependencies
  AfterEach build_cleanup

  Context 'リテラルの変数名'
    Parameters
      'SX_CFG_ARR_HOLE SX_CFG_SEP'
      '"SX_CFG_ARR_HOLE" "SX_CFG_SEP"'
      "'SX_CFG_ARR_HOLE' 'SX_CFG_SEP'"
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
      '__sx_var_is_rw SX_CFG_SEP "${SX_CFG_ARR_HOLE}"'
      '__sx_var_is_rw "SX_CFG_SEP${SX_CFG_ARR_HOLE}"'
    End

    It '名前を検査していても値の参照に必要な依存の不足を検出すること'
      build_add_unit func __sx_probe __sx_var_is_rw "__sx_probe() {
  __sx_var_is_rw SX_CFG_ARR_HOLE SX_CFG_SEP; $1
}"
      When run check_dependencies
      The status should be failure
      The stdout should include "不足=['SX_CFG_ARR_HOLE'"
      The stderr should include '依存宣言の不一致'
    End
  End
End
