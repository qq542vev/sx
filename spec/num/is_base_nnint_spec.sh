#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_base_nnint'
  Include ./sx.sh

  It '0 以上の整数（符号付き0を含む）で成功すること'
    When call sx_num_is_base_nnint 10 "0" "+0" "-0" "1" "+123"
    The status should be success
  End

  It '負の数値（-0を除く）で失敗すること'
    When call sx_num_is_base_nnint 10 "-1" "-123"
    The status should be failure
  End

  It '8進数で0以上の場合に成功すること'
    When call sx_num_is_base_nnint 8 "00" "+00" "-00" "01"
    The status should be success
  End

  It '16進数で0以上の場合に成功すること'
    When call sx_num_is_base_nnint 16 "0x0" "+0x0" "-0x0" "0x1"
    The status should be success
  End
End
