#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nnint_base10or16'
  sxtest_load ./build/modules/sx_num_is_nnint_base10or16.sh

  Context '有効な入力'
    It '0 以上の10進数（符号付き0を含む）で成功を返すこと'
      When call sx_num_is_nnint_base10or16 "0" "+0" "-0" "1" "+123"
      The status should be success
    End
    It '引数なしで成功を返すこと'
      When call sx_num_is_nnint_base10or16
      The status should be success
    End
  End

  Context '無効な入力'
    It '負の数値（-0を除く）で失敗を返すこと'
      When call sx_num_is_nnint_base10or16 "-1" "-123"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_nnint_base10or16 ""
      The status should be failure
    End
  End
End
