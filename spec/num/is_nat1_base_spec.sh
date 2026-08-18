#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nat1_base'
  Include ./sx.sh

  Describe '10進数 (base 10)'
    It '1以上の有効な10進数で成功すること'
      When call sx_num_is_nat1_base 10 "1" "123"
      The status should be success
    End

    It '"0" の場合に失敗すること'
      When call sx_num_is_nat1_base 10 "0"
      The status should be failure
    End

    It '先行する0がある場合に失敗すること'
      When call sx_num_is_nat1_base 10 "01"
      The status should be failure
    End
  End

  Describe '8進数 (base 8)'
    It '1以上の有効な8進数（接頭辞"0"必須）で成功すること'
      When call sx_num_is_nat1_base 8 "01" "07" "0123"
      The status should be success
    End

    It '"0" または "00" の場合に失敗すること'
      When call sx_num_is_nat1_base 8 "0" "00"
      The status should be failure
    End
  End

  Describe '16進数 (base 16)'
    It '1以上の有効な16進数（接頭辞"0x"/"0X"必須）で成功すること'
      When call sx_num_is_nat1_base 16 "0x1" "0xABC"
      The status should be success
    End

    It '"0x0" の場合に失敗すること'
      When call sx_num_is_nat1_base 16 "0x0" "0X0"
      The status should be failure
    End
  End


  Context 'SKIP_CHK フラグ'
    Before 'SX_CFG_SKIP_CHK=1'
    It '引数の検証自体は行われること'
      When call sx_num_is_nat1_base 10 "abc"
      The status should be failure
    End
  End
End
