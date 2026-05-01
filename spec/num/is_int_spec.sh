Describe 'sx_num_is_int'
  Include ./sx.sh

  Context '有効な入力 - 各基数'
    It '10進数の整数に対して成功を返すこと'
      When call sx_num_is_int "0" "+123" "-456"
      The status should be success
    End

    It '8進数の整数に対して成功を返すこと'
      When call sx_num_is_int "07" "+0123" "-010"
      The status should be success
    End

    It '16進数の整数に対して成功を返すこと'
      When call sx_num_is_int "0xABC" "+0x10" "-0xFF"
      The status should be success
    End
  End

  Context '有効な入力 - 符号付きゼロ'
    It '各基数の符号付きゼロに対して成功を返すこと'
      When call sx_num_is_int "+0" "-0" "+00" "-0x0"
      The status should be success
    End
  End

  Context '無効な入力'
    It '各基数で無効な文字を含む場合に失敗を返すこと'
      When call sx_num_is_int "08" "0xG" "+-123"
      The status should be failure
    End

    It '符号のみの場合に失敗を返すこと'
      When call sx_num_is_int "+" "-"
      The status should be failure
    End
  End
End
