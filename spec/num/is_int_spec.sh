Describe 'sx_num_is_int'
  Include ./sx.sh

  Context '有効な入力'
    It '符号なしの整数に対して成功を返すこと'
      When call sx_num_is_int "0" "1" "123"
      The status should be success
    End

    It 'プラス符号付きの整数に対して成功を返すこと'
      When call sx_num_is_int "+0" "+1" "+123"
      The status should be success
    End

    It 'マイナス符号付きの整数に対して成功を返すこと'
      When call sx_num_is_int "-1" "-123"
      The status should be success
    End

    It 'マイナス符号付きのゼロに対して成功を返すこと'
      When call sx_num_is_int "-0"
      The status should be success
    End

    It '混合した形式に対して成功を返すこと'
      When call sx_num_is_int "0" "+123" "-456"
      The status should be success
    End
  End

  Context '無効な入力 - 先頭ゼロ'
    It '符号なしで先頭に0がある数値に対して失敗を返すこと'
      When call sx_num_is_int "01"
      The status should be failure
    End

    It '符号付きで先頭に0がある数値に対して失敗を返すこと'
      When call sx_num_is_int "+01" "-01"
      The status should be failure
    End
  End

  Context '無効な入力 - 非数字文字'
    It '英字を含む数値に対して失敗を返すこと'
      When call sx_num_is_int "123a" "+123b" "-123c"
      The status should be failure
    End

    It '符号のみの文字列に対して失敗を返すこと'
      When call sx_num_is_int "+" "-"
      The status should be failure
    End
  End

  Context '無効な入力 - 空文字列'
    It '空文字列に対して失敗を返すこと'
      When call sx_num_is_int ""
      The status should be failure
    End
  End
End
