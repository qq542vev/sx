#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_int_base8'
  sxtest_load ./build/modules/sx_num_is_int_base8.sh

  Context '有効な入力'
    It '符号付きの8進数で成功を返すこと'
      When call sx_num_is_int_base8 "01" "+07" "-0123" "00" "+00" "-00"
      The status should be success
    End

    It '引数なしで成功を返すこと'
      When call sx_num_is_int_base8
      The status should be success
    End
  End

  Context '無効な入力'
    It '不正な形式で失敗を返すこと'
      When call sx_num_is_int_base8 "007" "7" "+7"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_int_base8 ""
      The status should be failure
    End
  End
End
