#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nzint'
  Include ./sx.sh

  Context '有効な入力 - 各基数'
    It '10進数の0以外の整数に対して成功を返すこと'
      When call sx_num_is_nzint "1" "+123" "-1" "-123"
      The status should be success
    End

    It '8進数の0以外の整数に対して成功を返すこと'
      When call sx_num_is_nzint "01" "+0123" "-01" "-0123"
      The status should be success
    End

    It '16進数の0以外の整数に対して成功を返すこと'
      When call sx_num_is_nzint "0x1" "+0xABC" "-0x1" "-0xABC"
      The status should be success
    End
  End

  Context '無効な入力 - ゼロ'
    It '各基数のゼロに対して失敗を返すこと'
      When call sx_num_is_nzint "0" "00" "0x0" "+0" "-0" "+00" "-00" "+0x0" "-0x0"
      The status should be failure
    End
  End

  Context '無効な入力 - 非整数'
    It '非整数に対して失敗を返すこと'
      When call sx_num_is_nzint "1.5" "abc" ""
      The status should be failure
    End
  End
End
