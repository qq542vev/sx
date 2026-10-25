#!/bin/sh

eval "$(shellspec - -c) exit 1"

Include ./spec/support/build.sh

Describe 'm4 による単位の依存解決'
  BeforeEach build_prepare_fixture
  AfterEach build_cleanup

  It '関数間の循環依存を許容し、各関数を一度だけ生成すること'
    build_add_unit func sx_cycle_a sx_cycle_b 'sx_cycle_a() { sx_cycle_b; }'
    build_add_unit func sx_cycle_b sx_cycle_a 'sx_cycle_b() { sx_cycle_a; }'
    build_resolve sx_cycle_a > "$SXTEST_BUILD_DIR/cycle.sh"
    When run build_function_names "$SXTEST_BUILD_DIR/cycle.sh"
    The status should be success
    The stdout should equal 'sx_cycle_a
sx_cycle_b'
    The stderr should equal ''
  End

  It '初期化処理の循環依存を拒否すること'
    build_add_unit var SX_SYS_A SX_SYS_B 'SX_SYS_A=1'
    build_add_unit var SX_SYS_B SX_SYS_A 'SX_SYS_B=1'
    When run build_resolve SX_SYS_A
    The status should be failure
    The stdout should not include 'SX_SYS_A='
    The stderr should include '初期化依存の循環'
  End

  It '一覧に同じ名前が重複していたら拒否すること'
    build_add_unit var SX_SYS_A '' 'SX_SYS_A=1'
    build_add_unit var SX_SYS_A '' 'SX_SYS_A=1'
    When run build_resolve SX_SYS_A
    The status should be failure
    The stdout should not include 'SX_SYS_A='
    The stderr should include '定義の重複'
  End

  It '初期化処理から関数への依存を拒否すること'
    build_add_unit func sx_dummy '' 'sx_dummy() { :; }'
    build_add_unit var SX_SYS_A sx_dummy 'SX_SYS_A=1'
    When run build_resolve SX_SYS_A
    The status should be failure
    The stdout should not include 'SX_SYS_A='
    The stderr should include '初期化から関数への依存'
  End

  It '定数から実行時状態への依存を拒否すること'
    build_add_unit var SX_SYS_A '' 'SX_SYS_A=1'
    build_add_unit const SX_STR_DUMMY SX_SYS_A 'readonly SX_STR_DUMMY=x'
    When run build_resolve SX_STR_DUMMY
    The status should be failure
    The stdout should not include 'readonly SX_STR_DUMMY='
    The stderr should include '定数から実行時状態への依存'
  End
End
