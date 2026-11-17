#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_ufixed'
  sxtest_load ./build/modules/sx_num_is_ufixed.sh

  It '符号なし10進の整数表記を受け入れること'
    When call sx_num_is_ufixed "1" "123" "10"
    The status should be success
  End

  It '符号なし10進の小数表記を受け入れること'
    When call sx_num_is_ufixed "1.5" "1.0" "123.456" "0"
    The status should be success
  End

  It '先頭ゼロや省略形を拒否すること'
    When call sx_num_is_ufixed "00" "01" "1." ".1"
    The status should be failure
  End

  It '符号や指数表記や空を拒否すること'
    When call sx_num_is_ufixed "+1" "-1" "1e3" ""
    The status should be failure
  End
End
