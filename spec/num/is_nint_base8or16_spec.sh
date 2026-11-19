#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nint_base8or16'
  sxtest_load ./build/modules/sx_num_is_nint_base8or16.sh

  Context '有効な入力'
    It '負の16進数（接頭辞"0x"/"0X"、"-" 符号必須）で成功を返すこと'
      When call sx_num_is_nint_base8or16 "-0x1"
      The status should be success
    End
    It '引数なしで成功を返すこと'
      When call sx_num_is_nint_base8or16
      The status should be success
    End
  End

  Context '無効な入力'
    It '8進数、正の16進数、ゼロ、接頭辞なしで失敗を返すこと'
      When call sx_num_is_nint_base8or16 "01" "07" "0123" "0x1" "0xABC" "0x0" "0" "1" "123"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_nint_base8or16 ""
      The status should be failure
    End
  End
End
