#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_int_base8or10'
  sxtest_load ./build/modules/sx_num_is_int_base8or10.sh

  Context '有効な入力'
    It '符号付きの10進数で成功を返すこと'
      When call sx_num_is_int_base8or10 "0" "123" "+456" "-789" "+0" "-0"
      The status should be success
    End
    It '有効な8進数（先行0あり、0-7のみ）で成功を返すこと'
      When call sx_num_is_int_base8or10 "01" "+01"
      The status should be success
    End
    It '引数なしで成功を返すこと'
      When call sx_num_is_int_base8or10
      The status should be success
    End
  End

  Context '無効な入力'
    It '不正な形式で失敗を返すこと'
      When call sx_num_is_int_base8or10 "--1" "++1" "12a"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_int_base8or10 ""
      The status should be failure
    End
  End
End
