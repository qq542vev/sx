#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nat0_base8or16'
  sxtest_load ./build/modules/sx_num_is_nat0_base8or16.sh

  Context '有効な入力'
    It '有効な8進数（接頭辞"0"、0 以上）で成功を返すこと'
      When call sx_num_is_nat0_base8or16 "01" "07" "0123"
      The status should be success
    End
    It '有効な16進数（接頭辞"0x"/"0X"、0 以上）で成功を返すこと'
      When call sx_num_is_nat0_base8or16 "0x1" "0xABC" "0x0"
      The status should be success
    End
    It '引数なしで成功を返すこと'
      When call sx_num_is_nat0_base8or16
      The status should be success
    End
  End

  Context '無効な入力'
    It '接頭辞なしの場合に失敗を返すこと'
      When call sx_num_is_nat0_base8or16 "0" "1" "123"
      The status should be failure
    End

    It '符号がある場合に失敗すること'
      When call sx_num_is_nat0_base8or16 "+0x1" "-0x1"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_nat0_base8or16 ""
      The status should be failure
    End
  End
End
