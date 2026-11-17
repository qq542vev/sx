#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_ufloat'
  sxtest_load ./build/modules/sx_num_is_ufloat.sh

  It '指数なしの符号なし10進実数表記を受け入れること'
    When call sx_num_is_ufloat "1" "123" "10" "1.5" "1.0" "0"
    The status should be success
  End

  It '指数表記を受け入れること'
    When call sx_num_is_ufloat "1e3" "1.2e-3" "1E+5" "0e0"
    The status should be success
  End

  It '先頭ゼロや省略形や不正な指数表記を拒否すること'
    When call sx_num_is_ufloat "00" "01" "1." ".1" "1e" "e3" "1e+" "1e3.2"
    The status should be failure
  End

  It '符号や空を拒否すること'
    When call sx_num_is_ufloat "+1" "-1" "+1e3" "-1e3" ""
    The status should be failure
  End
End
