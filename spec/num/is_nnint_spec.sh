#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_num_is_nnint'
  Include ./sx.sh

  Context '有効な入力 - 各基数'
    It '各基数での0以上の整数に対して成功を返すこと'
      When call sx_num_is_nnint "0" "1" "07" "0xABC"
      The status should be success
    End

    It '各基数でのゼロ表現に対して成功を返すこと'
      When call sx_num_is_nnint "00" "0x0" "+0" "-0" "+0x0" "-00"
      The status should be success
    End
  End

  Context '無効な入力 - 負の数値'
    It '負の数値に対して失敗を返すこと'
      When call sx_num_is_nnint "-1" "-01" "-0x1"
      The status should be failure
    End
  End

  Context '無効な入力 - 非数字'
    It '整数以外の文字列に対して失敗を返すこと'
      When call sx_num_is_nnint "a" "" "1.5"
      The status should be failure
    End
  End
End
