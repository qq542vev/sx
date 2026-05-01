Describe 'sx_num_is_nat1'
  Include ./sx.sh

  Context '有効な入力 - 10進数'
    It '単一の有効な正の整数に対して成功を返すこと'
      When call sx_num_is_nat1 "1"
      The status should be success
    End
  End

  Context '有効な入力 - 8進数'
    It '有効な正の8進数に対して成功を返すこと'
      When call sx_num_is_nat1 "01" "0123"
      The status should be success
    End
  End

  Context '有効な入力 - 16進数'
    It '有効な正の16進数に対して成功を返すこと'
      When call sx_num_is_nat1 "0x1" "0xABC"
      The status should be success
    End
  End

  Context '無効な入力 - ゼロ'
    It 'ゼロを表す各基数の入力に対して失敗を返すこと'
      When call sx_num_is_nat1 "0" "00" "0x0" "0X00"
      The status should be failure
    End
  End

  Context '無効な入力 - 8進数'
    It '8進数として無効な数字(8, 9)を含む場合に失敗を返すこと'
      When call sx_num_is_nat1 "08" "019"
      The status should be failure
    End
  End

  Context '無効な入力 - 16進数'
    It '16進数として無効な文字を含む場合に失敗を返すこと'
      When call sx_num_is_nat1 "0xG" "0x12H"
      The status should be failure
    End
  End

  Context '無効な入力 - 負の数値'
    It '負の数値に対して失敗を返すこと'
      When call sx_num_is_nat1 "-1" "-0x1"
      The status should be failure
    End
  End

  Context '境界値・巨大数'
    It '最大値付近の数値に対して成功を返すこと'
      When call sx_num_is_nat1 "9223372036854775807" "0x7fffffffffffffff"
      The status should be success
    End
  End
End
