#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nint_base10'
  sxtest_load ./build/modules/sx_num_is_nint_base10.sh

  Context '有効な入力'
    It '-1 以下の10進数（"-" 符号必須）で成功を返すこと'
      When call sx_num_is_nint_base10 "-1" "-123"
      The status should be success
    End

    It '引数なしで成功を返すこと'
      When call sx_num_is_nint_base10
      The status should be success
    End
  End

  Context '無効な入力'
    It '0 または 正の数値で失敗を返すこと'
      When call sx_num_is_nint_base10 "0" "-0" "1" "+1"
      The status should be failure
    End

    It '空文字列の場合に失敗を返すこと'
      When call sx_num_is_nint_base10 ""
      The status should be failure
    End
  End
End
