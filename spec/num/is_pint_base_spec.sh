#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_pint_base'
  Include ./sx.sh

  It '1以上の整数（任意で"+"符号）で成功すること'
    When call sx_num_is_pint_base 10 "1" "+123"
    The status should be success
  End

  It '0 または 負の数値で失敗すること'
    When call sx_num_is_pint_base 10 "0" "+0" "-1"
    The status should be failure
  End

  It '8進数で1以上の場合に成功すること'
    When call sx_num_is_pint_base 8 "01" "+07"
    The status should be success
  End

  It '16進数で1以上の場合に成功すること'
    When call sx_num_is_pint_base 16 "0x1" "+0xABC"
    The status should be success
  End


  Context 'SKIP_CHK フラグ'
    Before 'SX_CFG_SKIP_CHK=1'
    It '引数の検証自体は行われること'
      When call sx_num_is_pint_base 10 "abc"
      The status should be failure
    End
  End
End
