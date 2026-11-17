#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nat1_base8'
  sxtest_load ./build/modules/sx_num_is_nat1_base8.sh

  Context '有効な入力'
    It '有効な8進数（接頭辞"0"必須、1 以上）で成功を返すこと'
      When call sx_num_is_nat1_base8 "01" "07" "0123"
      The status should be success
    End

    It '引数なしで成功を返すこと'
      When call sx_num_is_nat1_base8
      The status should be success
    End
  End

  Context '無効な入力'
    It '"0" または "00" の場合に失敗を返すこと'
      When call sx_num_is_nat1_base8 "0" "00"
      The status should be failure
    End

    It '接頭辞なしの場合に失敗を返すこと'
      When call sx_num_is_nat1_base8 "7" "1"
      The status should be failure
    End

    It '8進数として無効な数字(8, 9)を含む場合に失敗を返すこと'
      When call sx_num_is_nat1_base8 "08" "019"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_nat1_base8 ""
      The status should be failure
    End
  End
End
