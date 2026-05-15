#!/bin/sh

Describe 'sx_num_is_fixed'
  Include ./sx.sh

  It '10進の整数表記を受け入れること'
    When call sx_num_is_fixed "0" "123" "+456" "-789"
    The status should be success
  End

  It '10進の小数表記を受け入れること'
    When call sx_num_is_fixed "0.5" "-12.34000" "1.00000000000"
    The status should be success
  End

  It '省略形を拒否すること'
    When call sx_num_is_fixed "1." ".1"
    The status should be failure
  End

  It '10進以外や不正な表記を拒否すること'
    When call sx_num_is_fixed "01" "0x1" "1e3" "1.2.3" ""
    The status should be failure
  End
End
