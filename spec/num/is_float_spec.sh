#!/bin/sh

Describe 'sx_num_is_float'
  Include ./sx.sh

  It '指数なしの10進実数表記を受け入れること'
    When call sx_num_is_float "0" "123" "-0.5" "1.00000000000"
    The status should be success
  End

  It '指数表記を受け入れること'
    When call sx_num_is_float "1e3" "1.2e-3" "-1.00000000000E+4" "0e0"
    The status should be success
  End

  It '省略形や不正な指数表記を拒否すること'
    When call sx_num_is_float "1." ".1" "1e" "e3" "1e+" "1e3.2" "01e3"
    The status should be failure
  End

  It '指数の桁数制限（4桁まで）を遵守すること'
    When call sx_num_is_float "1e9999" "1.23E+9999" "1e-9999"
    The status should be success
  End

  It '5桁以上の指数を拒否すること'
    When call sx_num_is_float "1e10000" "1.23E+10000" "1e-10000"
    The status should be failure
  End
End
