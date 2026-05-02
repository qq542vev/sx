#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_pint'
  Include ./sx.sh

  Context '有効な入力 - 各基数'
    It '10進数の正の整数に対して成功を返すこと'
      When call sx_num_is_pint "1" "+123"
      The status should be success
    End

    It '8進数の正の整数に対して成功を返すこと'
      When call sx_num_is_pint "01" "+0123"
      The status should be success
    End

    It '16進数の正の整数に対して成功を返すこと'
      When call sx_num_is_pint "0x1" "+0xABC"
      The status should be success
    End
  End

  Context '無効な入力 - ゼロ'
    It '各基数のゼロに対して失敗を返すこと'
      When call sx_num_is_pint "0" "00" "0x0" "+0"
      The status should be failure
    End
  End

  Context '無効な入力 - 負の数値'
    It '負の数値に対して失敗を返すこと'
      When call sx_num_is_pint "-1" "-0x1"
      The status should be failure
    End
  End
End
