#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nint'
  Include ./sx.sh

  Context '有効な入力 - 各基数'
    It '10進数の負の整数に対して成功を返すこと'
      When call sx_num_is_nint "-1" "-123"
      The status should be success
    End

    It '8進数の負の整数に対して成功を返すこと'
      When call sx_num_is_nint "-01" "-0123"
      The status should be success
    End

    It '16進数の負の整数に対して成功を返すこと'
      When call sx_num_is_nint "-0x1" "-0xABC"
      The status should be success
    End
  End

  Context '無効な入力 - ゼロ'
    It '各基数のゼロに対して失敗を返すこと'
      When call sx_num_is_nint "0" "-0" "-00" "-0x0"
      The status should be failure
    End
  End

  Context '無効な入力 - 正の数値・符号なし'
    It '正の数値や符号なし数値に対して失敗を返すこと'
      When call sx_num_is_nint "1" "+1" "0x1"
      The status should be failure
    End
  End
End
