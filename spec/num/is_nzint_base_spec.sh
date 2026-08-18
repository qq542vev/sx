#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nzint_base'
  Include ./sx.sh

  It '10進数の0以外の整数で成功すること'
    When call sx_num_is_nzint_base 10 "1" "+123" "-1" "-123"
    The status should be success
  End

  It '10進数のゼロで失敗すること'
    When call sx_num_is_nzint_base 10 "0" "+0" "-0"
    The status should be failure
  End

  It '8進数の0以外の整数で成功すること'
    When call sx_num_is_nzint_base 8 "01" "+0123" "-01" "-0123"
    The status should be success
  End

  It '8進数のゼロで失敗すること'
    When call sx_num_is_nzint_base 8 "00" "+00" "-00"
    The status should be failure
  End

  It '16進数の0以外の整数で成功すること'
    When call sx_num_is_nzint_base 16 "0x1" "+0xABC" "-0x1" "-0xABC"
    The status should be success
  End

  It '16進数のゼロで失敗すること'
    When call sx_num_is_nzint_base 16 "0x0" "+0x0" "-0x0"
    The status should be failure
  End

  It '非整数で失敗すること'
    When call sx_num_is_nzint_base 10 "1.5" "abc"
    The status should be failure
  End

  It '不正な基数で失敗すること'
    When call sx_num_is_nzint_base 7 "1" "2"
    The status should be failure
  End


  Context 'SKIP_CHK フラグ'
    Before 'SX_CFG_SKIP_CHK=1'
    It '引数の検証自体は行われること'
      When call sx_num_is_nzint_base 10 "abc"
      The status should be failure
    End
  End
End
