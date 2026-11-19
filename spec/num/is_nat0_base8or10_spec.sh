#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nat0_base8or10'
  sxtest_load ./build/modules/sx_num_is_nat0_base8or10.sh

  Context '有効な入力'
    It '有効な10進数（符号なし、先行0なし）で成功を返すこと'
      When call sx_num_is_nat0_base8or10 "0" "1" "123" "9876543210"
      The status should be success
    End
    It '有効な8進数（先行0あり、0-7のみ）で成功を返すこと'
      When call sx_num_is_nat0_base8or10 "01" "00"
      The status should be success
    End
    It '引数なしで成功を返すこと'
      When call sx_num_is_nat0_base8or10
      The status should be success
    End
  End

  Context '無効な入力'
    It '符号がある場合に失敗すること'
      When call sx_num_is_nat0_base8or10 "+0" "-0" "+123" "-456"
      The status should be failure
    End

    It '非数字が含まれる場合に失敗すること'
      When call sx_num_is_nat0_base8or10 "12a" " 1" "1.0"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_nat0_base8or10 ""
      The status should be failure
    End
  End
End
