#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_float_safe'
  Include ./sx.sh

  It '整数・小数・指数表記を受け付けること'
    When call sx_num_is_float_safe 1 -2.5 3e+4
    The status should be success
  End

  It '指数が4桁なら受け付けること'
    When call sx_num_is_float_safe 1e9999
    The status should be success
  End

  It '指数が5桁なら拒否すること'
    When call sx_num_is_float_safe 1e10000
    The status should equal 1
  End

  It '形式が不正な指数を拒否すること'
    When call sx_num_is_float_safe 1e+
    The status should equal 1
  End

  It 'いずれかが安全でなければ失敗すること'
    When call sx_num_is_float_safe 1.5 2e-10000
    The status should equal 1
  End
End
