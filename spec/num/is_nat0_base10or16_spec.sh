#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nat0_base10or16'
  sxtest_load ./build/modules/sx_num_is_nat0_base10or16.sh

  Context '有効な入力'
    It '有効な10進数（符号なし、先行0なし）で成功を返すこと'
      When call sx_num_is_nat0_base10or16 "0" "1" "123" "9876543210"
      The status should be success
    End
    It '引数なしで成功を返すこと'
      When call sx_num_is_nat0_base10or16
      The status should be success
    End
  End

  Context '無効な入力'
    It '先行する0がある場合に失敗すること（"0"単体を除く）'
      When call sx_num_is_nat0_base10or16 "01" "00"
      The status should be failure
    End

    It '符号がある場合に失敗すること'
      When call sx_num_is_nat0_base10or16 "+0" "-0" "+123" "-456"
      The status should be failure
    End

    It '非数字が含まれる場合に失敗すること'
      When call sx_num_is_nat0_base10or16 "12a" " 1" "1.0"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_nat0_base10or16 ""
      The status should be failure
    End
  End
End
