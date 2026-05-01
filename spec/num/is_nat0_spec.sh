Describe 'sx_num_is_nat0'
  Include ./sx.sh

  Context '有効な入力 - 10進数'
    It '単一の有効な符号なし整数に対して成功を返すこと'
      When call sx_num_is_nat0 "0"
      The status should be success
    End

    It '複数の有効な符号なし整数に対して成功を返すこと'
      When call sx_num_is_nat0 "1" "123" "456789" "0"
      The status should be success
    End
  End

  Context '有効な入力 - 8進数'
    It '有効な8進数に対して成功を返すこと'
      When call sx_num_is_nat0 "07" "0123" "00"
      The status should be success
    End
  End

  Context '有効な入力 - 16進数'
    It '有効な16進数に対して成功を返すこと'
      When call sx_num_is_nat0 "0x0" "0x123" "0xABC" "0xdef" "0X1A"
      The status should be success
    End
  End

  Context '無効な入力 - 8進数'
    It '8進数として無効な数字(8, 9)を含む場合に失敗を返すこと'
      When call sx_num_is_nat0 "08" "019"
      The status should be failure
    End
  End

  Context '無効な入力 - 16進数'
    It '16進数として無効な文字を含む場合に失敗を返すこと'
      When call sx_num_is_nat0 "0xG" "0x12H"
      The status should be failure
    End

    It '接頭辞のみの場合に失敗を返すこと'
      When call sx_num_is_nat0 "0x" "0X"
      The status should be failure
    End
  End

  Context '無効な入力 - 非数字文字'
    It '英字を含む数値に対して失敗を返すこと'
      When call sx_num_is_nat0 "123a"
      The status should be failure
    End

    It '記号を含む数値に対して失敗を返すこと'
      When call sx_num_is_nat0 "123@"
      The status should be failure
    End
  End

  Context '無効な入力 - 負の数値'
    It '負の数値に対して失敗を返すこと'
      When call sx_num_is_nat0 "-1" "-0"
      The status should be failure
    End
  End

  Context '境界値・巨大数'
    It '最大値付近の数値に対して成功を返すこと'
      When call sx_num_is_nat0 "18446744073709551615" "0xffffffffffffffff" "01777777777777777777777"
      The status should be success
    End
  End
End
