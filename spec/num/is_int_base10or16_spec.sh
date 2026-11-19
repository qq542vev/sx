#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_int_base10or16'
  sxtest_load ./build/modules/sx_num_is_int_base10or16.sh

  Context '有効な入力'
    It '符号付きの10進数で成功を返すこと'
      When call sx_num_is_int_base10or16 "0" "123" "+456" "-789" "+0" "-0"
      The status should be success
    End
    It '引数なしで成功を返すこと'
      When call sx_num_is_int_base10or16
      The status should be success
    End
  End

  Context '無効な入力'
    It '不正な形式で失敗を返すこと'
      When call sx_num_is_int_base10or16 "01" "+01" "--1" "++1" "12a"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_int_base10or16 ""
      The status should be failure
    End
  End
End
