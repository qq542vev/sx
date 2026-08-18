#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_int_base'
  Include ./sx.sh

  Context '10進数 (base 10)'
    It '符号付きの整数で成功すること'
      When call sx_num_is_int_base 10 "0" "123" "+456" "-789" "+0" "-0"
      The status should be success
    End

    It '不正な形式で失敗すること'
      When call sx_num_is_int_base 10 "01" "+01" "--1" "++1" "12a"
      The status should be failure
    End
  End

  Context '8進数 (base 8)'
    It '符号付きの8進数で成功すること'
      When call sx_num_is_int_base 8 "01" "+07" "-0123" "00" "+00" "-00"
      The status should be success
    End

    It '不正な形式で失敗すること'
      When call sx_num_is_int_base 8 "007" "7" "+7"
      The status should be failure
    End
  End

  Context '16進数 (base 16)'
    It '符号付きの16進数で成功すること'
      When call sx_num_is_int_base 16 "0x1" "+0xABC" "-0Xdef" "0x0" "+0x0" "-0x0"
      The status should be success
    End

    It '不正な形式で失敗すること'
      When call sx_num_is_int_base 16 "F" "+F" "0xG"
      The status should be failure
    End
  End


  Context 'SKIP_CHK フラグ'
    Before 'SX_CFG_SKIP_CHK=1'
    It '引数の検証自体は行われること'
      When call sx_num_is_int_base 10 "abc"
      The status should be failure
    End
  End
End
