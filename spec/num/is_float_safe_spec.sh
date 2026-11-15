#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_float_safe'
  sxtest_load ./build/modules/sx_num_is_float_safe.sh
  Include ./spec/support/run.sh

  It '整数・小数・指数表記を受け付けること'
    When call sx_num_is_float_safe 1 -2.5 3e+4
    The status should be success
  End

  It '指数が4桁なら受け付けること'
    When call sx_num_is_float_safe 1e9999
    The status should be success
  End

  It '指数が5桁（MAXと等しい）なら受け付けること'
    When call sx_num_is_float_safe 1e10000
    The status should be success
  End

  It '形式が不正な指数を拒否すること'
    When call sx_num_is_float_safe 1e+
    The status should equal 1
  End

  It 'いずれも安全であれば成功すること'
    When call sx_num_is_float_safe 1.5 2e-10000
    The status should be success
  End

  It 'SX_CFG_FLOAT_EXP_MAX=10 なら指数の絶対値が10以下を受理すること'
    sxtest_run r_ok r_ok2 -- 'sx_cfg_set FLOAT_EXP_MAX=10; sx_num_is_float_safe 1e9; r_ok=$?; sx_num_is_float_safe 1e10; r_ok2=$?'
    The variable r_ok should equal 0
    The variable r_ok2 should equal 0
  End

  It '符号付き指数の絶対値で判定すること'
    sxtest_run r_ok r_ok2 -- 'sx_cfg_set FLOAT_EXP_MAX=10; sx_num_is_float_safe 1e-9; r_ok=$?; sx_num_is_float_safe 1e-10; r_ok2=$?'
    The variable r_ok should equal 0
    The variable r_ok2 should equal 0
  End

  It 'sx_cfg_set で実行時に閾値を変更できること'
    sxtest_run r1 r2 r3 r4 -- 'sx_cfg_set FLOAT_EXP_MAX=10; sx_num_is_float_safe 1e9; r1=$?; sx_cfg_set FLOAT_EXP_MAX=100; sx_num_is_float_safe 1e99; r2=$?; sx_cfg_set FLOAT_EXP_MAX=100; sx_num_is_float_safe 1e100; r3=$?; sx_cfg_set FLOAT_EXP_MAX=10000; sx_num_is_float_safe 1e9999; r4=$?'
    The variable r1 should equal 0
    The variable r2 should equal 0
    The variable r3 should equal 0
    The variable r4 should equal 0
  End
End
